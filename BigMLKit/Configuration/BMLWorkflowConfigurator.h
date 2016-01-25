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

@class BMLWorkflowTaskConfiguration;
@class BMLWorkflowTask;
@protocol BMLResource;

/**
 *  BMLWorkflowConfigurator is a collection of BMLWorkflowTaskConfiguration,
 *  one for each step of a workflow.
 */
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowConfigurator : NSObject

+ (BMLWorkflowConfigurator*)configuratorFromConfigurationResource:(id<BMLResource>)resource;

- (BMLWorkflowTaskConfiguration*)configurationForResourceType:(BMLResourceTypeIdentifier*)resourceType;

- (NSDictionary*)configurationDictionary;

@end
