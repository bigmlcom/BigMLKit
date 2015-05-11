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

#import "BMLWorkflowTask.h"
#import "BMLWorkflowTask+Private.h"
#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflowTaskConfiguration.h"
#import "BMLWorkflowConfigurator.h"
#import "BigMLKit-Swift.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskTest : BMLWorkflowTask
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskFailTest : BMLWorkflowTask
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateFile : BMLWorkflowTask

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateSource : BMLWorkflowTask

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateDataset : BMLWorkflowTask

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateModel : BMLWorkflowTask

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateCluster : BMLWorkflowTask

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreatePrediction : BMLWorkflowTask

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskChooseModel : BMLWorkflowTask
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskChooseCluster : BMLWorkflowTask
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskTest

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    return [super initWithResourceType:nil];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    [super runInContext:context completionBlock:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bmlStatus = BMLWorkflowTaskEnded;
    });
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Testing...";
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskFailTest

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    return [super initWithResourceType:nil];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    [super runInContext:context completionBlock:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.error = [NSError errorWithInfo:@"Test failure" code:-1];
        self.bmlStatus = BMLWorkflowTaskFailed;
    });
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Testing failure...";
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateFile

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kFileEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"";
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateSource

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kSourceEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    [super runInContext:context completionBlock:completion];
    if (context.info[kCSVSourceFilePath] &&
        [[NSFileManager defaultManager] fileExistsAtPath:[(NSURL*)context.info[kCSVSourceFilePath] path]]) {
        
//        context.ml.options = [self optionStringForCurrentContext:context];
//        [context.ml createSourceWithName:context.info[kWorkflowName]
//                                 project:context.info[kProjectFullUuid]
//                                filePath:[(NSURL*)context.info[kCSVSourceFilePath] path]];
        
        BMLMinimalResource* sourceFile = [[BMLMinimalResource alloc]
                                          initWithName:context.info[kWorkflowName]
                                          rawType:BMLResourceRawTypeFile
                                          uuid:context.info[kCSVSourceFilePath]];

        [context.ml createResource:BMLResourceRawTypeSource
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:sourceFile
                        completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                            //-- TBD: code from Context class should come here...
                        }];
        
    } else {
        
        self.error = [NSError errorWithInfo:@"Could not retrieve file information" code:-1];
        self.bmlStatus = BMLWorkflowTaskFailed;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return NSLocalizedString(@"Creating Data Source", nil);
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateDataset

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kDatasetEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)optionsForCurrentConfiguration:(BMLWorkflowTaskContext*)context {
    
    NSMutableDictionary* options = self.configuration.optionDictionary;
    NSMutableDictionary* defaultCollection = options[kOptionsDefaultCollection];
    defaultCollection[@"size"] = @(floorf([context.info[kDataSourceDefinition][@"size"] intValue] *
                                          [defaultCollection[@"size"] floatValue]));
    
    return options;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    [super runInContext:context completionBlock:nil];
    if (context.info[kDataSourceId]) {
        
//        context.ml.options = [self optionStringForCurrentContext:context];
//        [context.ml createDataSetWithDataSourceId:context.info[kDataSourceId]
//                                             name:context.info[kWorkflowName]];

        BMLMinimalResource* source = [[BMLMinimalResource alloc]
                                      initWithName:context.info[kWorkflowName]
                                      rawType:BMLResourceRawTypeSource
                                      uuid:context.info[kDataSourceId]];
        
        [context.ml createResource:BMLResourceRawTypeDataset
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:source
                        completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                            //-- TBD: code from Context class should come here...
                        }];
} else {
        
        self.error = [NSError errorWithInfo:@"Could not find requested datasource" code:-1];
        self.bmlStatus = BMLWorkflowTaskFailed;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return NSLocalizedString(@"Creating  Dataset", nil);
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateModel

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kModelEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)optionsForCurrentConfiguration:(BMLWorkflowTaskContext*)context {
    
    NSMutableDictionary* options = self.configuration.optionDictionary;
    NSMutableDictionary* defaultCollection = options[kOptionsDefaultCollection];
    if ([defaultCollection[@"objective_field"] isEqualToString:@"first_field"]) {
        defaultCollection[@"objective_field"] = context.info[kDataSetDefinition][@"fields"][@"000000"][@"name"];
    } else if ([defaultCollection[@"objective_field"] isEqualToString:@"last_field"]) {
        [defaultCollection removeObjectForKey:@"objective_field"];
    }
    return options;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    [super runInContext:context completionBlock:nil];
    if (context.info[kDataSetId]) {
        
//        context.ml.options = [self optionStringForCurrentContext:context];
//        [context.ml createModelWithDataSetId:context.info[kDataSetId]
//                                        name:context.info[kWorkflowName]];
        
        BMLMinimalResource* dataset = [[BMLMinimalResource alloc]
                                      initWithName:context.info[kWorkflowName]
                                      rawType:BMLResourceRawTypeDataset
                                      uuid:context.info[kDataSetId]];
        
        [context.ml createResource:BMLResourceRawTypeModel
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:dataset
                        completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                            //-- TBD: code from Context class should come here...
                        }];

        
    } else if (context.info[kModelId]) {
        
        [context.ml getResource:BMLResourceRawTypeModel
                           uuid:context.info[kModelId]
                     completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                     }];
//        [context.ml getModelWithId:context.info[kModelId]];
    } else {
        
        self.error = [NSError errorWithInfo:@"Could not find requested dataset" code:-1];
        self.bmlStatus = BMLWorkflowTaskFailed;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return NSLocalizedString(@"Creating Model", nil);
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateCluster

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kClusterEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    [super runInContext:context completionBlock:nil];
    if (context.info[kDataSetId]) {

//        context.ml.options = [self optionStringForCurrentContext:context];
//        [context.ml createClusterWithDataSetId:context.info[kDataSetId]
//                                          name:context.info[kWorkflowName]];
        
        BMLMinimalResource* dataset = [[BMLMinimalResource alloc]
                                      initWithName:context.info[kWorkflowName]
                                      rawType:BMLResourceRawTypeDataset
                                      uuid:context.info[kDataSetId]];
        
        [context.ml createResource:BMLResourceRawTypeCluster
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:dataset
                        completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                            //-- TBD: code from Context class should come here...
                        }];
        

        
    } else if (context.info[kClusterId]) {
        
        [context.ml getResource:BMLResourceRawTypeCluster
                           uuid:context.info[kClusterId]
                     completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                     }];
//        [context.ml getClusterWithId:context.info[kClusterId]];
    } else {
        self.error = [NSError errorWithInfo:@"Could not find requested dataset" code:-1];
        self.bmlStatus = BMLWorkflowTaskFailed;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return NSLocalizedString(@"Creating  Cluster", nil);
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreatePrediction

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kPredictionEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    [super runInContext:context completionBlock:nil];
    if (context.info[kModelId] || context.info[kClusterId]) {
        
        /*
        BMLResourceType* type = nil;
        BMLResourceUuid* uuid = nil;
        NSDictionary* definition = nil;
        
        if (context.info[kModelId]) { //-- predicting from tree
            
            type = kModelEntityType;
            uuid = context.info[kModelId];
            definition = context.info[kModelDefinition];
            
        } else if (context.info[kClusterId]) { //-- predicting from cluster
            
            type = kClusterEntityType;
            uuid = context.info[kClusterId];
            definition = context.info[kClusterDefinition];
        }
        if (!definition) {
            
            NSInteger status = 0;
            if ([type isEqualToString:kModelEntityType]) {
                definition = [context.ml getModelWithIdSync:context.info[kModelId]
                                                 statusCode:&status];
            } else if ([type isEqualToString:kClusterEntityType]) {
                definition = [context.ml getClusterWithIdSync:context.info[kClusterId]
                                                   statusCode:&status];
            }
        }
        if (definition) {
            if (context.info[kModelId]) {
                context.info[kModelDefinition] = definition;
            } else if (context.info[kClusterId]) {
                context.info[kClusterDefinition] = definition;
            }
            self.bmlStatus = BMLWorkflowTaskEnded;
        } else {
            
            self.error = [NSError errorWithInfo:@"The model this prediction was based upon has not been found" code:-1];
            self.bmlStatus = BMLWorkflowTaskFailed;
        }
        //        NSDictionary* options = [self optionStringForCurrentContext:context];
        */
    } else {
        self.error = [NSError errorWithInfo:@"Could not find requested model/cluster" code:-1];
        self.bmlStatus = BMLWorkflowTaskFailed;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Making Prediction";
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskChooseModel

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kModelEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    NSAssert(context.info[kModelId], @"No model ID provided");
    [super runInContext:context completionBlock:nil];

    [context.ml getResource:BMLResourceRawTypeModel
                       uuid:context.info[kModelId]
                 completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                 }];

//    [context.ml getModelWithId:context.info[kModelId]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Choose model";
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskChooseCluster

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kClusterEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    NSAssert(context.info[kModelId], @"No model ID provided");
    [super runInContext:context completionBlock:nil];
    [context.ml getResource:BMLResourceRawTypeCluster
                       uuid:context.info[kClusterId]
                 completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                 }];
//    [context.ml getModelWithId:context.info[kModelId]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Choose cluster";
}
@end

