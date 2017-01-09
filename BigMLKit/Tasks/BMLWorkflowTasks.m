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

#import "BMLResource.h"
#import "BMLWorkflowTask.h"
#import "BMLWorkflowTask+Private.h"
#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflowConfigurator.h"
#import "NSError+BMLError.h"

//-- these are required by I/O handling
#import "BMLFieldModels.h"
#import "BMLFieldModelFactory.h"

#import "BMLResourceTypeIdentifier.h"
#import "BMLResourceTypeIdentifier+BigML.h"

//////////////////////////////////////////////////////////////////////////////////////
NSArray* resultsFromExecution(id<BMLResource> resource) {
    
    NSMutableArray* outputResources = [NSMutableArray new];
    if (resource) {
        id results = resource.jsonDefinition[@"execution"][@"result"];
        if (results) {
            if ([results isKindOfClass:[NSDictionary class]]) {
                results = [results allValues];
            } else if (![results isKindOfClass:[NSArray class]]) {
                results = @[results];
            }
            
            for (id result in results) {
                
                if ([BMLResourceTypeIdentifier isValidFullUuid:result]) {
                    [outputResources addObject:[[BMLMinimalResource alloc]
                                                initWithName:resource.name
                                                fullUuid:result
                                                definition:nil]];
                }
            }
        }
    }
    return outputResources;
}

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
@interface BMLWorkflowTaskGetExecution : BMLWorkflowTask
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
@interface BMLWorkflowTaskCloneDataset : BMLWorkflowTaskCreateResource
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
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    [super runWithArguments:inputs inContext:context completionBlock:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
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
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    [super runWithArguments:inputs inContext:context completionBlock:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
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
    
    id<BMLResource> resource = inputs.lastObject;
    if ([inputs.lastObject isKindOfClass:[BMLDragDropFieldModel class]])
        resource = [[BMLMinimalResource alloc]
                    initWithName:@""
                    fullUuid:[(BMLDragDropFieldModel*)inputs.lastObject currentValue]
                    definition:@{}];
    NSAssert([resource type] &&  [resource uuid], @"No model ID provided");
    [super runWithArguments:inputs inContext:context completionBlock:nil];
    
    [context.ml getResource:[resource type]
                       uuid:[resource uuid]
                 completion:^(id<BMLResource> __nullable resource, NSError* __nullable error) {
                     
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
@implementation BMLWorkflowTaskGetExecution

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
               inContext:(BMLWorkflowTaskContext*)context
         completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    id resource = inputs.lastObject;
    [super runWithArguments:inputs inContext:context completionBlock:nil];
    
    NSString* uuid = nil;
    BMLResourceTypeIdentifier* type = nil;
    
    if (![resource isKindOfClass:[BMLMinimalResource class]]) {
        NSString* fullUuid = [(BMLDragDropFieldModel*)resource currentValue];
        uuid = [BMLResourceTypeIdentifier uuidFromFullUuid:fullUuid];
        type = [BMLResourceTypeIdentifier typeFromFullUuid:fullUuid];
    } else {
        uuid = [resource uuid];
        type = [(id<BMLResource>)resource type];
    }
    
    [context.ml getResource:type
                       uuid:uuid
                 completion:^(id<BMLResource> __nullable resource, NSError* __nullable error) {
                     
                     NSArray* outputResources = resultsFromExecution(resource);
                     NSMutableArray* outputs = [NSMutableArray new];
                     for (BMLMinimalResource* result in outputResources) {
                         if ([BMLResourceTypeIdentifier isValidFullUuid:result.fullUuid]) {
                             BMLDragDropFieldModel* outputModel =
                             [BMLFieldModelFactory
                              newDragAndDropTarget:@"resource_id"
                              currentValue:result.fullUuid
                              typeString:[NSString stringWithFormat:@"%@-id",
                                          result.type.stringValue]];
//                             outputModel.fullUuid = result.fullUuid;
                             [outputs addObject:outputModel];
                         }
                     }
                     if (outputs.count > 0)
                         context.info[@"script_inputs"] = outputs;

                     [self arrayCompletionHandler:outputResources
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
- (NSArray*)inputResourceTypes {
    return @[@{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc]
                                         initWithType:BMLResourceTypeFile
                                         name:kWorkflowStartResource]}];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {

    NSAssert([inputs count] == 1,
             @"Calling BMLWorkflowTaskCreateSource with wrong number of input resources");
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
    return @[@{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc]
                                         initWithType:BMLResourceTypeSource
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
@implementation BMLWorkflowTaskCloneDataset

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
@implementation BMLWorkflowTaskCreateModel

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
- (NSDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context {
    
    NSMutableDictionary* options = [super optionsForCurrentContext:context];
    
    if (!options)
        options = [NSMutableDictionary new];
    
    BMLMinimalResource* r = context.info[kWorkflowSecondResource];
        options[[r.type stringValue]] = r.fullUuid;
    return options;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    return @[@{kWorkflowStartResource : [[BMLWorkflowInputDescriptor alloc]
                                         initWithType:BMLResourceTypeModel
                                         name:kWorkflowStartResource],
               kWorkflowSecondResource: [[BMLWorkflowInputDescriptor alloc]
                                         initWithType:BMLResourceTypeDataset
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
@implementation BMLWorkflowTaskBuildScript

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)reifyParameters:(NSArray*)parameters inputs:(NSArray*)inputs {

    NSMutableArray* results = [NSMutableArray new];
    
    //-- let's consider only a pipeline: 1 input for 1-argument script
    //-- association is univocal.
    if (inputs.count == parameters.count && parameters.count == 1) {
        NSDictionary* p = parameters.firstObject;
        BMLFieldModel* m = inputs.firstObject;
        if ([p[@"type"] containsString:@"["]) {
            
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
        
    } else {

        for (NSDictionary* p in parameters) {
            for (BMLDragDropFieldModel* m in inputs) {
                if ([p[@"name"] isEqualToString:m.name]) {
                    //-- if a [ is present, then we have a multi-type argument
                    if ([p[@"type"] containsString:@"["]) {
                        
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

        [self genericCompletionHandler:nil
                                 error:[NSError
                                        errorWithInfo:@"Badly defined script found."
                                        code:-10605]
                            completion:completion];
        return;
    }
    
    for (BMLFieldModel* f in context.info[@"script_inputs"]) {
        if (!f.currentValue) {
            [self genericCompletionHandler:nil
                                     error:[NSError
                                            errorWithInfo:@"Please provide values for all input fields"
                                            code:-10601]
                                completion:completion];
            return;
        }
    }
    
    BMLMinimalResource* resource =
    [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                        type:BMLResourceTypeWhizzmlSource
                                        uuid:@""
                                  definition:@{}];
    resourceDict = @{ @"source_code" : resourceDict[@"source_code"],
                      @"description" : resourceDict[@"description"] ?: @"",
                      @"tags" : @[kTempScriptTag],
                      @"inputs" : [self reifyParameters:resourceDict[@"inputs"]
                                                     inputs:context.info[@"script_inputs"]] };
    
    [context.ml createResource:BMLResourceTypeWhizzmlScript
                          name:context.info[@"name"]
                       options:resourceDict
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
- (NSDictionary*)optionsForCurrentContext:(BMLWorkflowTaskContext*)context {
    
    NSMutableDictionary* options = [[context.configurator configurationDictionary][@"configurations"]
                                    mutableCopy];
    if (!options)
        options = [NSMutableDictionary new];
    return options;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)argumentsFromInputs:(NSArray*)inputs
                             inContext:(BMLWorkflowTaskContext*)context
                                 error:(NSError**)errorp {
    
    NSMutableArray* __block processedInputs = [NSMutableArray new];
    NSError* __block processingError = nil;
    
    inputs = [inputs ?: @[] arrayByAddingObjectsFromArray:context.info[@"script_inputs"] ?: @[]];
    
    for (id obj in [inputs subarrayWithRange: NSMakeRange(1, inputs.count-1)]) {
        if ([obj isKindOfClass:[BMLDragDropFieldModel class]]) {
            
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);

            BMLFieldModel* field = obj;
            if ([field.currentValue hasPrefix:@"file/"]) {
                
                BMLMinimalResource* resource =
                [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                                fullUuid:field.currentValue
                                              definition:@{}];
                
                NSMutableDictionary* options = [self optionsForCurrentContext:context];
                if (context.projectFullUuid &&
                    ![context.projectFullUuid isEqualToString:[BMLResourceTypeIdentifier allProjectsPseudoFullUuid]])
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
                
            } else if (field.options.count > 0) {
                
                BMLMinimalResource* resource =
                [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                                fullUuid:field.currentValue
                                              definition:@{}];
                NSMutableDictionary* options = [self optionsForCurrentContext:context];

                if (field.options[@"fields"]) {
                    options[@"input_fields"] = [[field.options[@"fields"]
                                                 filteredArrayUsingPredicate:
                                                 [NSPredicate predicateWithFormat:@"isIncluded == %d", YES]] valueForKey:@"FieldID"];
                }
                
                if ([field.options[@"flatlineString"] length] > 0) {
                    options[@"lisp_filter"] = field.options[@"flatlineString"];
                }
                
                [context.ml createResource:BMLResourceTypeDataset
                                      name:nil
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
        } else if ([obj isKindOfClass:[BMLFieldModel class]]) {
            BMLFieldModel* field = obj;
            if (field.name && field.currentValue)
                [processedInputs addObject:@[field.name, field.currentValue]];
        } else {
            BMLMinimalResource* field = obj;
            if (field.name && field.fullUuid)
                [processedInputs addObject:@[field.name, field.fullUuid]];
        }
    }
    *errorp = processingError;
    return processedInputs;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
               inContext:(BMLWorkflowTaskContext*)context
         completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    //-- Here we handle the input arguments. The first object in inputs is the script to run.
    //-- The rest of arguments to be passed to the script are taken from inputs and the context.
    //-- Currently, only a one-to-one relationship is supported, so the second object in inputs
    //-- or the first in context["script_inputs"] are used as first and unique argument.
    NSError* error = nil;
    NSMutableArray* arguments = [self argumentsFromInputs:inputs inContext:context error:&error];
    NSLog(@"RUNNING EXEC WITH ARGS %@", arguments);
    BOOL __block isTempExecution = NO;
    
    if (!error) {
        BMLMinimalResource* script =
        [[BMLMinimalResource alloc] initWithName:context.info[@"name"]
                                        fullUuid:[inputs.firstObject fullUuid]
                                      definition:@{}];
        
        //-- if this was chained in through buildScript, then delete the script.
        dispatch_sync(dispatch_get_main_queue(), ^{
            BMLResource* r = [BMLResource fetchByFullUuid:script.fullUuid];
            if ([r.tags containsString:kTempScriptTag] || !r) {
                isTempExecution = YES;
            }
        });
        
        [context.ml createResource:BMLResourceTypeWhizzmlExecution
                              name:context.info[@"name"]
                           options:@{ @"inputs" : arguments,
                                      @"tags" : isTempExecution ? @[kTempScriptTag] : @[],
                                      @"creation_defaults": [self optionsForCurrentContext:context]}
                              from:script
                        completion:^(id<BMLResource> resource, NSError* error) {
                            
                            self.executionUuid = resource.uuid;
                            [self arrayCompletionHandler:resultsFromExecution(resource)
                                                   error:error
                                              completion:completion];
                            
                            //-- if this was chained in through buildScript, then delete the script.
                            if (isTempExecution) {
                                
                                [context.ml deleteResource:script.type
                                                      uuid:script.uuid
                                                completion:nil];
                                [context.ml deleteResource:resource.type
                                                      uuid:resource.uuid
                                                completion:nil];
                            }
                        } uuid:^(BMLResourceFullUuid* fullUuid) {
                            self.executionUuid = [BMLResourceTypeIdentifier uuidFromFullUuid:fullUuid];
                            self.parentTask.executionUuid = self.executionUuid;
                        }];
    } else {
        [self genericCompletionHandler:nil
                                 error:error
                            completion:completion];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)inputResourceTypes {
    
//    NSAssert(NO, @"BMLWorkflowTaskCreateExecution inputResourceTypes SHOULD NOT BE HERE");
    return nil;
}
@end
