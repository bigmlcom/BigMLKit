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

#import "BMLWorkflowTaskConfiguration.h"
#import "BMLWorkflowTaskConfigurationOption.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskConfiguration {
    
    NSMutableDictionary* _optionModels;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)configurationPlistForResourceType:(BMLResourceType*)resourceType {
    
    return [NSString stringWithFormat:@"%@ConfigurationOptions", resourceType];
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithPList:(NSString*)plistName {
 
    if (self = [super init]) {
        
        NSString* path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {

            _optionModels = [NSMutableDictionary new];

            NSDictionary* myDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            _groups = myDic[@"optionGroups"];
            _options = myDic[@"optionNames"];
            _optionDescriptions = myDic[@"optionDescriptions"];
            
        } else {
            return nil;
        }
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithResource:(BMLResourceType*)resourceType {
    
    NSString* plistName = [BMLWorkflowTaskConfiguration configurationPlistForResourceType:resourceType];
    if (self = [self initWithPList:plistName]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMLWorkflowTaskConfigurationOption*)optionModelForOptionNamed:(NSString*)optionName {

    return _optionModels[optionName];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setOptionModel:(BMLWorkflowTaskConfigurationOption*)optionModel forOptionNamed:(NSString*)optionName {
    
    NSAssert(optionModel, @"Passing a nil optionModel!");
        
    [_optionModels setObject:optionModel forKey:optionName];
}

////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary*)optionDictionary {
    
    NSMutableDictionary* optionValues = [NSMutableDictionary new];
    for (NSArray* optionArray in [_options allValues]) {
        for (NSString* option in optionArray) {
            
            BMLWorkflowTaskConfigurationOption* optionModel = _optionModels[option];
            if (!optionModel.showOnly && optionModel.isFieldIncluded && optionModel.currentValue) {
                
                NSString* collectionName = _optionDescriptions[option][@"collection"] ?: kOptionsDefaultCollection;
                NSMutableDictionary* collection = optionValues[collectionName];
                if (!collection) {
                    collection = [NSMutableDictionary dictionary];
                    optionValues[collectionName] = collection;
                }
                collection[option] = optionModel.currentValue;
            }
        }
    }
    
    return optionValues;
}

@end
