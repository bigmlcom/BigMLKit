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

#import "BMLWorkflowTaskConfigurationOption.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskConfigurationOption

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    NSAssert(NO, @"Should not be here!!");
    return  nil;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)displayValue {
    
    return @"";
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"displayValue"]) {
        [keyPaths addObject:@"currentValue"];
    }
    
    return keyPaths;
}

@end
