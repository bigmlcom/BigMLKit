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

#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflow.h"
#import "BMLFieldModels.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflow {
    
    BMLWorkflowCompletedBlock _completion;
    BMLWorkflowTaskContext* _context;
}

@dynamic inputResourceTypes;

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)statusMessage {
    
    if (_status == BMLResourceStatusFailed)
        return @"Workflow failed!";
    else if (_status == BMLResourceStatusEnded)
        return @"Workflow Completed.";
    return @"";
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)info {
    
    return _context.info;
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMLWorkflow*)currentTask {
    
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return @[];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
    if ([keyPath isEqualToString:@"resourceStatus"]) {
        
        if ([change[NSKeyValueChangeNewKey] intValue] != [change[NSKeyValueChangeOldKey] intValue]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                BMLWorkflow* task = object;
                if (task.resourceStatus == BMLResourceStatusEnded) {
                    
                    if (self != task) {
                        self.outputResources =
                        [task.outputResources arrayByAddingObjectsFromArray:self.outputResources?:@[]];
                    }
                    [task removeObserver:self forKeyPath:@"resourceStatus"];
                    [self executeStepWithArguments:task.outputResources];
                    
                } else if (task.resourceStatus == BMLResourceStatusFailed) {
                    
                    [task removeObserver:self forKeyPath:@"resourceStatus"];
                    [self handleError:task.error];
                    self.status = BMLResourceStatusFailed;
                    
                } else {
                    self.resourceStatus = task.resourceStatus;
                }
            });
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    NSAssert(_status == BMLResourceStatusEnded || _status == BMLResourceStatusWaiting || _status == BMLResourceStatusFailed,
             @"Trying to re-start running task");
    NSAssert(context, @"Improper BMLWorkflowTaskSequence API usage: you must specify a context.");
    
    _completion = completion;
    _context = context;
    _outputResources = @[];
    
    self.status = BMLResourceStatusQueued;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)executeStepWithArguments:(NSArray*)resources {

    [self stopWithError:nil];
}

#pragma mark - Error handling
//////////////////////////////////////////////////////////////////////////////////////
- (void)stopWithError:(NSError*)error {
    
    NSAssert(_status == BMLResourceStatusStarted || _status == BMLResourceStatusQueued,
             @"Trying to stop idle task");
    
    if (_completion)
        _completion(self.outputResources, error);
    
    self.status = error ? BMLResourceStatusFailed : BMLResourceStatusEnded;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)handleError:(NSError*)error {
    
    NSAssert(error, @"Should not call handleError without an error information.");
    [self stopWithError:error];
}

@end
