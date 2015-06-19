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

#import "BMLResourceTypeIdentifier+BigML.h"
#import "BigMLApp-Swift.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLResourceTypeIdentifier (BigML)

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceTypeIdentifier*)typeFromTypeString:(NSString*)type {
    
    if ([type isEqualToString:[kFileEntityType stringValue]])
        return kFileEntityType;
    if ([type isEqualToString:[kSourceEntityType stringValue]])
        return kSourceEntityType;
    if ([type isEqualToString:[kDatasetEntityType stringValue]])
        return kDatasetEntityType;
    if ([type isEqualToString:[kModelEntityType stringValue]])
        return kModelEntityType;
    if ([type isEqualToString:[kClusterEntityType stringValue]])
        return kClusterEntityType;
    if ([type isEqualToString:[kPredictionEntityType stringValue]])
        return kPredictionEntityType;
    if ([type isEqualToString:[kAnomalyEntityType stringValue]])
        return kAnomalyEntityType;
    if ([type isEqualToString:[kEnsembleEntityType stringValue]])
        return kEnsembleEntityType;
    if ([type isEqualToString:[kProjectEntityType stringValue]])
        return kProjectEntityType;
    NSAssert(NO, @"Should not be here!");
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceTypeIdentifier*)typeFromFullUuid:(BMLResourceFullUuid*)fullUuid {
    
    NSString* type = [[fullUuid componentsSeparatedByString:@"/"] firstObject];
    return [self typeFromTypeString:type];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceUuid*)uuidFromFullUuid:(BMLResourceFullUuid*)fullUuid {

    NSMutableArray* parts = [[fullUuid componentsSeparatedByString:@"/"] mutableCopy];
    if ([parts count] == 2)
        return [parts lastObject];
    else if ([parts count] > 2) {
        return [[parts subarrayWithRange:NSMakeRange(1, [parts count]-1)] componentsJoinedByString:@"/"];
    }
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceFullUuid*)allProjectsPseudoFullUuid {
    return @"project/allProjectsPseudoUUID";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceUuid*)allProjectsPseudoUuid {
    return @"allProjectsPseudoUUID";
}

@end
