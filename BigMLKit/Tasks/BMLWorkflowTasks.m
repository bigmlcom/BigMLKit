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
#import "BMLWorkflowConfigurator.h"
#import "BMLFieldModels.h"

#import "BMLResourceTypeIdentifier.h"

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
@interface BMLWorkflowTaskCreateResource : BMLWorkflowTask

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateSource : BMLWorkflowTaskCreateResource

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateDataset : BMLWorkflowTaskCreateResource

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateModel : BMLWorkflowTaskCreateResource

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateCluster : BMLWorkflowTaskCreateResource

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateAnomaly : BMLWorkflowTaskCreateResource

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
@interface BMLWorkflowTaskCreateEvaluation : BMLWorkflowTaskCreateResource
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateScript : BMLWorkflowTaskCreateResource
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskBuildScript : BMLWorkflowTaskCreateResource
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskCreateExecution : BMLWorkflowTaskCreateResource
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
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    [super runWithArguments:inputs inContext:context completionBlock:nil];
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
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    [super runWithArguments:inputs inContext:context completionBlock:nil];
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
    
    if (self = [super initWithResourceType:BMLResourceTypeFile]) {
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
@implementation BMLWorkflowTaskCreateResource

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    [super runWithArguments:inputs inContext:context completionBlock:nil];
    [context.ml createResource:self.descriptor.type
                          name:[inputs.firstObject name]
                       options:[self optionsForCurrentContext:context]
                          from:inputs.firstObject
                    completion:^(id<BMLResource> resource, NSError* error) {

                        if (resource) {
                            self.outputResources = @[resource];
                            self.resourceStatus = BMLResourceStatusEnded;
                        } else {
                            self.error = error ?: [NSError errorWithInfo:@"Could not complete task" code:-1];
                            self.resourceStatus = BMLResourceStatusFailed;
                        }
                    }];
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateSource

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:BMLResourceTypeSource]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return @[@{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeFile
                                                                                  name:kWorkflowStartResource]}];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {

    NSAssert([inputs count] == 1, @"Calling BMLWorkflowTaskCreateSource with wrong number of input resources");
    if ([[NSFileManager defaultManager] fileExistsAtPath:[inputs.firstObject uuid]]) {
        
        [super runWithArguments:inputs inContext:context completionBlock:completion];

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
    
    if (self = [super initWithResourceType:BMLResourceTypeDataset]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context {
    
    NSMutableDictionary* options = [super optionsForCurrentContext:context];
    if (options[@"size"]) {
        options[@"size"] = @(floorf([self.runningResource.jsonDefinition[@"size"] intValue] *
                                    [options[@"size"] floatValue]));
    }
    return options;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return @[@{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeSource
                                                                                  name:kWorkflowStartResource]}];
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
    
    if (self = [super initWithResourceType:BMLResourceTypeModel]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context {
    
    NSMutableDictionary* defaultCollection = [super optionsForCurrentContext:context];
    if ([defaultCollection[@"objective_field"] isEqualToString:@"first_field"]) {
        defaultCollection[@"objective_field"] = self.runningResource.jsonDefinition[@"fields"][@"000000"][@"name"];
    } else if ([defaultCollection[@"objective_field"] isEqualToString:@"last_field"]) {
        [defaultCollection removeObjectForKey:@"objective_field"];
    }
    return defaultCollection;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return @[@{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeDataset
                                                                                  name:kWorkflowStartResource]}];
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
    
    if (self = [super initWithResourceType:BMLResourceTypeCluster]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)inputResourceTypes {
    return @{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeDataset
                                                                                  name:kWorkflowStartResource]};
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
    
    if (self = [super initWithResourceType:BMLResourceTypeAnomaly]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return @[@{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeDataset
                                                                                  name:kWorkflowStartResource]}];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return NSLocalizedString(@"Creating  Anomaly", nil);
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreatePrediction

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:BMLResourceTypePrediction]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    NSAssert([inputs count] == 1, @"Calling BMLWorkflowTaskCreatePrediction with wrong number of input resources");
    [super runWithArguments:inputs inContext:context completionBlock:nil];
    id<BMLResource> resource = inputs.firstObject;
    if (resource) {
        
        void(^predict)(id<BMLResource>) = ^(id<BMLResource> resource) {
            
            if (resource && resource.jsonDefinition) {
                self.outputResources = @[resource];
                self.resourceStatus = BMLResourceStatusEnded;
            } else {
                self.error = [NSError errorWithInfo:@"The model this prediction was based upon\nhas not been found" code:-1];
                self.resourceStatus = BMLResourceStatusFailed;
            }
            if (completion)
                completion(@[resource], self.error);
        };
        
        if (!resource.jsonDefinition) {
            
            [context.ml getResource:resource.type
                               uuid:resource.uuid
                         completion:^(id<BMLResource> resource, NSError* error) {
                             if (!error) {
                                 predict(resource);
                             } else {
                                 self.error = [NSError errorWithInfo:@"Could not find requested model/cluster" code:-1];
                                 self.resourceStatus = BMLResourceStatusFailed;
                             }
                         }];
        } else {
            predict(resource);
        }
        //        NSDictionary* options = [self optionsForCurrentContext:context];

    } else {
        self.error = [NSError errorWithInfo:@"Could not find requested model/cluster" code:-1];
        self.resourceStatus = BMLResourceStatusFailed;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return nil;
    NSAssert(NO, @"FAULT!!!");
//    return [self.descriptor.properties dictionaryWithValuesForKeys:@[kWorkflowStartResource]];
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
    
    if (self = [super initWithResourceType:BMLResourceTypeModel]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    NSAssert(context.info[kModelId], @"No model ID provided");
    [super runWithArguments:inputs inContext:context completionBlock:nil];

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
    
    if (self = [super initWithResourceType:BMLResourceTypeCluster]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    NSAssert(context.info[kModelId], @"No model ID provided");
    [super runWithArguments:inputs inContext:context completionBlock:nil];
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

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateEvaluation

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:BMLResourceTypeEvaluation]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context {
    
    NSMutableDictionary* options = [super optionsForCurrentContext:context];
    
    if (!options)
        options = [NSMutableDictionary new];
    
    BMLMinimalResource* r = context.info[kWorkflowSecondResource];
//    BMLResourceTypeIdentifier* t = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:r.type];
//    options[[t stringValue]] = r.fullUuid;
        options[[r.type stringValue]] = r.fullUuid;
    return options;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return @[@{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeModel
                                                                                  name:kWorkflowStartResource],
             kWorkflowSecondResource: [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeDataset
                                                                                  name:kWorkflowSecondResource]}];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Evaluating model";
}
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateScript

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:BMLResourceTypeWhizzmlScript]) {
    }
    return self;
}


//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
               inContext:(BMLWorkflowTaskContext*)context
         completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    NSMutableArray* arguments = [NSMutableArray new];
    for (BMLFieldModel* field in [inputs subarrayWithRange: NSMakeRange(1, inputs.count-1)]) {
        [arguments addObject:@[field.title, field.currentValue]];
    }
    BMLMinimalResource* resource =
    [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                    fullUuid:[inputs.firstObject fullUuid]
                                  definition:@{}];
    
    [context.ml createResource:BMLResourceTypeWhizzmlExecution
                          name:context.info[@"name"] ?: @"Temporary Name"
                       options:@{ @"arguments" : arguments }
                          from:resource
                    completion:^(id<BMLResource> resource, NSError* error) {
                        
                        if (resource) {
                            self.outputResources = resource.jsonDefinition[@"execution"][@"results"];
                            self.resourceStatus = BMLResourceStatusEnded;
                        } else {
                            self.error = error ?: [NSError errorWithInfo:@"Could not complete task" code:-1];
                            self.resourceStatus = BMLResourceStatusFailed;
                        }
                    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    
    NSAssert(NO, @"BMLWorkflowTaskCreateScript inputResourceTypes SHOULD NOT BE HERE");
    return nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskBuildScript

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:BMLResourceTypeWhizzmlScript]) {
    }
    return self;
}


//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
               inContext:(BMLWorkflowTaskContext*)context
         completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    BMLResource* workflow = self.descriptor.properties[kWorkflowStartResource];
    NSDictionary* resourceDict = workflow.jsonDefinition;
    if ([resourceDict[@"source_code"] length] == 0) {
        //-- HANDLE ERROR HERE
        return;
    }
    
    if (inputs)
        context.info[@"script_inputs"] = inputs;
    
    BMLMinimalResource* resource =
    [[BMLMinimalResource alloc] initWithName:context.info[@"name"] ?: @"Temporary Name"
                                        type:BMLResourceTypeWhizzmlSource
                                        uuid:@""
                                  definition:@{}];
    NSDictionary* dict = @{ @"source_code" : resourceDict[@"source_code"],
                            @"description" : resourceDict[@"description"] ?: @"",
                            @"parameters" : resourceDict[@"parameters"] ?: @[],
                            @"tags" : @[] };
    
    [context.ml createResource:BMLResourceTypeWhizzmlScript
                          name:context.info[@"name"] ?: @"Temporary Name"
                       options:dict //-- could we use resourceDict here??????
                          from:resource
                    completion:^(id<BMLResource> resource, NSError* error) {
                        
                        if (resource) {
                            self.outputResources = @[resource];
                            self.resourceStatus = BMLResourceStatusEnded;
                        } else {
                            self.error = error ?: [NSError errorWithInfo:@"Could not complete task" code:-1];
                            self.resourceStatus = BMLResourceStatusFailed;
                        }
                    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    
    NSAssert(NO, @"BMLWorkflowTaskCreateScript inputResourceTypes SHOULD NOT BE HERE");
    return nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskCreateExecution

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:BMLResourceTypeWhizzmlExecution]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context {
    
//    NSMutableDictionary* options = [super optionsForCurrentContext:context];
    NSDictionary* options = [self.configurator configurationDictionary][@"configurations"];
    if (!options)
        options = [NSMutableDictionary new];
    
//    BMLMinimalResource* r = context.info[kWorkflowSecondResource];
//    BMLResourceTypeIdentifier* t = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:r.type];
//    options[[t stringValue]] = r.fullUuid;
    return options;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)argumentsFromInputs:(NSArray*)inputs
                             inContext:(BMLWorkflowTaskContext*)context
                                 error:(NSError**)errorp {
    
    NSMutableArray* __block processedInputs = [NSMutableArray new];
    NSLog(@"SUBRANGE: %@", [inputs subarrayWithRange: NSMakeRange(1, inputs.count-1)]);
    for (BMLFieldModel* field in [inputs subarrayWithRange: NSMakeRange(1, inputs.count-1)]) {
        if ([field isKindOfClass:[BMLDragDropFieldModel class]] &&
            [field.currentValue hasPrefix:@"file/"]) {

            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            
            BMLMinimalResource* resource =
            [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                            fullUuid:field.currentValue
                                          definition:@{}];
            
            [context.ml createResource:BMLResourceTypeSource
                                  name:[resource.uuid lastPathComponent]
                               options:@{}
                                  from:resource
                            completion:^(id<BMLResource> resource, NSError* error) {
                                
                                if (resource) {
                                    [processedInputs addObject:@[field.title, resource.fullUuid]];
                                } else {
                                    *errorp = error ?:
                                    [NSError errorWithInfo:@"Could not create datasource from file"
                                                      code:-1];
                                }
                                dispatch_semaphore_signal(sem);
                            }];
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

        } else {
            [processedInputs addObject:@[field.name, field.currentValue]];
        }
    }
    return processedInputs;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
               inContext:(BMLWorkflowTaskContext*)context
         completionBlock:(BMLWorkflowCompletedBlock)completion {

    
    //-- Here we handle the input arguments. there are two cases: either this task is executed
    //-- within a WhizzMLWorkflow, in which case it receives correct 'inputs'; or, it is part
    //-- of an extended (local) script, in which case it receives its inputs from the previous
    //-- stage in context.info[@"script_inputs"].
    NSError* error = nil;
    NSMutableArray* arguments = [self argumentsFromInputs:context.info[@"script_inputs"] ?: inputs
                                                inContext:context
                                                    error:&error];
    if (!error) {
        BMLMinimalResource* resource =
        [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                        fullUuid:[inputs.firstObject fullUuid]
                                      definition:@{}];
        [context.ml createResource:BMLResourceTypeWhizzmlExecution
                              name:context.info[@"name"]?:@"New Script"
                           options:@{ @"arguments" : arguments,
                                      @"creation_defaults": [self optionsForCurrentContext:context]}
                              from:resource
                        completion:^(id<BMLResource> resource, NSError* error) {
                            
                            if (resource) {
                                
                                BMLResourceFullUuid* fullUuid = resource.jsonDefinition[@"execution"][@"result"];
                                [context.ml getResource:[BMLResourceTypeIdentifier typeFromFullUuid:fullUuid]
                                                   uuid:[BMLResourceTypeIdentifier uuidFromFullUuid:fullUuid]
                                             completion:^(id<BMLResource> resource, NSError* error) {
                                                 
                                                 if (resource) {

                                                     self.outputResources = @[resource];
                                                     self.resourceStatus = BMLResourceStatusEnded;
                                                 } else {
                                                     self.error = error ?:
                                                     [NSError errorWithInfo:@"Could not complete task" code:-1];
                                                     self.resourceStatus = BMLResourceStatusFailed;
                                                 }
                                             }];
                            } else {
                                self.error = error ?:
                                [NSError errorWithInfo:@"Could not complete task" code:-1];
                                self.resourceStatus = BMLResourceStatusFailed;
                            }
                        }];
    } else {
        self.error = error;
        self.resourceStatus = BMLResourceStatusFailed;
        if (completion)
            completion(nil, error);
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    
//    NSAssert(NO, @"BMLWorkflowTaskCreateExecution inputResourceTypes SHOULD NOT BE HERE");
    return nil;
}
@end
