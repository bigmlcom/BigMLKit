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
#import "BMLWorkflowTaskContext.h"

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
    
    if (self = [self init]) {
        self.resourceStatus = BMLResourceStatusUndefined;
        self.inputResourceType = resourceName;
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context {
    
    return [[context.configurator configurationForResourceType:self.inputResourceType]
            optionDictionaryAllOptions:NO];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)genericCompletionHandler:(id<BMLResource>)resource
                           error:(NSError*)error
                      completion:(BMLWorkflowCompletedBlock)completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resource) {
            self.outputResources = @[resource];
            self.resourceStatus = BMLResourceStatusEnded;
        } else {
            self.error = error ?: [NSError errorWithInfo:@"Could not complete task" code:-1];
            self.resourceStatus = BMLResourceStatusFailed;
        }
        if (completion)
            completion(self.outputResources, self.error);
    });
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

