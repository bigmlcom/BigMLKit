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
//

#import <Foundation/Foundation.h>
#import "BMLWorkflowTask.h"
//#import "bigml-objc.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTask ()

//-- these properties should be declared in the category below, but it is not allowed
//-- if no refactoring is possible, then they should be replaced with associated objs
@property (nonatomic, readonly) BOOL allowsUserInteraction;
@property (nonatomic, weak) id<BMLResource> runningResource;
@property (nonatomic, readonly) BMLResourceTypeIdentifier* inputResourceType;
//@property (nonatomic, strong) BMLWorkflowConfigurator* configurator;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTask (Private)

- (NSMutableDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context;
- (instancetype)initWithResourceType:(BMLResourceTypeIdentifier*)resourceName;

- (void)genericCompletionHandler:(id<BMLResource>)resource
                           error:(NSError*)error
                      completion:(BMLWorkflowCompletedBlock)completion;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLInputTask : BMLWorkflowTask

@property (nonatomic, strong) NSString* inputName;
@property (nonatomic, strong, readwrite) NSString* name;

+ (BMLInputTask*)newInputForDescriptor:(BMLWorkflowInputDescriptor*)inputDescriptor;

@end

