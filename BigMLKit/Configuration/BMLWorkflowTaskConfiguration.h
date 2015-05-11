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

@class BMLWorkflowTaskConfigurationOption;
#import "BigMLKit.h"
#import "BigMLKit-Swift.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

/**
 *  BMLWorkflowTaskConfiguration provides an interface to work with resource
 *  configuration options. An instance of this class is ideally tied to a specific
 *  task in a workflow, while a BMLWorkflowConfigurator is tied to an entire workflow.
 *  Resource configuration options provided by BigML are described in a collection
 *  of plist files (e.g., modelConfigurationOptions.plist) that this class is able to
 *  interpret and expose through a higher-level interface.
 */
@interface BMLWorkflowTaskConfiguration : NSObject

/**
 *  Options are grouped; for each group you can get the options belonging to that group,
 *  and for each option, you can get its description.
 */
@property (nonatomic, readonly) NSArray* groups;
@property (nonatomic, readonly) NSDictionary* options;
@property (nonatomic, readonly) NSDictionary* optionDescriptions;
@property (nonatomic, readonly) NSDictionary* optionModels;

+ (NSString*)configurationPlistForResourceType:(BMLResourceType*)resourceType;

- (instancetype)initWithPList:(NSString*)plistName;
- (instancetype)initWithResource:(BMLResourceType*)resourceType;

- (BMLWorkflowTaskConfigurationOption*)optionModelForOptionNamed:(NSString*)optionName;
- (void)setOptionModel:(BMLWorkflowTaskConfigurationOption*)optionModel forOptionNamed:(NSString*)optionName;

- (NSMutableDictionary*)optionDictionary;

@end
