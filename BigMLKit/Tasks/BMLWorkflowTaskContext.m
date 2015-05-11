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

#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflow.h"
#import "BMLResourceUtils.h"
#import "BigMLKit-Swift.h"

#define kMonitoringPeriod 0.25

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskContext ()

@property (nonatomic, strong) BMLConnector* ml;
@property (nonatomic, weak) BMLWorkflow* workflow;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskContext

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    NSAssert(NO, @"Improper BMLWorkflowTaskContext API usage. Use either initWithWorkflow: or initWithWorkflow:context:");
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithWorkflow:(BMLWorkflow*)workflow
                       connector:(BMLConnector*)connector {
    
    if (self = [super init]) {
        
        _workflow = workflow;
        _ml = connector;
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary*)info {
    
    if (!_info) {
        _info = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return _info;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSError*)errorWithInfo:(NSString*)errorString
                     code:(NSInteger)code
                 response:(NSDictionary*)response {
    
    return [NSError errorWithInfo:errorString
                             code:code
                     extendedInfo:response];
}
/*
//////////////////////////////////////////////////////////////////////////////////////
- (void)monitorStepWithBlock:(NSDictionary*(^)(void))block
                     success:(void(^)(NSDictionary* result))success
                       error:(void(^)(void))error {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSDictionary* resource = nil;
        if (block)
            resource = block();
        
        if (!resource) {
            if (error) error();
            [self handleError:[self errorWithInfo:@"Unknown Error" code:0 response:nil]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BMLWorkflowTaskStatus status = (BMLWorkflowTaskStatus)[resource[@"status"][@"code"] intValue];
            NSLog(@"Monitoring operation: %@ (%d)", resource[@"status"][@"message"], status);
            
            if (status < BMLWorkflowTaskWaiting) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) error();
                    [self handleError:[self errorWithInfo:resource[@"status"][@"message"]
                                                     code:status
                                                 response:nil]];
                });
                
            } else if (status < BMLWorkflowTaskEnded) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kMonitoringPeriod * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self monitorStepWithBlock:block success:success error:error];
                });
                
                if (self.workflow.currentTask.bmlStatus != status)
                    self.workflow.currentTask.bmlStatus = status;
                self.workflow.currentTask.progress = [resource[@"status"][@"progress"] floatValue];
                
            }  else if (status == BMLWorkflowTaskEnded) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success)
                        success(resource);
                    self.workflow.currentTask.bmlStatus = status;
                });
            }
        });
    });
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)monitorStepWithBlock:(NSDictionary*(^)(void))block {
    
    [self monitorStepWithBlock:block success:NULL error:NULL];
}

#pragma mark - ML4iOS Delegate
//////////////////////////////////////////////////////////////////////////////////////
- (void)dataSourceCreated:(NSDictionary*)dataSource statusCode:(NSInteger)code {
    
    NSString* datasourceId = [BMLResourceUtils uuidFromFullUuid:dataSource[@"resource"]];
    if (!datasourceId) {
        [self handleError:[self errorWithInfo:@"Datasource could not be created."
                                         code:code
                                     response:dataSource]];
    } else {
        self.info[kDataSourceId] = datasourceId;
        [self monitorStepWithBlock:^{
//            NSInteger status = 0;
            return (NSDictionary*)nil; //[self.ml getSourceWithIdSync:datasourceId statusCode:&status];
        } success:^(NSDictionary* result) {
            self.info[kDataSourceDefinition] = result;
        } error:NULL];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)dataSetCreated:(NSDictionary*)dataSet statusCode:(NSInteger)code {
    
    NSString* datasetId = [BMLResourceUtils uuidFromFullUuid:dataSet[@"resource"]];
    if (!datasetId) {
        [self handleError:[self errorWithInfo:@"Dataset could not be created."
                                         code:code
                                     response:dataSet]];
    } else {
        self.info[kDataSetId] = datasetId;
        [self monitorStepWithBlock:^{
            NSInteger status = 0;
            return [self.ml getResource:@"source" uuid:datasetId completion:^(id<BMLResource> result, NSError * error) {
                if (!error)
                    self.info[kDataSetDefinition] = result;
            }];
        }];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)modelCreated:(NSDictionary*)model statusCode:(NSInteger)code {
    
    NSString* modelId = [BMLResourceUtils uuidFromFullUuid:model[@"resource"]];
    if (!modelId) {
        [self handleError:[self errorWithInfo:@"Model could not be created."
                                         code:code
                                     response:model]];
    } else {
        
        self.info[kModelId] = modelId;
        [self monitorStepWithBlock:^{
            NSInteger status = 0;
            return [self.ml getModelWithIdSync:modelId statusCode:&status];
        } success:^(NSDictionary* result) {
            self.info[kModelDefinition] = result;
        } error:NULL];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)clusterCreated:(NSDictionary*)cluster statusCode:(NSInteger)code {
    
    NSString* clusterId = [BMLResourceUtils uuidFromFullUuid:cluster[@"resource"]];
    if (!clusterId) {
        [self handleError:[self errorWithInfo:@"Cluster could not be created."
                                         code:code
                                     response:cluster]];
    } else {
        
        self.info[kClusterId] = clusterId;
        [self monitorStepWithBlock:^{
            NSInteger status = 0;
            return [self.ml getClusterWithIdSync:clusterId statusCode:&status];
        } success:^(NSDictionary* result) {
            self.info[kClusterDefinition] = result;
        } error:NULL];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)predictionCreated:(NSDictionary*)prediction statusCode:(NSInteger)code {
    
}

//////////////////////////////////////////////////////////////////////////////////////
-(void)modelRetrieved:(NSDictionary*)model statusCode:(NSInteger)code {
    
    self.info[kModelDefinition] = model;
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.workflow.currentTask.bmlStatus = BMLWorkflowTaskEnded;
    });
}

//////////////////////////////////////////////////////////////////////////////////////
-(void)clusterRetrieved:(NSDictionary*)cluster statusCode:(NSInteger)code {
    
    self.info[kClusterDefinition] = cluster;
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.workflow.currentTask.bmlStatus = BMLWorkflowTaskEnded;
    });
}
*/
#pragma mark - Error handler
//////////////////////////////////////////////////////////////////////////////////////
- (void)handleError:(NSError*)error {
    
    NSLog(@"Context HandleError called!!!");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.workflow handleError:error];
    });
}

@end

