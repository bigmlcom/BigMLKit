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

@class BMLWorkflowTaskContext;
@class BMLWorkflowConfigurator;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskDescriptor : NSObject

@property (nonatomic, copy) NSString* verb;
@property (nonatomic, strong) BMLResourceTypeIdentifier* type;
@property (nonatomic, copy) NSDictionary* properties;
@property (nonatomic, readonly) NSString* taskName;

//-- In both initializers, typeIdentifier can be nil.
//-- In this case, an unspecified resource is assumed. Notice that not all conceivable verbs
//-- can be used with unspecified resources (e.g., create)
- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier
                        verb:(NSString*)verb
                  properties:(NSDictionary*)properties;

- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier;

- (NSString*)typeAsString;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowInputDescriptor : BMLWorkflowTaskDescriptor

@property (nonatomic, copy) NSString* name;

- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier
                        name:(NSString*)name
                        verb:(NSString*)verb
                  properties:(NSDictionary*)properties;

- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier
                        name:(NSString*)name;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/**
 *  BMLWorkflowTask is the simplest form of BMLWorkflow, i.e., a workflow comprised of 
 *  one single step (e.g., create data source, create data set, etc.). This can be used
 *  as the basic building block for more complex workflows, such as BMLWorkfloTaskSequence.
 */
@interface BMLWorkflowTask : BMLWorkflow

/**
 *  A configuration object storing the current configuration for this task.
 */
//@property (nonatomic, strong) BMLWorkflowTaskConfiguration* configuration;

/**
 *  A descriptor object encapsulating both the main resource associated with this task
 *  as well as any additional properties to be used when instantiating the task.
 */
@property (nonatomic, strong) BMLWorkflowTaskDescriptor* descriptor;

/**
 *  Convenience constructor. It acts as a factory method, in that it takes a descriptor and creates
 *  a BMLWorkflowTask. The descriptor type and verb are used to identify the concrete class
 *  to instantiate, e.g., BMLWorkflowTaskCreateDataset from a Create/Dataset descriptor.
 *  The descriptor's properties are used to initialize the task properties.
 *  The class must be defined, otherwise the program will crash.
 *  The task is set up to use the given configurator object.
 *
 *  @param descriptor    a descriptor representing the task to be created.
 *  @param configurator  the configurator object to use.
 *
 *  @return the initialized instance.
 */
+ (BMLWorkflowTask*)newTaskWithDescriptor:(BMLWorkflowTaskDescriptor*)step
                             configurator:(BMLWorkflowConfigurator*)configurator;

- (instancetype)initWithDescriptor:(BMLWorkflowTaskDescriptor*)step
                      configurator:(BMLWorkflowConfigurator*)configurator NS_DESIGNATED_INITIALIZER;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/**
 *  This class is an "empty" BMLWorkflowTask that can be used as a placeholder.
 */
@interface BMLWorkflowNoOpTask : BMLWorkflowTask
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreatePrediction : BMLWorkflowTask

@end


