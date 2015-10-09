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

#import "BMLWorkflowConfigurator.h"
#import "BMLWorkflowTaskConfiguration.h"
#import "BMLWorkflowTask.h"

#import "BMLResource.h"
#import "BMLResourceDefinition.h"
#import "BMLResourceTypeIdentifier+BigML.h"
#import "BMLWorkflowTaskConfigurationOption.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowConfigurator

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
 
    if (self = [super init]) {
        _taskConfigurations = [NSMutableDictionary new];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (void)setOption:(NSString*)optionName withValue:(id)currentValue configuration:(BMLWorkflowTaskConfiguration*)configuration {
    
    if ([currentValue isKindOfClass:[NSDictionary class]]) {
        for (NSString* optionName in [currentValue allKeys]) {
            [self setOption:optionName
                  withValue:currentValue[optionName]
              configuration:configuration];
        }
    } else {
        BMLWorkflowTaskConfigurationOption* model = [configuration optionModelForOptionNamed:optionName];
        model.isFieldIncluded = YES;
        model.currentValue = currentValue;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLWorkflowConfigurator*)configuratorFromConfigurationResource:(BMLResource*)resource {
    
    BMLWorkflowConfigurator* configurator = [BMLWorkflowConfigurator new];
    for (NSString* resourceType in resource.definition.json.allKeys) {
        BMLWorkflowTaskConfiguration* configuration = [configurator configurationForResourceType:[BMLResourceTypeIdentifier typeFromTypeString:resourceType]];
        for (NSString* optionName in [resource.definition.json[resourceType] allKeys]) {
            [self setOption:optionName
                  withValue:resource.definition.json[resourceType][optionName]
              configuration:configuration];
        }
    }
    return configurator;
}


//////////////////////////////////////////////////////////////////////////////////////
- (BMLWorkflowTaskConfiguration*)configurationForResourceType:(BMLResourceTypeIdentifier*)resourceType {
    
    NSString* typeString = resourceType.stringValue;
    if (!_taskConfigurations[typeString]) {
        BMLWorkflowTaskConfiguration* configuration =
        [[BMLWorkflowTaskConfiguration alloc] initWithResourceType:resourceType];
        if (configuration)
            _taskConfigurations[typeString] = configuration;
    }
    return _taskConfigurations[typeString];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)optionDictionaryAllOptions:(BOOL)allOptions {
    
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity:_taskConfigurations.allKeys.count];
    for  (NSString* k in _taskConfigurations.allKeys) {
        BMLWorkflowTaskConfiguration* c = _taskConfigurations[k];
        d[k] = [c optionDictionaryAllOptions:allOptions];
    }
    return d;
}

@end
