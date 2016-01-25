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
#import "BMLResourceTypeIdentifier.h"

//#import "BigMLApp-Swift.h"

//BMLResourceTypeIdentifier* BMLResourceTypeFile = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeSource = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeDataset = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeModel = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeCluster = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeAnomaly = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeEvaluation = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeWhizzmlScript = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeWhizzmlSource = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeWhizzmlExecution = nil;
//BMLResourceTypeIdentifier* BMLResourceTypePrediction = nil;
//BMLResourceTypeIdentifier* BMLResourceTypeProject = nil;
BMLResourceTypeIdentifier* BMLResourceTypeConfiguration = nil;

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
    
//    BMLResourceTypeFile = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeFile];
//    BMLResourceTypeSource = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeSource];
//    BMLResourceTypeDataset = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeDataset];
//    BMLResourceTypeModel = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeModel];
//    BMLResourceTypeCluster = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeCluster];
//    BMLResourceTypeAnomaly = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeAnomaly];
//    BMLResourceTypeEvaluation = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeEvaluation];
//    BMLResourceTypeWhizzmlScript = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeWhizzmlScript];
//    BMLResourceTypeWhizzmlSource = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeWhizzmlSource];
//    BMLResourceTypeWhizzmlExecution = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeWhizzmlExecution];
//    BMLResourceTypePrediction = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypePrediction];
//    BMLResourceTypeProject = [[BMLResourceTypeIdentifier alloc] initWithRawType:BMLResourceTypeProject];
    BMLResourceTypeConfiguration = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:@"configuration"];
    
    kModelTarget = BMLResourceTypeModel;
    kClusterTarget = BMLResourceTypeCluster;
    kAnomalyTarget = BMLResourceTypeAnomaly;
    kEvaluationTarget = BMLResourceTypeEvaluation;
    kWhizzMLTarget = BMLResourceTypeWhizzmlSource;
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
