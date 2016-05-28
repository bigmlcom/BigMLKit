//
//  BMLWhizzProviders.m
//  BigMLX
//
//  Created by sergio on 27/05/16.
//  Copyright © 2016 sergio. All rights reserved.
//

#import "BMLWhizzProviders.h"

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

- (NSURL*)apiURL {
    return nil;
}

- (NSDictionary*)whizzFromResponse:(NSDictionary*)dict {
    return nil;
}

@end

@implementation BMLWhizzGitHubGistProvider

- (NSURL*)apiURL {
    
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"https://api.github.com/gists/%@",
                                 self.userURL.path.lastPathComponent]];
}

- (NSDictionary*)whizzFromResponse:(NSDictionary*)gist {

    NSString* sourceCode = @"";
    NSArray* parameters = @[];
    NSString* gistId = gist[@"id"] ?: @"";
    NSString* gistName = gist[@"description"] ?: [NSString stringWithFormat:@"Gist: %@", gistId];
    
    NSError* error = nil;
    for (NSDictionary* file in [gist[@"files"] allValues]) {
        if ([file[@"type"] isEqualToString:@"application/json"]) {
            parameters =
            [NSJSONSerialization
             JSONObjectWithData:[file[@"content"] dataUsingEncoding:NSUTF8StringEncoding]
             options:NSJSONReadingAllowFragments
             error:&error];
        }
        if ([file[@"type"] isEqualToString:@"text/plain"]) {
            sourceCode = file[@"content"];
        }
    }
    
    return @{ @"source_code" : sourceCode,
              @"name" : gistName,
              @"description" : gistName,
              @"inputs" : parameters,
              @"gist_id" : gistId,
              @"tags" : @[] };
}

@end

@implementation BMLWhizzGitHubProvider

- (NSURL*)apiURL {
    
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
        
        NSString* user = [self.userURL.path substringWithRange:[match rangeAtIndex:1]];
        NSString* repo = [self.userURL.path substringWithRange:[match rangeAtIndex:2]];
        NSString* branch = [self.userURL.path substringWithRange:[match rangeAtIndex:3]];
        NSString* path = [self.userURL.path substringWithRange:[match rangeAtIndex:4]];
        
        NSArray* branchSplits = [branch componentsSeparatedByString:@"/"];
        if (branchSplits.count == 2) {
            branch = branchSplits[0];
            path = [NSString stringWithFormat:@"%@/%@", branchSplits[1], path];
        } else {
            branch = branchSplits.firstObject;
        }
        
        return [NSURL URLWithString:[NSString stringWithFormat:
                                     @"https://api.github.com/repos/%@/%@/contents/%@?ref=%@",
                                     user, repo, path, branch]];
    }
    return nil;
}

- (NSDictionary*)whizzFromResponse:(NSDictionary*)gist {

    return nil;
}

@end
