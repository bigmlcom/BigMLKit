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
#import "BigMLKit.h"
#import "BMLResource.h"

@class BMLWorkflow;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

/**
 *  A BMLWorkflowManager allows to keep track of multiple BMLWorkflows while they are
 *  executing. It can also be easily modified so it allows to handle a log of all
 *  past and present workflows.
 *  This is accomplished by means of a NSArrayController which exposes task details and allows
 *  to peek into their current/final state. The manager is responsible to update
 *  the task status as it changes.
 *  Besides this, this class' main aim is to relieve from having to keep workflows alive while they
 *  are running and to make it easier to run multiple workflows at the same time.
 *
 *  This class is only provided on OS X due to its dependency from NSArrayController.
 */
@interface BMLWorkflowManager : NSObject

/**
 *  The name of the workflow. Used mostly for macro workflows.
 *
 */
@property (nonatomic, strong) NSString* name;

/**
 *  An NSArrayController representing all tasks in execution.
 *  This includes both executions that are being created on the server
 *  and older executions.
 *  For each handled task, the array controller provides access to an object
 *  conforming to the BMLResource protocol.
 *
 */
@property (nonatomic, weak) NSArrayController* tasks;

/**
 * This option controls whether the cleanUpWorkflow: method effectively
 * removes a task from the task list. When it is YES, cleanUpWorkflow:
 * will keep the task in the list.
 */
@property (nonatomic) BOOL keepTasksAfterCompletion;

/**
 *   The currently running workflow, i.e., the latest one.
 */
@property(nonatomic, readonly, weak) BMLExecutionResource* currentWorkflowResource;

 /**
 *  The number of workflows that this manages handles, i.e., those that are executing.
 */
@property (nonatomic) NSUInteger runningTasksCount;

/**
 *  Adds a new workflow to the manager so it is kept alive and its status exposed through tasks.
 *
 *  @param task The workflow to add.
 */
- (void)addWorkflowAsCurrent:(BMLWorkflow*)task;

/**
 *  Removes a workflow from the manager, usually when it is done.
 *  If you remove a workflow before it completes, you have to ensure
 *  that the workflow object is not released, i.e., that someone else
 *  is owning (retaining) it.
 *  When the keepsTaskAfterCompletion is YES, this method will not
 *  remove the task (it just does some internal house keeping).
 *
 *  @param the workflow to remove.
 */
- (void)cleanUpWorkflow:(BMLWorkflow*)task;

/**
 *  This method will empty the list of current tasks and store them internally
 *  so they can be recovered later through popWorkflows.
 *  Only one level of stashing/popping is allowed.
 */
- (void)stashWorkflows;

/**
 *  This method will restore the list of tasks that were previously stashed.
 *  Existing tasks are removed.
 *  Only one level of stashing/popping is allowed.
 */
- (void)popWorkflows;

/**
 *  Sets the current workflow so that it matches the workflow at index index in tasks.
 *
 *  @param the index of the workflow to set as current.
 */
- (void)selectCurrentWorkflowAtIndex:(NSUInteger)index;

/**
 *  Sets the current workflow so that it matches the workflow passed. The workflow must exist
 *  for this to have any effect, otherwise the current selection is emptied.
 *
 *  @param the index of the workflow to set as current.
 */
- (void)selectCurrentWorkflow:(BMLResource*)resource;

/**
 *  Returns true is there are any workflows in tasks.
 *
 */
- (NSNumber*)areThereAnyTasks;

/**
 *  Returns a representation of the Workflow Manager content as a macro workflow.
 *
 */
- (NSDictionary*)macro;

@end
