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

#import "BigMLApp-Swift.h"

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
@interface BMLWorkflowTaskCreateAnomaly : BMLWorkflowTask

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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {
    
    [super runWithResource:resource inContext:context completionBlock:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.resourceStatus = BMLResourceStatusEnded;
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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {
    
    [super runWithResource:resource inContext:context completionBlock:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.error = [NSError errorWithInfo:@"Test failure" code:-1];
        self.resourceStatus = BMLResourceStatusFailed;
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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {

    [super runWithResource:resource inContext:context completionBlock:completion];
    if (resource &&
        [[NSFileManager defaultManager] fileExistsAtPath:resource.uuid]) {
        
//        context.ml.options = [self optionStringForCurrentContext:context];
//        [context.ml createSourceWithName:context.info[kWorkflowName]
//                                 project:context.info[kProjectFullUuid]
//                                filePath:[(NSURL*)context.info[kCSVSourceFilePath] path]];
        
//        BMLMinimalResource* sourceFile = [[BMLMinimalResource alloc]
//                                          initWithName:context.info[kWorkflowName]
//                                          rawType:BMLResourceTypeFile
//                                          uuid:[context.info[kCSVSourceFilePath] path]];

        [context.ml createResource:BMLResourceTypeSource
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:resource
                        completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {

                            if (!error) {
                                self.outputResource = resource;
                                self.resourceStatus = BMLResourceStatusEnded;
                            } else
                                self.resourceStatus = BMLResourceStatusFailed;
                        }];
    } else {
        
        self.error = [NSError errorWithInfo:@"Could not retrieve file information" code:-1];
        self.resourceStatus = BMLResourceStatusFailed;
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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {

    [super runWithResource:resource inContext:context completionBlock:nil];
    if (resource) {
        
        [context.ml createResource:BMLResourceTypeDataset
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:resource
                        completion:^(id<BMLResource> resource, NSError* error) {

                            if (!error) {
                                self.outputResource = resource;
                                self.resourceStatus = BMLResourceStatusEnded;
                            } else {
                                self.error = error;
                                self.resourceStatus = BMLResourceStatusFailed;
                            }
                        }];
    } else {
    
        self.error = [NSError errorWithInfo:@"Could not find requested datasource" code:-1];
        self.resourceStatus = BMLResourceStatusFailed;
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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {
    
    [super runWithResource:resource inContext:context completionBlock:nil];
    if (resource) { //-- HERE WE SHOULD CHECK FOR THE RESOURCE TYPE
        
        [context.ml createResource:BMLResourceTypeModel
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:resource
                        completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {

                            if (!error) {
                                self.outputResource = resource;
                                self.resourceStatus = BMLResourceStatusEnded;
                            } else {
                                self.error = error;
                                self.resourceStatus = BMLResourceStatusFailed;
                            }
                        }];
        
    } else if (context.info[kModelId]) { //-- HERE WE SHOULD CHECK FOR THE RESOURCE TYPE
        
        NSAssert(NO, @"TBD");
        [context.ml getResource:BMLResourceTypeModel
                           uuid:context.info[kModelId]
                     completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {

                         if (!error) {
                             context.info[kModelId] = resource.uuid;
                             self.resourceStatus = BMLResourceStatusEnded;
                         } else
                             self.resourceStatus = BMLResourceStatusFailed;
                     }];
    } else {
        
        self.error = [NSError errorWithInfo:@"Could not find requested dataset" code:-1];
        self.resourceStatus = BMLResourceStatusFailed;
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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {
    
    NSAssert(NO, @"TBD");
    [super runWithResource:resource inContext:context completionBlock:nil];
    if (context.info[kDataSetId]) {

        BMLMinimalResource* dataset = [[BMLMinimalResource alloc]
                                      initWithName:context.info[kWorkflowName]
                                      rawType:BMLResourceTypeDataset
                                      uuid:context.info[kDataSetId]];
        
        [context.ml createResource:BMLResourceTypeCluster
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:dataset
                        completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {

                            if (!error) {
                                context.info[kClusterId] = resource.uuid;
                                self.resourceStatus = BMLResourceStatusEnded;
                            } else
                                self.resourceStatus = BMLResourceStatusFailed;
                        }];
        
    } else if (context.info[kClusterId]) {
        
        [context.ml getResource:BMLResourceTypeCluster
                           uuid:context.info[kClusterId]
                     completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {

                         if (!error) {
                             context.info[kClusterId] = resource.uuid;
                             self.resourceStatus = BMLResourceStatusEnded;
                         } else
                             self.resourceStatus = BMLResourceStatusFailed;
                     }];
    } else {
        self.error = [NSError errorWithInfo:@"Could not find requested dataset" code:-1];
        self.resourceStatus = BMLResourceStatusFailed;
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
@implementation BMLWorkflowTaskCreateAnomaly

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kAnomalyEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {
    
    NSAssert(NO, @"TBD");
    [super runWithResource:resource inContext:context completionBlock:nil];
    if (context.info[kDataSetId]) {
        
        BMLMinimalResource* dataset = [[BMLMinimalResource alloc]
                                       initWithName:context.info[kWorkflowName]
                                       rawType:BMLResourceTypeDataset
                                       uuid:context.info[kDataSetId]];
        
        [context.ml createResource:BMLResourceTypeAnomaly
                              name:context.info[kWorkflowName]
                           options:@{}
                              from:dataset
                        completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                            
                            if (!error) {
                                context.info[kAnomalyId] = resource.uuid;
                                self.resourceStatus = BMLResourceStatusEnded;
                            } else
                                self.resourceStatus = BMLResourceStatusFailed;
                        }];
        
    } else if (context.info[kAnomalyId]) {
        
        [context.ml getResource:BMLResourceTypeAnomaly
                           uuid:context.info[kAnomalyId]
                     completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                         
                         if (!error) {
                             context.info[kAnomalyId] = resource.uuid;
                             self.resourceStatus = BMLResourceStatusEnded;
                         } else
                             self.resourceStatus = BMLResourceStatusFailed;
                     }];
    } else {
        self.error = [NSError errorWithInfo:@"Could not find requested dataset" code:-1];
        self.resourceStatus = BMLResourceStatusFailed;
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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {
    
    [super runWithResource:resource inContext:context completionBlock:nil];
    if (resource) {
        
        void(^predict)(id<BMLResource>) = ^(id<BMLResource> resource) {
            
            if (resource && resource.jsonDefinition) {
                self.outputResource = resource;
                self.resourceStatus = BMLResourceStatusEnded;
            } else {
                self.error = [NSError errorWithInfo:@"The model this prediction was based upon has not been found" code:-1];
                self.resourceStatus = BMLResourceStatusFailed;
            }
        };
        
        BMLResourceUuid* uuid = nil;
        NSDictionary* definition = nil;
        
        BMLResourceTypeIdentifier* type = [[BMLResourceTypeIdentifier alloc] initWithRawType:resource.type];
        uuid = resource.uuid;
        definition = resource.jsonDefinition;
        
//        if (context.info[kModelId]) { //-- predicting from tree
//            
//            type = kModelEntityType;
//            uuid = context.info[kModelId];
//            definition = context.info[kModelDefinition];
//            
//        } else if (context.info[kClusterId]) { //-- predicting from cluster
//            
//            type = kClusterEntityType;
//            uuid = context.info[kClusterId];
//            definition = context.info[kClusterDefinition];
//            
//        } else if (context.info[kAnomalyId]) { //-- predicting from anomaly
//
//            type = kAnomalyEntityType;
//            uuid = context.info[kAnomalyId];
//            definition = context.info[kAnomalyDefinition];
//        } else {
//            NSAssert(NO, @"Should not be here! No proper resource found to base prediction on.");
//        }
        if (!definition) {
            
            [context.ml getResource:type.type
                               uuid:uuid
                         completion:^(id<BMLResource> resource, NSError* error) {
                             predict(resource);
                         }];
        } else {
            predict(resource);
        }
        //        NSDictionary* options = [self optionStringForCurrentContext:context];

    } else {
        self.error = [NSError errorWithInfo:@"Could not find requested model/cluster" code:-1];
        self.resourceStatus = BMLResourceStatusFailed;
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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {
    
    NSAssert(context.info[kModelId], @"No model ID provided");
    [super runWithResource:resource inContext:context completionBlock:nil];

    [context.ml getResource:BMLResourceTypeModel
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
- (void)runWithResource:(id<BMLResource>)resource
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(void(^)(id<BMLResource>, NSError*))completion {
    
    NSAssert(context.info[kModelId], @"No model ID provided");
    [super runWithResource:resource inContext:context completionBlock:nil];
    [context.ml getResource:BMLResourceTypeCluster
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

