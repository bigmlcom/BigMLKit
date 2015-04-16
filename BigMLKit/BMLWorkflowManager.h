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
 *  An NSArrayController representing all tasks in execution.
 *  For each handled task, the array controller provides access to a NSDictionary
 *  with the following keys:
 *
 *   - task: task title, a NSString
 *   - status: task status, a BMLWorkflowStatus
 *   - task: the tast itself, aBMLWorkflowTask
 *   - count: the sequence index of the task, an integer.
 */
@property (nonatomic, weak) IBOutlet NSArrayController* tasks;

/**
 *   The currently running workflow, i.e., the latest one.
 */
@property(nonatomic, readonly, weak) BMLWorkflow* currentWorkflow;

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
 *
 *  @param the workflow to remove.
 */
- (void)removeWorkflow:(BMLWorkflow*)task;

- (void)setCurrentWorkflowAtIndex:(NSUInteger)index;

- (NSArray*)workflows;

@end
