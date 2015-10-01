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

#ifndef BigML_BigML_h
#define BigML_BigML_h

@class BMLResourceTypeIdentifier;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowType : NSString
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
typedef NSString BMLResourceUuid;
typedef NSString BMLResourceFullUuid;

static NSString* const BMLExtendedErrorDescriptionKey = @"BMLExtendedErrorDescriptionKey";

extern BMLResourceTypeIdentifier* kFileEntityType;
extern BMLResourceTypeIdentifier* kSourceEntityType;
extern BMLResourceTypeIdentifier* kDatasetEntityType;
extern BMLResourceTypeIdentifier* kModelEntityType;
extern BMLResourceTypeIdentifier* kClusterEntityType;
extern BMLResourceTypeIdentifier* kAnomalyEntityType;
extern BMLResourceTypeIdentifier* kEvaluationEntityType;
extern BMLResourceTypeIdentifier* kScriptEntityType;
extern BMLResourceTypeIdentifier* kSourceCodeEntityType;
extern BMLResourceTypeIdentifier* kExecutionEntityType;
extern BMLResourceTypeIdentifier* kPredictionEntityType;
extern BMLResourceTypeIdentifier* kProjectEntityType;
extern BMLResourceTypeIdentifier* kConfigurationEntityType;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface NSError (BMLError)

+ (NSError*)errorWithInfo:(NSString*)errorString
                     code:(NSInteger)code;

+ (NSError*)errorWithInfo:(NSString*)errorString
                     code:(NSInteger)code
             extendedInfo:(NSDictionary*)extendedInfo;

@end

#define BMLLoginFailureError -50001
#define kOptionsDefaultCollection @"options"

#endif
