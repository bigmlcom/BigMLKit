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

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskConfigurationOption : NSObject

/**
 *  This property specifies that the field shall be only displayed and its value never sent
 *  to the server. This is useful to have, e.g., a pop up field that allows you to decide
 *  whether to include a subsets of fields or not.
 *  Defaults to NO.
 */
@property (nonatomic) BOOL showOnly;

/**
 *  This property specifies if the field value has to be used.
 *  This is useful both when doing predictions, to include/exclude specific field from them
 *  and when handling conditional configuration options.
 *  Defaults to YES.
 */
@property (nonatomic) BOOL isFieldIncluded;

/**
 *  Virtual method that should be mandatorily overriden to return the currentValue for the field.
 *  Take care of overriding keyPathsForValuesAffectingValueForKey so currentValue
 *  gets associated to the underlying property implementing it
 *
 *  @return The field's currentValue
 */
- (id)currentValue;

/**
 *  Virtual method that should be mandatorily overriden to set the currentValue for the field.
 *  This is only used when restoring field models from a persistent store, e.g., with configurations.
 *
 */
- (void)setCurrentValue:(id)value;

/**
 *  This method can be overridden to customize how this option's currentValue is to be displayed.
 *  Its default implementation will just return the empty string.
 *
 *  @return The field's currentValue
 */
- (NSString*)displayValue;

@end
