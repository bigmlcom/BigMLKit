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
    
    if ([type isEqualToString:[BMLResourceTypeFile stringValue]])
        return BMLResourceTypeFile;
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
    if ([type isEqualToString:[kEvaluationEntityType stringValue]])
        return kEvaluationEntityType;
    if ([type isEqualToString:[kScriptEntityType stringValue]])
        return kScriptEntityType;
    if ([type isEqualToString:[kSourceCodeEntityType stringValue]])
        return kSourceCodeEntityType;
    if ([type isEqualToString:[kExecutionEntityType stringValue]])
        return kExecutionEntityType;
    if ([type isEqualToString:[kProjectEntityType stringValue]])
        return kProjectEntityType;
    if ([type isEqualToString:[BMLResourceTypeConfiguration stringValue]])
        return BMLResourceTypeConfiguration;
    NSAssert(NO, @"Type Id: Should not be here! (%@)", type);
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

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceFullUuid*)modelScriptPseudoFullUuid {
    return @"sourcecode/modelScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceUuid*)modelScriptPseudoUuid {
    return @"modelScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceFullUuid*)clusterScriptPseudoFullUuid {
    return @"sourcecode/clusterScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceUuid*)clusterScriptPseudoUuid {
    return @"clusterScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceFullUuid*)anomalyScriptPseudoFullUuid {
    return @"sourcecode/anomalyScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceUuid*)anomalyScriptPseudoUuid {
    return @"anomalyScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceFullUuid*)multipleInputsScriptPseudoFullUuid {
    return @"sourcecode/multipleInputsScriptPseudoUuid";

}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceUuid*)multipleInputsScriptPseudoUuid {
    return @"multipleInputsScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceFullUuid*)evaluationScriptPseudoFullUuid {
    return @"sourcecode/evaluationScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceUuid*)evaluationScriptPseudoUuid {
    return @"evaluationScriptPseudoUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceFullUuid*)defaultConfigurationPseudoFullUuid {
    return @"configuration/defaultConfigurationPseudoFullUuid";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLResourceUuid*)defaultConfigurationPseudoUuid {
    return @"defaultConfigurationPseudoFullUuid";
}

@end

