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
@interface BMLWorkflowTaskGetResource : BMLWorkflowTask
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
@interface BMLWorkflowTaskCreateEvaluation : BMLWorkflowTaskCreateResource
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//@interface BMLWorkflowTaskCreateScript : BMLWorkflowTaskCreateResource
//@end

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

                        [self genericCompletionHandler:resource
                                                 error:error
                                            completion:completion];
                    }];
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskGetResource

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
               inContext:(BMLWorkflowTaskContext*)context
         completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    id<BMLResource> resource = inputs.firstObject;
    NSAssert([resource type] &&  [resource uuid], @"No model ID provided");
    [super runWithArguments:inputs inContext:context completionBlock:nil];
    
    [context.ml getResource:[resource type]
                       uuid:[resource uuid]
                 completion:^(id<BMLResource> __nullable resource, NSError * __nullable error) {
                     
                     [self genericCompletionHandler:resource
                                              error:error
                                         completion:completion];
                 }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Choose model";
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
        defaultCollection[@"objective_field"] =
        self.runningResource.jsonDefinition[@"fields"][@"000000"][@"name"];
    } else if ([defaultCollection[@"objective_field"] isEqualToString:@"last_field"]) {
        [defaultCollection removeObjectForKey:@"objective_field"];
    }
    return defaultCollection;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return @[@{kWorkflowStartResource :
                   [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeDataset
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
    return @{kWorkflowStartResource :
                 [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeDataset
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
    return @[@{kWorkflowStartResource :
                   [[BMLWorkflowInputDescriptor alloc] initWithType:BMLResourceTypeDataset
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
    
    NSAssert([inputs count] == 1,
             @"Calling BMLWorkflowTaskCreatePrediction with wrong number of input resources");
    [super runWithArguments:inputs inContext:context completionBlock:nil];
    id<BMLResource> resource = inputs.firstObject;
    if (resource) {
        
        if (resource.jsonDefinition) {
            
            [self genericCompletionHandler:resource error:nil completion:completion];

        } else {

            [context.ml getResource:resource.type
                               uuid:resource.uuid
                         completion:^(id<BMLResource> resource, NSError* error) {
                             
                             [self genericCompletionHandler:resource.jsonDefinition ? resource : nil
                                                      error:error
                                                 completion:completion];
                         }];
        }

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

/*
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
*/
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
- (NSArray*)reifyParameters:(NSArray*)parameters inputs:(NSArray*)inputs {

    NSMutableArray* results = [NSMutableArray new];
    for (NSDictionary* p in parameters) {
        for (BMLDragDropFieldModel* m in inputs) {
            if ([p[@"name"] isEqualToString:m.name]) {
                if (m.resourceTypes.count > 1) {
                    
                    BMLResourceTypeIdentifier* type =
                    [BMLResourceTypeIdentifier typeFromFullUuid:m.currentValue];
                    //-- override file type since wzml does not support it and we will send
                    //-- instead the source-id of a datasource generated on the fly.
                    if (type == BMLResourceTypeFile) {
                        type = BMLResourceTypeSource;
                    }
                    NSMutableDictionary* q = [p mutableCopy];
                    q[@"type"] =
                    [NSString stringWithFormat:@"%@-id", type.stringValue];
                    [results addObject:q];
                } else {
                    [results addObject:p];
                }
                break;
            }
        }
    }
    return results;
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
    
    for (BMLFieldModel* f in inputs) {
        if (!f.currentValue) {
            [self genericCompletionHandler:nil
                                     error:[NSError
                                            errorWithInfo:@"Please provide values for all input fields"
                                            code:-10601]
                                completion:completion];
            return;
        }
    }
    
    if (inputs)
        context.info[@"script_inputs"] = inputs;
    
    BMLMinimalResource* resource =
    [[BMLMinimalResource alloc] initWithName:context.info[@"name"] ?: @"Temporary Script"
                                        type:BMLResourceTypeWhizzmlSource
                                        uuid:@""
                                  definition:@{}];
    NSDictionary* dict = @{ @"source_code" : resourceDict[@"source_code"],
                            @"description" : resourceDict[@"description"] ?: @"",
                            @"parameters" : [self reifyParameters:resourceDict[@"parameters"]
                                                           inputs:inputs],
                            @"tags" : @[@"bigmlx_temp_script"] };
    
    [context.ml createResource:BMLResourceTypeWhizzmlScript
                          name:context.info[@"name"] ?: @"Temporary Script"
                       options:dict //-- could we use resourceDict here??????
                          from:resource
                    completion:^(id<BMLResource> resource, NSError* error) {
                        
                        [self genericCompletionHandler:resource
                                                 error:error
                                            completion:completion];
                    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    
    NSAssert(NO, @"BMLWorkflowTaskBuildScript inputResourceTypes SHOULD NOT BE HERE");
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
    
    NSMutableDictionary* options = [[self.configurator configurationDictionary][@"configurations"]
                                    mutableCopy];
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
    NSError* __block processingError = nil;
    for (BMLFieldModel* field in [inputs subarrayWithRange: NSMakeRange(1, inputs.count-1)]) {
        if ([field isKindOfClass:[BMLDragDropFieldModel class]] &&
            [field.currentValue hasPrefix:@"file/"]) {

            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            BMLMinimalResource* resource =
            [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                            fullUuid:field.currentValue
                                          definition:@{}];
            
            NSMutableDictionary* options = [self optionsForCurrentContext:context];
            if (![context.projectFullUuid isEqualToString:[BMLResource allProjectsPseudoFullUuid]])
                [options setObject:context.projectFullUuid forKey:@"project"];

            [context.ml createResource:BMLResourceTypeSource
                                  name:[resource.uuid lastPathComponent]
                               options:options
                                  from:resource
                            completion:^(id<BMLResource> resource, NSError* error) {
                                
                                if (resource) {
                                    [processedInputs addObject:@[field.title, resource.fullUuid]];
                                } else {
                                    processingError = error ?:
                                    [NSError errorWithInfo:@"Could not create datasource from file"
                                                      code:-1];
                                }
                                dispatch_semaphore_signal(sem);
                            }];
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            if (processingError)
                break;
        } else {
            if (field.name && field.currentValue)
                [processedInputs addObject:@[field.name, field.currentValue]];
        }
    }
    *errorp = processingError;
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
        BMLMinimalResource* script =
        [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                        fullUuid:[inputs.firstObject fullUuid]
                                      definition:@{}];
        [context.ml createResource:BMLResourceTypeWhizzmlExecution
                              name:context.info[@"name"]?:@"New Script"
                           options:@{ @"arguments" : arguments,
                                      @"creation_defaults": [self optionsForCurrentContext:context]}
                              from:script
                        completion:^(id<BMLResource> resource, NSError* error) {
                                                        
                            [self genericCompletionHandler:resource
                                                     error:error
                                                completion:completion];
                            
                            //-- if this was chained in through buildScript, then delete the script.
                            //-- this is better solved by allowing script multiplexing.
                            if (context.info[@"script_inputs"] || error) {
                                [context.ml deleteResource:script.type
                                                      uuid:script.uuid
                                                completion:^(NSError* error) {
                                                    NSLog(@"Could not delete intermediate script: %@", error);
                                                }];
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
