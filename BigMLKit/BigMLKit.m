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

#import <Foundation/Foundation.h>
#import "BigMLKit.h"

#import "BigMLApp-Swift.h"

BMLResourceTypeIdentifier* kFileEntityType = nil;
BMLResourceTypeIdentifier* kSourceEntityType = nil;
BMLResourceTypeIdentifier* kDatasetEntityType = nil;
BMLResourceTypeIdentifier* kModelEntityType = nil;
BMLResourceTypeIdentifier* kClusterEntityType = nil;
BMLResourceTypeIdentifier* kAnomalyEntityType = nil;
BMLResourceTypeIdentifier* kEvaluationEntityType = nil;
BMLResourceTypeIdentifier* kScriptEntityType = nil;
BMLResourceTypeIdentifier* kExecutionEntityType = nil;
BMLResourceTypeIdentifier* kPredictionEntityType = nil;
BMLResourceTypeIdentifier* kProjectEntityType = nil;
BMLResourceTypeIdentifier* kConfigurationEntityType = nil;

BMLResourceTypeIdentifier* kModelTarget = nil;
BMLResourceTypeIdentifier* kClusterTarget = nil;
BMLResourceTypeIdentifier* kAnomalyTarget = nil;
BMLResourceTypeIdentifier* kEvaluationTarget = nil;
BMLResourceTypeIdentifier* kWhizzMLTarget = nil;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLKitInitializer : NSObject
@end

@implementation BMLKitInitializer

//////////////////////////////////////////////////////////////////////////////////////
+ (void)load {
    
    kFileEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeFile];
    kSourceEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeSource];
    kDatasetEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeDataset];
    kModelEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeModel];
    kClusterEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeCluster];
    kAnomalyEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeAnomaly];
    kEvaluationEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeEvaluation];
    kScriptEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeWhizzmlScript];
    kExecutionEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeWhizzmlExecution];
    kPredictionEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypePrediction];
    kProjectEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeProject];
    kConfigurationEntityType = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeConfiguration];
    
    kModelTarget = kModelEntityType;
    kClusterTarget = kClusterEntityType;
    kAnomalyTarget = kAnomalyEntityType;
    kEvaluationTarget = kEvaluationEntityType;
    kWhizzMLTarget = kScriptEntityType;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowType

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation NSError (BMLError)

//////////////////////////////////////////////////////////////////////////////////////
+ (NSError*)errorWithInfo:(NSString*)errorString code:(NSInteger)code {
    
    return [self errorWithInfo:errorString code:code extendedInfo:@{}];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSError*)errorWithInfo:(NSString*)errorString
                     code:(NSInteger)code
             extendedInfo:(NSDictionary*)extendedInfo {
    
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey:errorString,
                                BMLExtendedErrorDescriptionKey:extendedInfo?: @{} };
    
    return [NSError errorWithDomain:@"com.bigml.BigML"
                               code:code
                           userInfo:userInfo];
}

@end
