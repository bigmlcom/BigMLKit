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
#import "BMLResourceTypeIdentifier+BigML.h"

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
}

@synthesize steps = _steps;
@dynamic currentTask;

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithSteps:(NSArray*)steps configurator:(BMLWorkflowConfigurator*)configurator {
    
    if (self = [super init]) {
        
        self.status = BMLWorkflowIdle;
        _steps = [NSMutableArray new];
        for (NSString* step in steps)
            [_steps addObject:[BMLWorkflowTask newTaskForStep:step configurator:configurator]];

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
//-- sequence workflow's inputResourceTypes are taken to be its initialStep's
//-- this might not be always the case
//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)inputResourceTypes {
    return [_steps[_initialStep] inputResourceTypes];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)statusMessage {
    
    if (self.status == BMLWorkflowStarted)
        return self.currentTask.message;
    return [super statusMessage];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithResources:(NSArray*)resources
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {

    NSLog(@"START WORKFLOW: %@", self);
    [super runWithResources:resources inContext:context completionBlock:completion];
    [self executeStepWithResources:resources];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)executeStepWithResources:(NSArray*)resources {

    NSAssert(self.status == BMLWorkflowStarting || self.status == BMLWorkflowStarted, @"Trying to execute step before starting workflow");

    if (_currentStep < (int)[_steps count]-1 && _currentStep < (int)_lastStep) {

        self.currentStep = self.currentStep + 1;
        [_steps[_currentStep] addObserver:self
                               forKeyPath:@"resourceStatus"
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                  context:NULL];

        self.status = BMLWorkflowStarted;
        [(BMLWorkflowTask*)_steps[_currentStep] runWithResources:resources
                                                      inContext:self.context
                                                completionBlock:nil];
        
    } else {
        
        [self stopWithError:nil];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMLWorkflowTask*)currentTask {
    
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
