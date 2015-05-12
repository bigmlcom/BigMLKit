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

@import BigMLKitConnector;

BMLResourceType* kFileEntityType = nil;
BMLResourceType* kSourceEntityType = nil;
BMLResourceType* kDatasetEntityType = nil;
BMLResourceType* kModelEntityType = nil;
BMLResourceType* kClusterEntityType = nil;
BMLResourceType* kPredictionEntityType = nil;
BMLResourceType* kProjectEntityType = nil;

BMLResourceType* kModelTarget = nil;
BMLResourceType* kClusterTarget = nil;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLKitInitializer : NSObject
@end

@implementation BMLKitInitializer

//////////////////////////////////////////////////////////////////////////////////////
+ (void)load {
    
    kFileEntityType = [[BMLResourceType alloc] initWithRawType:BMLResourceRawTypeFile];
    kSourceEntityType = [[BMLResourceType alloc] initWithRawType:BMLResourceRawTypeSource];
    kDatasetEntityType = [[BMLResourceType alloc] initWithRawType:BMLResourceRawTypeDataset];
    kModelEntityType = [[BMLResourceType alloc] initWithRawType:BMLResourceRawTypeModel];
    kClusterEntityType = [[BMLResourceType alloc] initWithRawType:BMLResourceRawTypeCluster];
    kPredictionEntityType = [[BMLResourceType alloc] initWithRawType:BMLResourceRawTypePrediction];
    kProjectEntityType = [[BMLResourceType alloc] initWithRawType:BMLResourceRawTypeProject];
    
    kModelTarget = kModelEntityType;
    kClusterTarget = kClusterEntityType;
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
    
    return [self errorWithInfo:errorString code:code extendedInfo:nil];
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
