// Copyright 2014-2015 BigML
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.
//

#import "BMLWorkflowTask+Private.h"
#import "BMLWorkflowTaskConfiguration.h"

#import <objc/runtime.h>

static void* gResourceTypePropertyKey = &gResourceTypePropertyKey;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTask (Private)

//////////////////////////////////////////////////////////////////////////////////////
- (BMLResourceType*)resourceType {
    return objc_getAssociatedObject(self, gResourceTypePropertyKey);
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setResourceType:(BMLResourceType*)resourceType {
    objc_setAssociatedObject(self, gResourceTypePropertyKey, resourceType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//////////////////////////////////////////////////////////////////////////////////////
- (BOOL)allowsUserInteraction {
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithResourceType:(BMLResourceType*)resourceName {
    
    if (self = [super init]) {
        self.bmlStatus = BMLWorkflowTaskUndefined;
        self.resourceType = [resourceName copy];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)optionStringForCurrentContext:(BMLWorkflowTaskContext*)context {
    
    NSMutableDictionary* optionValues = self.configuration.optionDictionary;
    for (NSString* collectionName in [optionValues allKeys]) {
        id optionValue = optionValues[collectionName];
        if ([NSJSONSerialization isValidJSONObject:optionValue]) {
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:optionValue options:0 error:nil];
            optionValues[collectionName] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    return optionValues;
}

@end

