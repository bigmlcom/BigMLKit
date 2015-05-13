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
#import "BMLWorkflowTaskConfiguration.h"
#import "BMLResourceUtils.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflow {
    
    void(^_completion)(NSError*);
    BMLWorkflowTaskContext* _context;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)statusMessage {
    
    if (_status == BMLWorkflowFailed)
        return @"Workflow failed!";
    else if (_status == BMLWorkflowEnded)
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
- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
    if ([keyPath isEqualToString:@"bmlStatus"]) {
        
        if ([change[NSKeyValueChangeNewKey] intValue] != [change[NSKeyValueChangeOldKey] intValue]) {
            
            BMLWorkflow* task = object;
            if (task.bmlStatus == BMLResourceStatusEnded) {
                
                [task removeObserver:self forKeyPath:@"bmlStatus"];
                [self executeNextStep:nil];
                
            } else if (task.bmlStatus == BMLResourceStatusFailed) {
                
                [task removeObserver:self forKeyPath:@"bmlStatus"];
                [self handleError:task.error];
                self.status = BMLWorkflowFailed;
                
            } else {
                self.bmlStatus = task.bmlStatus;
            }
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context
         completionBlock:(void(^)(NSError*))completion {

    NSAssert(_status == BMLWorkflowEnded || _status == BMLWorkflowIdle || _status == BMLWorkflowFailed,
             @"Trying to re-start running task");
    NSAssert(context, @"Improper BMLWorkflowTaskSequence API usage: you must specify a context.");
    
    _completion = completion;
    _context = context;
    
    self.status = BMLWorkflowStarting;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)executeNextStep:(BMLWorkflow*)workflow {

    [self stopWithError:nil];
}

#pragma mark - Error handling
//////////////////////////////////////////////////////////////////////////////////////
- (void)stopWithError:(NSError*)error {
    
    NSAssert(_status == BMLWorkflowStarted || _status == BMLWorkflowStarting,
             @"Trying to stop idle task");
    
    if (_completion)
        _completion(error);
    
    self.status = error ? BMLWorkflowFailed : BMLWorkflowEnded;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)handleError:(NSError*)error {
    
    NSAssert(error, @"Should not call handleError without an error information.");
    [self stopWithError:error];
}

@end
