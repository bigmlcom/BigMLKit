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

#import "BMLWorkflowModel.h"
#import "BMLResourceUtils.h"
#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflowTaskSequence.h"

NSString* const kModelTarget = @"modelTarget";
NSString* const kClusterTarget = @"clusterTarget";

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowModel {
 
    NSMutableDictionary* _properties;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary*)properties {
 
    if (!_properties) {
        _properties = [NSMutableDictionary new];
    }
    return _properties;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setValue:(id)value forModelProperty:(NSString*)property {
    
    _properties[property] = value;
}

//////////////////////////////////////////////////////////////////////////////////////
- (id)valueForModelProperty:(NSString*)property {
    
    return _properties[property];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)workflowTasks {
    
    NSMutableArray* types = [@[kSourceEntityType,
                               kDatasetEntityType,
                               (self.target == kModelTarget)?kModelEntityType:kClusterEntityType,
                               kPredictionEntityType] mutableCopy];
    
    NSInteger initialIndex = [types indexOfObject:self.workflowInitialTask];
    
    if (initialIndex == [types count]-1)
        initialIndex--;
    
    if (initialIndex != NSNotFound && initialIndex >= 0) {
        NSRange range = (NSRange){ 0, initialIndex + 1 };
        [types removeObjectsInRange:range];
    }
    
    NSInteger finalIndex = [types indexOfObject:self.workflowEndTask];
    if (finalIndex != NSNotFound && finalIndex >= 0 && finalIndex < [types count]) {
        NSRange range = (NSRange){ finalIndex + 1, [types count] - finalIndex - 1};
        [types removeObjectsInRange:range];
    }
    
    NSMutableArray* tasks = [NSMutableArray array];
    for (short i = 0; i < [types count]; ++i) {
        tasks[i] = [NSString stringWithFormat:@"Create%@", [types[i] capitalizedString]];
    }
    return tasks;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)createWorkflowWithConfigurator:(BMLWorkflowConfigurator*)configurator
                             connector:(ML4iOS*)connector {
    
    self.workflow = [[BMLWorkflowTaskSequence alloc] initWithSteps:self.workflowTasks configurator:configurator];
    self.context = [[BMLWorkflowTaskContext alloc] initWithWorkflow:self.workflow connector:connector];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)configureWorkflowForResource:(NSDictionary*)resource {
    
    BMLResourceUuid* resourceUuid = [BMLResourceUtils uuidFromFullUuid:resource[@"resource"]];
    BMLResourceType* resourceType = [BMLResourceUtils typeFromFullUuid:resource[@"resource"]];

    self.workflowInitialTask = resourceType;
    self.context.info[kWorkflowName] = resource[@"name"];
    
    if ([resourceType isEqualToString:kSourceEntityType]) {
        self.context.info[kDataSourceId] = resourceUuid;
        
    } else if ([resourceType isEqualToString:kFileEntityType]) {
        
        self.workflowInitialTask = nil;
        self.context.info[kCSVSourceFilePath] = [NSURL URLWithString:resourceUuid];
        self.context.info[kWorkflowName] = [resourceUuid lastPathComponent];
        
    } else if ([resourceType isEqualToString:kDatasetEntityType]) {
        self.context.info[kDataSetId] = resourceUuid;
        
    } else if ([resourceType isEqualToString:kModelEntityType]) {
        self.context.info[kModelId] = resourceUuid;
        
    } else if ([resourceType isEqualToString:kClusterEntityType]) {
        self.context.info[kClusterId] = resourceUuid;
        
    } else if ([resourceType isEqualToString:kPredictionEntityType]) {
        
        [self prepareForPrediction:resource];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)configureWorkflowForResourceType:(BMLResourceType*)resourceType
                                    uuid:(BMLResourceUuid*)resourceUuid {
    
    [self configureWorkflowForResource:@{ @"resource" : [NSString stringWithFormat:@"%@/%@",
                                                       resourceType, resourceUuid],
                                          @"name" : resourceUuid }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForPrediction:(NSDictionary*)resource {
    
    self.context.info[kPredictionDefinition] = resource;
    if (resource[@"model"]) {
        self.context.info[kModelId] = [BMLResourceUtils uuidFromFullUuid:resource[@"model"]];
    } else if (resource[@"cluster"]) {
        self.context.info[kClusterId] = [BMLResourceUtils uuidFromFullUuid:resource[@"cluster"]];
    } else {
        NSAssert(NO, @"Should not be here!");
    }
}

@end
