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
#import "BMLWorkflowTaskConfiguration.h"
#import "BMLResourceUtils.h"

NSString* const BMLWorkflowTaskCompletedTask = @"BMLWorkflowTaskCompletedTask";
NSString* const BMLWorkflowTaskCompletedWorkflow = @"BMLWorkflowTaskCompletedWorkflow";

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskSequence ()

@property (nonatomic) NSUInteger currentStep;

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
        [_steps addObject:[BMLWorkflowNoOpTask new]];
        
        for (NSString* step in steps)
            [_steps addObject:[BMLWorkflowTask newTaskForStep:step configurator:configurator]];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"currentTask"])
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"currentStep"]];
    return keyPaths;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)statusMessage {
    
    if (self.status == BMLWorkflowStarted)
        return self.currentTask.message;
    return [super statusMessage];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context
         completionBlock:(void(^)(NSError*))completion {

    [super runInContext:context completionBlock:completion];
    [self executeNextStep:nil];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithResource:(NSObject<BMLResourceProtocol>*)resource
                connector:(BMLConnector*)connector
          completionBlock:(void(^)(NSError*))completion {
    
    BMLWorkflowTaskContext* context = [[BMLWorkflowTaskContext alloc] initWithWorkflow:self
                                                                             connector:connector];
    context.info[kWorkflowName] = resource.name;

    BMLResourceUuid* resourceUuid = [BMLResourceUtils uuidFromFullUuid:resource.fullUuid];
    BMLResourceType* resourceType = [BMLResourceUtils typeFromFullUuid:resource.fullUuid];
    
    if (resourceType == kSourceEntityType) {
        context.info[kDataSourceId] = resourceUuid;
        
    } else if (resourceType == kFileEntityType) {
        
        context.info[kCSVSourceFilePath] = [NSURL URLWithString:resourceUuid];
        context.info[kWorkflowName] = [resourceUuid lastPathComponent];
        
    } else if (resourceType == kDatasetEntityType) {

        context.info[kDataSetId] = resourceUuid;
        
    } else if (resourceType == kModelEntityType) {

        context.info[kModelId] = resourceUuid;
        
    } else if (resourceType == kClusterEntityType) {

        context.info[kClusterId] = resourceUuid;
        
    } else if (resourceType == kPredictionEntityType) {
        
        NSAssert(NO, @"Workflow not supported.");
    }
    [self runInContext:context completionBlock:completion];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)executeNextStep:(BMLWorkflow*)workflow {

    NSAssert(self.status == BMLWorkflowStarting || self.status == BMLWorkflowStarted, @"Trying to execute step before starting workflow");
    
    if (_currentStep < [_steps count] - 1) {

        self.currentStep = self.currentStep + 1;
        [_steps[_currentStep] addObserver:self
                               forKeyPath:@"resourceStatus"
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                  context:NULL];

        self.status = BMLWorkflowStarted;
        [(BMLWorkflowTask*)_steps[_currentStep] runInContext:self.context completionBlock:nil];
    
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
