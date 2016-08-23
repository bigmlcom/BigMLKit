//
//  BMLWhizzProviders.m
//  BigMLX
//
//  Created by sergio on 27/05/16.
//  Copyright © 2016 sergio. All rights reserved.
//

#import "BMLWhizzProviders.h"
#import "BMLHTTPConnector.h"

@interface BMLWhizzProvider ()

@property (nonatomic, strong) NSURL* userURL;

@end

@interface BMLWhizzGitHubGistProvider : BMLWhizzProvider
@end

@interface BMLWhizzGitHubProvider : BMLWhizzProvider
@end

@implementation BMLWhizzProvider

+ (BMLWhizzProvider*)providerForURL:(NSURL*)url {
   
    BMLWhizzProvider* provider = nil;
    if ([url.host isEqualToString:@"gist.github.com"]) {
        
        provider = [BMLWhizzGitHubGistProvider new];
        
    } else if ([url.host isEqualToString:@"github.com"]) {
        
        provider = [BMLWhizzGitHubProvider new];
    }
    provider.userURL = url;
    return provider;
}

+ (void)listWhizzies:(NSString*)url completion:(void(^)(NSDictionary*, NSError*))completion {

    if ([url containsString:@"github.com"]) {
        [BMLWhizzGitHubProvider listWhizzies:url completion:completion];
    }
}

- (NSURL*)apiURL {
    return nil;
}

- (NSArray*)whizzFromResponse:(NSDictionary*)dict {
    return nil;
}

@end

@implementation BMLWhizzGitHubGistProvider

- (NSURL*)apiURL {
    
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"https://api.github.com/gists/%@",
                                 self.userURL.path.lastPathComponent]];
}

- (NSArray*)whizzFromResponse:(NSDictionary*)gist {

    NSString* sourceCode = @"";
    NSArray* metadata = @[];
    NSString* gistId = gist[@"id"] ?: @"";
    NSString* gistName = gist[@"description"] ?: [NSString stringWithFormat:@"Gist: %@", gistId];
    
    NSError* error = nil;
    for (NSDictionary* file in [gist[@"files"] allValues]) {
        if ([file[@"type"] isEqualToString:@"application/json"]) {
            metadata =
            [NSJSONSerialization
             JSONObjectWithData:[file[@"content"] dataUsingEncoding:NSUTF8StringEncoding]
             options:NSJSONReadingAllowFragments
             error:&error];
        }
        if ([file[@"type"] isEqualToString:@"text/plain"]) {
            sourceCode = file[@"content"];
        }
    }
    
    return @[@{ @"source_code" : sourceCode,
              @"name" : gistName,
              @"description" : gistName,
              @"inputs" : metadata,
              @"provider_id" : self.userURL.absoluteString,
              @"tags" : @[] }];
}

@end

@implementation BMLWhizzGitHubProvider {
    
    NSString* _user;
    NSString* _repo;
    NSString* _branch;
    NSString* _path;
}

- (void)setUserURL:(NSURL*)userURL {
    
    [super setUserURL:userURL];
    
    NSRegularExpression* regex =
    [NSRegularExpression
     regularExpressionWithPattern:@"([^/]+)/([^/]+)/tree/([^/]+)/(.+)$"
     options:0
     error:nil];
    
    NSArray* matches = [regex matchesInString:self.userURL.path
                                      options:0
                                        range:NSMakeRange(0, [self.userURL.path length])];
    
    NSTextCheckingResult* match = [matches firstObject];
    if (match && [match numberOfRanges] == 5) {
        
        _user = [self.userURL.path substringWithRange:[match rangeAtIndex:1]];
        _repo = [self.userURL.path substringWithRange:[match rangeAtIndex:2]];
        _branch = [self.userURL.path substringWithRange:[match rangeAtIndex:3]];
        _path = [self.userURL.path substringWithRange:[match rangeAtIndex:4]];
        
        NSArray* branchSplits = [_branch componentsSeparatedByString:@"/"];
        if (branchSplits.count == 2) {
            _branch = branchSplits[0];
            _path = [NSString stringWithFormat:@"%@/%@", branchSplits[1], _path];
        } else {
            _branch = branchSplits.firstObject;
        }
    } else {
        _user = @"";
        _repo = @"";
        _branch = @"";
        _path = @"";
    }
}

- (NSURL*)apiURL {
    
    if (_user && _repo && _path && _branch) {
        return [NSURL URLWithString:[NSString stringWithFormat:
                                     @"https://api.github.com/repos/%@/%@/contents/%@?ref=%@",
                                     _user, _repo, _path, _branch]];
    }
    return nil;
}

+ (void)listWhizzies:(NSString*)url completion:(void(^)(NSDictionary*, NSError*))completion {

    NSString* user = nil;
    NSString* repo = nil;

    NSRegularExpression* regex =
    [NSRegularExpression
     regularExpressionWithPattern:@"([^/]+)/([^/]+)/?$"
     options:0
     error:nil];
    
    NSArray* matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    
    
    NSTextCheckingResult* match = [matches firstObject];
    if (match && [match numberOfRanges] == 3) {
        
        user = [url substringWithRange:[match rangeAtIndex:1]];
        repo = [url substringWithRange:[match rangeAtIndex:2]];
    }

    if (user && repo) {
        
        NSURL* url =  [NSURL URLWithString:[NSString stringWithFormat:
                                            @"https://api.github.com/repos/%@/%@/contents?ref=master",
                                            user, repo]];
        
        BMLHTTPConnector* connector = [BMLHTTPConnector new];
        [connector getURL:url
               completion:^(NSDictionary* dict, NSError* e) {
                   
                   NSMutableDictionary* whizzs = [NSMutableDictionary new];
                   if (!e) {
                       for (NSDictionary* whizz in [dict allValues]) {
                           if (whizz[@"name"] && whizz[@"html_url"])
                               whizzs[whizz[@"name"]] = whizz[@"html_url"];
                       }
                   }
                   if (completion)
                       completion(whizzs, e);
               }];
    }
}

- (NSArray*)whizzFromResponse:(NSDictionary*)dict {

    NSMutableArray* whizzs = [NSMutableArray array];
    NSString* sourceCode = nil;
    NSMutableDictionary* metadata = nil;
    
    NSError* error = nil;
    for (NSDictionary* file in [dict allValues]) {

        if ([file[@"type"] isEqualToString:@"dir"]) {
            
            NSArray* jsonObject = [NSJSONSerialization
                                 JSONObjectWithData:[NSData dataWithContentsOfURL:
                                                     [NSURL URLWithString:file[@"url"]]]
                                 options:NSJSONReadingAllowFragments
                                 error:&error];
            
            NSMutableArray* keys = [NSMutableArray array];
            for (NSUInteger i = 0; i < [jsonObject count]; i++) {
                [keys addObject:@(i)];
            }
            NSDictionary* components = [NSDictionary dictionaryWithObjects:jsonObject
                                                                   forKeys:keys];

            [whizzs addObjectsFromArray:[self whizzFromResponse:components]];
            
            
        } else {
        
            if ([[file[@"name"] pathExtension] isEqualToString:@"json"]) {
                metadata =
                [NSJSONSerialization
                 JSONObjectWithData:[NSData dataWithContentsOfURL:
                                     [NSURL URLWithString:file[@"download_url"]]]
                 options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers
                 error:&error];
            }
            if ([[file[@"name"] pathExtension] isEqualToString:@"whizzml"]) {
                sourceCode = [NSString stringWithContentsOfURL:
                              [NSURL URLWithString:file[@"download_url"]]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
            }
        }
    }
    
    if (metadata && sourceCode.length > 0) {
        
        metadata[@"source_code"] = sourceCode;
        metadata[@"provider_id"] = self.userURL.absoluteString;
        metadata[@"tags"] = @[];
        
        [whizzs addObject: metadata];
  
  
//  @{ @"source_code" : sourceCode,
//                             @"name" : metadata[@"name"] ?: @"Untitled Script",
//                             @"description" : metadata[@"description"] ?: @"",
//                             @"inputs" : metadata[@"inputs"] ?: @"",
//                             @"outputs" : metadata[@"outputs"] ?: @"",
//                             @"provider_id" : self.userURL.absoluteString,
//                             @"tags" : @[] }];
    }
    
    return whizzs;
}

@end
