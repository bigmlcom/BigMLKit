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

//#import "bigml-objc.h"

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
//BMLResourceTypeIdentifier* BMLResourceTypeConfiguration = nil;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLKitInitializer : NSObject
@end

@implementation BMLKitInitializer

//////////////////////////////////////////////////////////////////////////////////////
+ (void)load {
    
//    BMLResourceTypeFile = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeFile];
//    BMLResourceTypeSource = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeSource];
//    BMLResourceTypeDataset = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeDataset];
//    BMLResourceTypeModel = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeModel];
//    BMLResourceTypeCluster = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeCluster];
//    BMLResourceTypeAnomaly = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeAnomaly];
//    BMLResourceTypeEvaluation = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeEvaluation];
//    BMLResourceTypeWhizzmlScript = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeWhizzmlScript];
//    BMLResourceTypeWhizzmlSource = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeWhizzmlSource];
//    BMLResourceTypeWhizzmlExecution = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeWhizzmlExecution];
//    BMLResourceTypePrediction = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypePrediction];
//    BMLResourceTypeProject = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:BMLResourceTypeProject];
//    BMLResourceTypeConfiguration = [[BMLResourceTypeIdentifier alloc] initWithStringLiteral:@"configuration"];
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowType

@end
/*
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
*/