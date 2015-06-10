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

#import "BMLWorkflowTask.h"
#import "BMLWorkflowTask+Private.h"
#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflowTaskConfiguration.h"
#import "BMLWorkflowConfigurator.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTask

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLWorkflowTask*)newTaskForStep:(NSString*)step configurator:(BMLWorkflowConfigurator*)configurator {
    
    NSString* taskClassName = [NSString stringWithFormat:@"BMLWorkflowTask%@", step];
    BMLWorkflowTask* item = [NSClassFromString(taskClassName) new];
    item.name = step;
    item.configuration = [configurator configurationForResourceType:item.resourceType];

    return item;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {

    if (self = [super init])
        self.resourceStatus = BMLResourceStatusUndefined;
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {

    [super runWithResource:resource inContext:context completionBlock:completion];
    self.resourceStatus = BMLResourceStatusStarted;
    
    [self addObserver:self
           forKeyPath:@"resourceStatus"
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:NULL];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"";
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMLWorkflowStatus)status {

    switch (self.resourceStatus) {
        case BMLResourceStatusUndefined:
            return BMLWorkflowIdle;
        case BMLResourceStatusWaiting:
        case BMLResourceStatusQueued:
        case BMLResourceStatusStarted:
            return BMLWorkflowStarted;
        case BMLResourceStatusEnded:
            return BMLWorkflowEnded;
        case BMLResourceStatusFailed:
            return BMLWorkflowFailed;
        default:
            NSAssert(NO, @"Should not be here: wrong resourceStatus found.");
            break;
    }
    NSAssert(NO, @"Should not be here: wrong resourceStatus found.");
    return BMLWorkflowIdle;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"status"]) {
        [keyPaths addObject:@"resourceStatus"];
    }
    
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowNoOpTask

@end

