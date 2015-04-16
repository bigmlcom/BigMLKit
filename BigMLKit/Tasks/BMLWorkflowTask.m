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
#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflowTaskConfiguration.h"
#import "BMLWorkflowConfigurator.h"
#import "ML4iOS.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTask {
    
    BMLResourceType* _resourceType;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLWorkflowTask*)newTaskForStep:(NSString*)step configurator:(BMLWorkflowConfigurator*)configurator {
    
    NSString* taskClassName = [NSString stringWithFormat:@"BMLWorkflowTask%@", step];
    BMLWorkflowTask* item = [NSClassFromString(taskClassName) new];
    item.name = step;
    item.configuration = [configurator configurationForResourceType:item->_resourceType];

    return item;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {

    if (self = [super init])
        self.bmlStatus = BMLWorkflowTaskUndefined;
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {

    [super runInContext:context completionBlock:completion];
    self.bmlStatus = BMLWorkflowTaskStarted;
    
    [self addObserver:self
           forKeyPath:@"bmlStatus"
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:NULL];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"";
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMLWorkflowStatus)status {

    switch (self.bmlStatus) {
        case BMLWorkflowTaskUndefined:
            return BMLWorkflowIdle;
        case BMLWorkflowTaskWaiting:
        case BMLWorkflowTaskQueued:
        case BMLWorkflowTaskStarted:
            return BMLWorkflowStarted;
        case BMLWorkflowTaskEnded:
            return BMLWorkflowEnded;
        case BMLWorkflowTaskFailed:
            return BMLWorkflowFailed;
        default:
            NSAssert(NO, @"Should not be here: wrong bmlStatus found.");
            break;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"status"]) {
        [keyPaths addObject:@"bmlStatus"];
    }
    
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowNoOpTask

@end

