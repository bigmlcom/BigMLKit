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

#import <Foundation/Foundation.h>
#import "BMLWorkflowTask.h"

@class BMLWorkflowTaskSequence;
@class BMLWorkflowTaskContext;
@class BMLWorkflowConfigurator;
@class ML4iOS;

extern NSString* const kModelTarget;
extern NSString* const kClusterTarget;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowModel : NSObject

@property (nonatomic) NSUInteger currentStep;
@property (nonatomic, weak) BMLWorkflowTask* currentlySelectedTask;

@property (nonatomic, strong) BMLWorkflowTaskSequence* workflow;

@property (nonatomic, strong) BMLWorkflowType* workflowType;
@property (nonatomic, strong) BMLWorkflowTaskContext* context;

@property (nonatomic, copy) NSString* workflowInitialTask;
@property (nonatomic, copy) NSString* workflowEndTask;
@property (nonatomic, readonly) NSArray* workflowTasks;

@property (nonatomic, strong) BMLResourceType* target;

- (void)createWorkflowWithConfigurator:(BMLWorkflowConfigurator*)configurator
                             connector:(ML4iOS*)connector;
- (void)configureWorkflowForResource:(NSDictionary*)resource;
- (void)configureWorkflowForResourceType:(BMLResourceType*)resourceType
                                    uuid:(BMLResourceUuid*)resourceUuid;


- (void)setValue:(id)value forModelProperty:(NSString*)property;
- (id)valueForModelProperty:(NSString*)property;

@end
