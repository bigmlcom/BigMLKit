//
//  BMLWhizzProviders.h
//  BigMLX
//
//  Created by sergio on 27/05/16.
//  Copyright © 2016 sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMLWhizzProvider : NSObject

+ (BMLWhizzProvider*)providerForURL:(NSURL*)url;

- (NSURL*)apiURL;
- (NSArray*)whizzFromResponse:(NSDictionary*)dict;

+ (void)listWhizzies:(NSString*)url completion:(void(^)(NSDictionary*, NSError*))completion;

@end
