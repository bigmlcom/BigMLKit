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
#import "BigMLApp-Swift.h"

//////////////////////////////////////////////////////////////////////////////////////
typedef enum {
    BMLWorkflowIdle,
    BMLWorkflowStarting,
    BMLWorkflowStarted,
    BMLWorkflowEnded,
    BMLWorkflowFailed,
} BMLWorkflowStatus;

//typedef enum {
//    BMLResourceStatusUndefined = BMLResourceStatusUndefined,
//    BMLResourceStatusWaiting = BMLResourceStatusWaiting,
//    BMLResourceStatusQueued = BMLResourceStatusQueued,
//    BMLResourceStatusStarted = BMLResourceStatusStarted,
//    BMLResourceStatusEnded = BMLResourceStatusEnded,
//    BMLResourceStatusFailed = BMLResourceStatusFailed,
//} BMLWorkflowTaskStatus;

@class BMLWorkflowConfigurator;
@class BMLWorkflowTaskContext;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

/**
 *  The BMLWorkflow class represents workflows, i.e., collection of BigML operations.
 *  A workflow can be as simple as implying a single call to BigML REST API, e.g.
 *  to create a data source, or include multiple steps.
 *  BMLWorkflow is an abstract base class that basically is useful to build composite
 *  workflows combining lower-level workflows together.
 */
@interface BMLWorkflow : NSObject

/**
 *  The name used to identify this workflow.
 */
@property (nonatomic, strong) NSString* name;

/**
 *  A string describing the workflow.
 */
@property (nonatomic, readonly) NSString* message;

/**
 *  A string representing what the workflow is currently doing.
 */
@property (nonatomic, readonly) NSString* statusMessage;

/**
 *  This value, comprised between 0 and 1, represents the progress of the workflow.
 */
@property (nonatomic) float progress;

/**
 *  The current task which is being executed.
 */
@property (nonatomic, readonly) BMLWorkflow* currentTask;

/**
 *  The overall workflow status.
 */
@property (nonatomic) BMLWorkflowStatus status;

/**
 *  The current task-level status. This value represents the current task status in BigML REST API terms.
 */
@property (nonatomic) BMLResourceStatus resourceStatus;

/**
 *  The resource that this task is responsible to handle (create, retrieve, etc.).
 */
@property (nonatomic) id<BMLResource> outputResource;

/**
 *  Shortcut to the info dictionary associated to this workflow (through its running context).
 */
@property (nonatomic, readonly) NSDictionary* info;

/**
 *  The context where the workflow is running.
 */
@property (nonatomic, readonly) BMLWorkflowTaskContext* context;

/**
 *  The error, if any, associated with the workflow.
 */
@property (nonatomic, strong) NSError* error;

/**
 *  A facility method that will handle an error condition. The default implementation will just
 *  call stopWithError:.
 *
 *  @param error The error that is to ba handled. This parameter may not be nil.
 */
- (void)handleError:(NSError*)error;

/**
 *  This method stops the current workflow execution and call the completion block.
 *  if an error is passed in, that error is forwarded to the completion block and
 *  the workflow status is set to BMLWorkflowFailed.
 *  If no error is given, then it is understood that the workflow completed successfully.
 *
 *  @param error The optional error that was encountered during execution.
 */
- (void)stopWithError:(NSError*)error;

/**
 *  Run the workflow in a given context. At the end of the workflow execution, the completion 
 *  block is called.
 *
 *  @param context    The context where the workflow should get/write parameters from/to.
 *  @param completion A completion block.
 */
//- (void)runInContext:(BMLWorkflowTaskContext*)context
//         completionBlock:(void(^)(NSError*))completion;

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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(NSError*))completion;

@end
