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

@class BMLConnector;

/**
 *  The following constants idnetify entities that can be stored inside of a BMLWorkflowTaskContext.
 *
 *  - kCSVSourceFilePath: the path to a CSV file to be used to create a datasource.
 *  - kDataSourceId: the id of a datasource (only one allowed).
 *  - kDataSourceDefinition: a dictionary representing the datasource of kDataSourceId id.
 *  - kDataSetId: the id of a dataset (only one allowed).
 *  - kDataSetDefinition: a dictionary representing the dataset of kDataSetId id.
 *  - kModelId/kModelDefinition: the id of a model (only one allowed)/a dictionary representing it.
 *  - kClusterId/kClusterDefinition: the id of a cluster (only one allowed)/a dictionary representing it.
 *  - kPredictionDefinition: a dictionary representing a prediction.
 *  - kProjectFullUuid: the full UUID of the project that owns all resources.
 *  - kWorkflowName: a user-friendly name that is used to create all intermediate resources.
 */
static NSString* const kCSVSourceFilePath = @"kCSVSourceFilePath";
static NSString* const kDataSourceId = @"kDataSourceId";
static NSString* const kDataSourceDefinition = @"kDataSourceDefinition";
static NSString* const kDataSetId = @"kDataSetId";
static NSString* const kDataSetDefinition = @"kDataSetDefinition";
static NSString* const kModelId = @"kModelId";
static NSString* const kModelDefinition = @"kModelDefinition";
static NSString* const kClusterId = @"kClusterId";
static NSString* const kClusterDefinition = @"kClusterDefinition";
static NSString* const kPredictionDefinition = @"kPredictionDefinition";

static NSString* const kProjectFullUuid = @"kProjectFullUuid";
static NSString* const kWorkflowName = @"kWorkflowName";

@class BMLWorkflow;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

/**
 *  A BMLWorkflowTaskContext instance provides a context for task execution where
 *  input, output, and intermediate results can be stored. The context also acts
 *  as a monitor for remote operations: it will poll BigML API to check a resource
 *  state progress and handle it accordingly to its semantics.
 *  The storage mechanism is exposed through a NSMutableDictionary. The association
 *  key/value is an implementation detail of the workflows that use the context to carry
 *  through their operation. In its current implementation, though, a few constraints
 *  are enforced: a context can host only one kind of any resource types at a time,
 *  and the keys used to identify those resources are provided at the top of this file.
 *  A context also hosts a connector object, which is responsible to handle communication
 *  with BigML through its API interface.
 */
@interface BMLWorkflowTaskContext : NSObject

/**
 *  The connector object to use for this context.
 */
@property (nonatomic, readonly) BMLConnector* ml;

/**
 *  The info dictionary providing access to all input, output, and intermediate results.
 */
@property (nonatomic, strong) NSMutableDictionary* info;

/**
 *  Initializes a BMLWorkflowTaskContext object by specifying the connector that
 *  shall be used and the workflow that will be executed.
 *
 *  @param workflow  The workflow to execute.
 *  @param connector The connector to use.
 *
 *  @return An instance of BMLWorkflowTaskContext
 */
- (instancetype)initWithWorkflow:(BMLWorkflow*)workflow
                       connector:(BMLConnector*)connector;

@end

