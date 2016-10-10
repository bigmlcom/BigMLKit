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
#import "BMLWorkflow.h"
#import "BMLWorkflowTask.h"
#import "BMLResourceProtocol.h"

@class BMLAPIConnector;

extern NSString* const BMLWorkflowTaskCompletedTask;
extern NSString* const BMLWorkflowTaskCompletedWorkflow;


//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskSequence : BMLWorkflow

/**
 *  The read-only full UUID of the workflow resources from which this TaskSequence was created.
 */
@property (nonatomic, readonly) BMLResourceFullUuid* workflowUuid;

/**
 *  A read-only array containing the sequence of steps to execute. Steps are BMLWorkflowTask instances.
 */
@property (nonatomic, readonly) NSArray* steps;

/**
 *  Initializes a BMLWorkflowTaskSequence with a task descriptor, list of inputs,
 *  and a configurator object. Descriptors are passed into [BMLWorkflowTask newTaskWithDescriptor:]
 *  convenience constructor to create a task from its descriptor, which will only succeed if
 *  a class with the proper name has been defined somewhere. E.g., for a descriptor
 *  specifying a "create" verb and a BMLResourceTypeModel, a class named BMLWorkflowTaskCreateModel
 *  is required.
 *  The configurator decouples task configuration from task execution.
 *
 *  @param descriptors   The sequence of tasks to execute (array of BMLWorkflowTaskDescriptors).
 *  @param inputs        The inputs to be used (wzml-only); shared among all tasks in the sequence.
 *
 *  @return The initialized task sequence instance.
 */
- (instancetype)initWithWorkflowFullUuid:(BMLResourceFullUuid*)fullUuid
                             descriptors:(NSArray*)descriptors
                             inputs:(NSArray*)inputs;

/** Override the workflow inputs.
 *  This is used when re-running a script to re-create the inputs that were originally used.
 */
- (void)overrideDefaultInputs:(NSArray*)inputs;

@end
