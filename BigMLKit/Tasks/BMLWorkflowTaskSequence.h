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

/**
 *  Initializes a BMLWorkflowTaskSequence with an array of NSString representing task
 *  names and a configurator object. Task names are passed into [BMLWorkflowTask newTaskForStep:]
 *  convenience constructor to create a task from its name.
 *  The configurator decouples task configuration from task execution.
 *
 *  @param steps        The task sequence to execute.
 *  @param configurator The configurator object responsible to provide the task configuration.
 *
 *  @return The initialized task sequence instance.
 */
- (instancetype)initWithSteps:(NSArray*)steps
                 configurator:(BMLWorkflowConfigurator*)configurator;

/**
 *  Runs the task using a specified resource as input resource, a given connector to access
 *  BigML REST API, and a completion block.
 *
 *  @param resource   An object implementing BMLResourceProtocol. It must be compatible with
 *                    the first workflow task that is going to be executed (e.g., a data source
 *                    when the first task is "create data set", etc.)
 *  @param connector  An ML4iOS instance allowed to access BigML REST API. This object shall
 *                    be capable to authenticate itself.
 *  @param completion A completion block able to handle both success and failure cases.
 */
- (void)runWithResource:(NSObject<BMLResourceProtocol>*)resource
                connector:(BMLConnector*)connector
          completionBlock:(void(^)(NSError*))completion;

@end
