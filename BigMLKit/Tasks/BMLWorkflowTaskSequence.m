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
#import "BMLWorkflowTaskSequence.h"
#import "BMLWorkflowTask.h"
//-- check
//#import "BMLResourceTypeIdentifier+BigML.h"

NSString* const BMLWorkflowTaskCompletedTask = @"BMLWorkflowTaskCompletedTask";
NSString* const BMLWorkflowTaskCompletedWorkflow = @"BMLWorkflowTaskCompletedWorkflow";

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskSequence ()

@property (nonatomic) NSInteger currentStep;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskSequence {
    
    NSMutableArray* _steps;
    NSArray* _inputs;
}

@synthesize steps = _steps;
@dynamic currentTask;

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithDescriptors:(NSArray*)descriptors
                             inputs:(NSArray*)inputs
                       configurator:(BMLWorkflowConfigurator*)configurator {
    
    if (self = [super init]) {
        
        _inputs = inputs;
        self.status = BMLWorkflowIdle;
        _steps = [NSMutableArray new];
        for (BMLWorkflowTaskDescriptor* d in descriptors) {
            BMLWorkflowTask* newTask = [BMLWorkflowTask newTaskWithDescriptor:d
                                                                 configurator:configurator];
            if (!newTask)
                NSLog(@"WILL CRASH NOW...");
            [_steps addObject:newTask];
        }

        self.initialStep = 0;
        self.lastStep = [_steps count] - 1;
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"currentTask"])
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"currentStep"]];
    return keyPaths;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setInitialStep:(NSUInteger)initialStep {
    
    NSAssert(self.status != BMLWorkflowStarting && self.status != BMLWorkflowStarted,
             @"Trying to change initial step while workflow is running");
    NSAssert(initialStep < [_steps count], @"Wrong initial step (%d in %d elements)", (int)initialStep, (int)[_steps count]);
    if (initialStep < [_steps count]) {
        _initialStep = initialStep;
        self.currentStep = _initialStep - 1;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)steps {
    NSAssert(_initialStep <= _lastStep, @"Wrong workflow definition");
    return  [_steps subarrayWithRange:(NSRange){_initialStep, _lastStep - _initialStep + 1}];
}

//////////////////////////////////////////////////////////////////////////////////////
//-- sequence workflow's inputResourceTypes are taken to be its initialStep's for
//-- traditional workflow; in case of wzml's, the _inputs property rules
//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    
    if ([NSStringFromClass([_steps.firstObject class]) isEqualToString:@"BMLWorkflowTaskCreateScript"] ||
        [NSStringFromClass([_steps.firstObject class]) isEqualToString:@"BMLWorkflowTaskCreateExecution"])
        return _inputs ?:@[];
    return [_steps[_initialStep] inputResourceTypes];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)statusMessage {
    
    if (self.status == BMLWorkflowStarted)
        return self.currentTask.message;
    return [super statusMessage];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {

    NSLog(@"START WORKFLOW: %@", self);
    [super runWithArguments:inputs inContext:context completionBlock:completion];
    [self executeStepWithArguments:inputs];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)executeStepWithArguments:(NSArray*)inputs {

    NSAssert(self.status == BMLWorkflowStarting || self.status == BMLWorkflowStarted,
             @"Trying to execute step before starting workflow");
    
    if (_currentStep < (int)[_steps count]-1 && _currentStep < (int)_lastStep) {

        self.currentStep = self.currentStep + 1;
        [_steps[_currentStep] addObserver:self
                               forKeyPath:@"resourceStatus"
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                  context:NULL];

        self.status = BMLWorkflowStarted;
        [(BMLWorkflowTask*)_steps[_currentStep] runWithArguments:inputs
                                                       inContext:self.context
                                                 completionBlock:nil];
    } else {
        
        [self stopWithError:nil];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMLWorkflowTask*)currentTask {
    
    if (_currentStep < 0)
        return nil;
    return _steps[_currentStep];
}

#pragma mark - Error handling
//////////////////////////////////////////////////////////////////////////////////////
- (void)stopWithError:(NSError*)error {
    
    [super stopWithError:error];
    _currentStep = 0;
}

//////////////////////////////////////////////////////////////////////////////////////
//-- this method can be called from both outside of this class and from observeValue...
//-- this makes it possible.
//////////////////////////////////////////////////////////////////////////////////////
- (void)handleError:(NSError*)error {
    
    if (self.currentTask.resourceStatus != BMLResourceStatusFailed)
        [self.currentTask handleError:error];
    [super handleError:error];
}

@end
