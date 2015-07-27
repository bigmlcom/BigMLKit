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

@class BMLConnector;

extern NSString* const BMLWorkflowTaskCompletedTask;
extern NSString* const BMLWorkflowTaskCompletedWorkflow;

@class BMLWorkflowConfigurator;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskSequence : BMLWorkflow

/**
 *  A read-only array containing the sequence of steps to execute. Steps are BMLWorkflowTask instances.
 */
@property (nonatomic, readonly) NSArray* steps;
@property (nonatomic) NSUInteger initialStep;
@property (nonatomic) NSUInteger lastStep;

/**
 *  Initializes a BMLWorkflowTaskSequence with an array of NSString representing task
 *  names and a configurator object. Task names are passed into [BMLWorkflowTask newTaskWithDescriptors:]
 *  convenience constructor to create a task from its name.
 *  The configurator decouples task configuration from task execution.
 *
 *  @param steps        The task sequence to execute.
 *  @param configurator The configurator object responsible to provide the task configuration.
 *
 *  @return The initialized task sequence instance.
 */
- (instancetype)initWithDescriptors:(NSArray*)descriptors
                 configurator:(BMLWorkflowConfigurator*)configurator;

@end
