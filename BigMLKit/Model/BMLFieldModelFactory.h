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

@class BMLFieldModel;
@class BMLPopUpFieldModel;
@class BMLIndexedPopUpFieldModel;
@class BMLTextFormFieldModel;
@class BMLCheckBoxFieldModel;
@class BMLTokenFieldModel;
@class BMLDragDropFieldModel;
@class BMLScriptArgumentFieldModel;

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
@interface BMLFieldModelFactory : NSObject

+ (BMLFieldModel*)newSliderVal:(float)val
                           min:(float)min
                           max:(float)max
                      datatype:(NSString*)datatype
                         title:(NSString*)title
                    importance:(NSNumber*)importance;

+ (BMLFieldModel*)newRangeSliderLowVal:(float)lowVal
                                 upVal:(float)upVal
                                   min:(float)min
                                   max:(float)max
                              datatype:(NSString*)datatype
                                 title:(NSString*)title
                            importance:(NSNumber*)importance;

+ (BMLPopUpFieldModel*)newPopupValues:(NSArray*)values
                         currentValue:(NSString*)currentValue
                                title:(NSString*)title
                           importance:(NSNumber*)importance;

+ (BMLIndexedPopUpFieldModel*)newIndexedPopupValues:(NSArray*)values
                                       currentValue:(NSUInteger)currentValue
                                              title:(NSString*)title
                                         importance:(NSNumber*)importance;

+ (BMLPopUpFieldModel*)newRadioGroup:(NSArray*)values
                         currentValue:(NSString*)currentValue
                                title:(NSString*)title
                           importance:(NSNumber*)importance;

+ (BMLTextFormFieldModel*)newTextFieldTitle:(NSString*)title
                               currentValue:(NSString*)currentValue
                                 importance:(float)importance;

+ (BMLTextFormFieldModel*)newStepperFieldTitle:(NSString*)title
                                  currentValue:(NSUInteger)currentValue
                                    importance:(float)importance;

+ (BMLCheckBoxFieldModel*)newCheckBoxFieldTitle:(NSString*)title
                                     isSelected:(BOOL)isSelected
                                     importance:(float)importance;

+ (BMLTokenFieldModel*)newTokenFieldTitle:(NSString*)title
                                currentValue:(NSString*)currentValue
                                  importance:(float)importance;

+ (BMLDragDropFieldModel*)newDragAndDropTarget:(NSString*)title
                                    typeString:(NSString*)typeString;

+ (BMLDragDropFieldModel*)newDragAndDropTarget:(NSString*)title
                                          type:(BMLResourceTypeIdentifier*)type;

+ (BMLDragDropFieldModel*)newDragAndDropTarget:(NSString*)title
                                         types:(NSArray<BMLResourceTypeIdentifier*>*)types;

+ (BMLScriptArgumentFieldModel*)newScriptArgument:(NSString*)name
                                description:(NSString*)description
                                       type:(NSString*)type
                               defaultValue:(NSString*)defaultValue
                                         readOnly:(BOOL)readOnly;

+ (BMLFieldModel*)fieldModelForOptionNamed:(NSString*)optionName
                               description:(NSDictionary*)description;

@end
