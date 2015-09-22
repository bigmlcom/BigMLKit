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
#import "BMLWorkflowConfigurator.h"

#import <objc/runtime.h>

static void* gResourceTypePropertyKey = &gResourceTypePropertyKey;
static void* gRunningResourcePropertyKey = &gRunningResourcePropertyKey;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTask (Private)

//////////////////////////////////////////////////////////////////////////////////////
- (BMLResourceTypeIdentifier*)inputResourceType {
    return objc_getAssociatedObject(self, gResourceTypePropertyKey);
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setInputResourceType:(BMLResourceTypeIdentifier*)resourceType {
    objc_setAssociatedObject(self, gResourceTypePropertyKey, resourceType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//////////////////////////////////////////////////////////////////////////////////////
- (id<BMLResource>)runningResource {
    return objc_getAssociatedObject(self, gRunningResourcePropertyKey);
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setRunningResource:(id<BMLResource>)resource {
    objc_setAssociatedObject(self, gRunningResourcePropertyKey, resource, OBJC_ASSOCIATION_ASSIGN);
}

//////////////////////////////////////////////////////////////////////////////////////
- (BOOL)allowsUserInteraction {
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithResourceType:(BMLResourceTypeIdentifier*)resourceName {
    
    if (self = [super init]) {
        self.resourceStatus = BMLResourceStatusUndefined;
        self.inputResourceType = resourceName;
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context {
    
//    NSMutableDictionary* optionValues = ;
//    for (NSString* collectionName in [optionValues allKeys]) {
//        id optionValue = optionValues[collectionName];
//        if ([NSJSONSerialization isValidJSONObject:optionValue]) {
//            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:optionValue options:0 error:nil];
//            optionValues[collectionName] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        }
//    }
    return [[self.configurator configurationForResourceType:self.inputResourceType] optionDictionaryAllOptions:NO];
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLInputTask

@synthesize name = _name;

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLInputTask*)newInputForDescriptor:(BMLWorkflowInputDescriptor*)inputDescriptor {
    
    BMLInputTask* item = [[BMLInputTask alloc] initWithResourceType:inputDescriptor.type];
    item.name = [NSString stringWithFormat:@"%@%@", [inputDescriptor.verb capitalizedString],
                 [[inputDescriptor.type stringValue] capitalizedString]];
    [item setInputResourceType:inputDescriptor.type];
    return item;
}

@end

