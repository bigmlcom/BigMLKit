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
#import "BMLResourceTypeIdentifier+BigML.h"

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
#pragma mark - Error handler
//////////////////////////////////////////////////////////////////////////////////////
- (void)handleError:(NSError*)error {
    
    NSLog(@"Context HandleError called!!!");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.workflow handleError:error];
    });
}

@end

