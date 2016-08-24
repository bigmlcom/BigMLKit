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

#import "BMLFieldModelFactory.h"
#import "BMLFieldModels.h"

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
@implementation BMLFieldModelFactory

/////////////////////////////////////////////////////////////////////////////////
+ (BMLFieldModel*)newSliderVal:(float)val
                           min:(float)min
                           max:(float)max
                      datatype:(NSString*)datatype
                         title:(NSString*)title
                    importance:(NSNumber*)importance {
    
    BMLFieldModel* fieldModel = nil;
    
    if ([datatype isEqualToString:@"month"]) {
        
        BMLPopUpFieldModel* popValue = [BMLPopUpFieldModel new];
        popValue.values = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
        popValue.isFieldIncluded = YES;
        popValue.title = title;
        popValue.name = title;
        popValue.importance = [importance floatValue];
        
        fieldModel = popValue;
        
    } else if ([datatype isEqualToString:@"day-of-week"]) {
        
        BMLPopUpFieldModel* popValue = [BMLPopUpFieldModel new];
        popValue.values = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
        popValue.isFieldIncluded = YES;
        popValue.title = title;
        popValue.name = title;
        popValue.importance = [importance floatValue];
        
        fieldModel = popValue;
        
    } else {
        
        BMLSliderFieldModel* sliderValue = [BMLSliderFieldModel new];
        sliderValue.min = min;
        sliderValue.max = max;
        sliderValue.rawValue = val;
        
        sliderValue.isFieldIncluded = YES;
        sliderValue.title = title;
        sliderValue.name = title;
        sliderValue.importance = [importance floatValue];
        
        fieldModel = sliderValue;
        
        if ([datatype isEqualToString:@"double"]) {
            
        } else if ([datatype rangeOfString:@"int"].location == 0) {
            
            sliderValue.inc = 1;
            
        } else if ([datatype isEqualToString:@"year"] ||
                   [datatype isEqualToString:@"month"] ||
                   [datatype isEqualToString:@"day-of-month"]) {
            
            sliderValue.inc = 1;
            
        }
    }
    
    return fieldModel;
}

/////////////////////////////////////////////////////////////////////////////////
+ (BMLFieldModel*)newRangeSliderLowVal:(float)lowVal
                                 upVal:(float)upVal
                                   min:(float)min
                                   max:(float)max
                              datatype:(NSString*)datatype
                                 title:(NSString*)title
                            importance:(NSNumber*)importance {
    
    BMLFieldModel* fieldModel = nil;
    
    BMLRangeSliderFieldModel* sliderValue = [BMLRangeSliderFieldModel new];
    sliderValue.min = min;
    sliderValue.max = max;
    sliderValue.lowerValue = lowVal;
    sliderValue.upperValue = upVal;
    
    sliderValue.isFieldIncluded = YES;
    sliderValue.title = title;
    sliderValue.name = title;

    sliderValue.importance = [importance floatValue];
    
    fieldModel = sliderValue;
    
    if ([datatype rangeOfString:@"int_range"].location == 0) {
        sliderValue.inc = 1;
    }
    
    return fieldModel;
}

/////////////////////////////////////////////////////////////////////////////////
+ (BMLPopUpFieldModel*)newPopupValues:(NSArray*)values
                         currentValue:(NSString*)currentValue
                                title:(NSString*)title
                             editable:(BOOL)editable
                                 list:(BOOL)list
                           importance:(NSNumber*)importance {
    
    BMLPopUpFieldModel* popup = [BMLPopUpFieldModel new];
    
    if ([currentValue isKindOfClass:[NSArray class]]) {
        values = (NSArray*)currentValue;
    } else if (currentValue &&
        [values indexOfObject:currentValue] == NSNotFound &&
        (id)currentValue != [NSNull null]) {
        values = [values arrayByAddingObject:currentValue];
    } else {
        currentValue = @"";
    }
    
    NSUInteger index = 0;
    if (currentValue) {
        index = [values indexOfObject:currentValue];
        if (index == NSNotFound)
            index = 0;
    }
    if (index < values.count)
        popup.itemValue = values[index];

    popup.isFieldIncluded = YES;
    popup.title = title;
    popup.name = title;
    popup.importance = [importance floatValue];
    popup.values = values;
    popup.isEditable = editable;
    popup.isList = list;
    
    return popup;
}

/////////////////////////////////////////////////////////////////////////////////
+ (BMLIndexedPopUpFieldModel*)newIndexedPopupValues:(NSArray*)values
                                       currentValue:(NSUInteger)currentValue
                                              title:(NSString*)title
                                         importance:(NSNumber*)importance {
    
    BMLIndexedPopUpFieldModel* popup = [BMLIndexedPopUpFieldModel new];
    if (currentValue < NSNotFound && currentValue < [values count])
        popup.itemIndex = currentValue;
    else
        popup.itemIndex = 0;
    popup.isFieldIncluded = YES;
    popup.title = title;
    popup.name = title;
    popup.importance = [importance floatValue];
    popup.values = values;
    
    return popup;
}

/////////////////////////////////////////////////////////////////////////////////
+ (BMLRadioGroupFieldModel*)newRadioGroup:(NSArray*)values
                        currentValue:(NSString*)currentValue
                               title:(NSString*)title
                          importance:(NSNumber*)importance {
 
    if (![currentValue isKindOfClass:[NSString class]]) currentValue = @"";

    BMLRadioGroupFieldModel* radioGroup = [BMLRadioGroupFieldModel new];
    
    radioGroup.isFieldIncluded = YES;
    radioGroup.title = title;
    radioGroup.name = title;
    radioGroup.importance = [importance floatValue];
    radioGroup.choices = values;
    
    return radioGroup;
}

/////////////////////////////////////////////////////////////////////////////////
+ (BMLTextFormFieldModel*)newTextFieldTitle:(NSString*)title
                               currentValue:(NSString*)currentValue
                                 importance:(float)importance {
    
    if (![currentValue isKindOfClass:[NSString class]]) currentValue = @"";
    
    BMLTextFormFieldModel* textField = [BMLTextFormFieldModel new];
    textField.isFieldIncluded = YES;
    textField.title = title;
    textField.name = title;
    textField.importance = importance;
    textField.currentValue = currentValue;
    
    return textField;
}

/////////////////////////////////////////////////////////////////////////////////
+ (BMLCheckBoxFieldModel*)newCheckBoxFieldTitle:(NSString*)title
                                     isSelected:(BOOL)isSelected
                                     importance:(float)importance {
    
    BMLCheckBoxFieldModel* model = [BMLCheckBoxFieldModel new];
    model.isSelected = isSelected;
    model.title = title;
    model.name = title;
    model.importance = importance;
    
    return model;
}

/////////////////////////////////////////////////////////////////////////////////
+ (BMLTokenFieldModel*)newTokenFieldTitle:(NSString*)title
                             currentValue:(NSString*)currentValue
                               importance:(float)importance {
    
    if (![currentValue isKindOfClass:[NSString class]]) currentValue = @"";

    BMLTokenFieldModel* tokenField = [BMLTokenFieldModel new];
    tokenField.isFieldIncluded = YES;
    tokenField.title = title;
    tokenField.name = title;
    tokenField.importance = importance;
    tokenField.rawValue = currentValue;
    
    return tokenField;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLMapFieldModel*)newMapFieldTitle:(NSString*)title
                         currentValue:(NSDictionary*)currentValue {
    
    BMLMapFieldModel* mapModel = [BMLMapFieldModel new];
    mapModel.title = title;
    mapModel.currentValue = currentValue;

    return mapModel;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLStepperFieldModel*)newStepperFieldTitle:(NSString*)title
                                  currentValue:(NSUInteger)currentValue
                                    importance:(float)importance {

    BMLStepperFieldModel* stepperModel = [BMLStepperFieldModel new];
    stepperModel.isFieldIncluded = YES;
    stepperModel.title = title;
    stepperModel.name = title;
    stepperModel.importance = importance;
    stepperModel.currentValue = @(currentValue);
    
    return stepperModel;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLDragDropFieldModel*)newDragAndDropTarget:(NSString*)title
                                         types:(NSArray<BMLResourceTypeIdentifier*>*)types {

    BMLDragDropFieldModel* targetModel = [BMLDragDropFieldModel new];
    targetModel.title = title;
    targetModel.name = title;
    targetModel.resourceTypes = types;
    targetModel.importance = 1.0;
    targetModel.isFieldIncluded = NO;
    return targetModel;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLDragDropFieldModel*)newDragAndDropTarget:(NSString*)title
                                          type:(BMLResourceTypeIdentifier*)type {
    
    if (!type) return nil;
    return [self newDragAndDropTarget:title
                                types:@[type]];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLDragDropFieldModel*)newDragAndDropTarget:(NSString*)title
                                    typeString:(NSString*)typeString {
   
    BMLDragDropFieldModel* fieldModel = nil;
    NSRegularExpression* regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"^([a-z]+)-id(\\[([^]]*)\\])?"
                                  options:0
                                  error:nil];
    
    NSArray* matches = [regex matchesInString:typeString
                                      options:0
                                        range:NSMakeRange(0, [typeString length])];
    
    NSTextCheckingResult* match = [matches firstObject];
    NSAssert(match, @"Wrong type passed to newDragAndDropTarget: %@", typeString);
    if (match) {
        NSString* type = [typeString substringWithRange:[match rangeAtIndex:1]];
        NSArray* subtypes = nil;
        if ([match rangeAtIndex:3].location != NSNotFound) {
            subtypes = [[typeString substringWithRange:[match rangeAtIndex:3]]
                        componentsSeparatedByString:@"|"];
            
            NSMutableArray<BMLResourceTypeIdentifier*>* types = [NSMutableArray new];
            for (NSString* t in subtypes) {
                BMLResourceTypeIdentifier* type =
                [BMLResourceTypeIdentifier typeFromTypeString:t];
                if (![types containsObject:type])
                    [types addObject:type];
            }
            
            fieldModel = [BMLFieldModelFactory
                          newDragAndDropTarget:title
                          types:types];
        } else {
            
            fieldModel = [BMLFieldModelFactory
                          newDragAndDropTarget:title
                          type:[BMLResourceTypeIdentifier typeFromTypeString:type]];
        }
    } else {
        NSLog(@"Wrong type passed to newDragAndDropTarget: %@", typeString);
    }
    return fieldModel;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLScriptArgumentFieldModel*)newScriptArgument:(NSString*)name
                                      description:(NSString*)description
                                             type:(NSString*)type
                                     defaultValue:(NSString*)defaultValue
                                         readOnly:(BOOL)readOnly {
    
    BMLScriptArgumentFieldModel* scriptModel = [BMLScriptArgumentFieldModel new];
    scriptModel.name = name;
    scriptModel.title = name;
    scriptModel.typeModel =
    [BMLFieldModelFactory newPopupValues:@[@"string",
                                           @"number",
                                           @"boolean",
                                           @"list",
                                           @"list-of-string",
                                           @"list-of-integer",
                                           @"list-of-number",
                                           @"list-of-boolean",
                                           @"objective-id",
                                           @"resource-id",
                                           @"source-id",
                                           @"dataset-id",
                                           @"model-id",
                                           @"ensemble-id",
                                           @"prediction-id",
//                                           @"batchprediction-id",
//                                           @"evaluation-id",
                                           @"anomaly-id",
//                                           @"anomalyscore-id",
                                           @"batchanomalyscore-id",
                                           @"cluster-id",
                                           @"centroid-id",
//                                           @"batchcentroid-id",
//                                           @"correlation-id",
//                                           @"statisticaltest-id",
//                                           @"logisticregression-id",
//                                           @"association-id",
                                           @"execution-id",
                                           @"library-id",
                                           @"script-id"]
                            currentValue:type
                                   title:@"type"
                                editable:NO
                                    list:NO
                              importance:@1.0];
    scriptModel.fieldDescription = description;
    scriptModel.isFieldIncluded = NO;
    scriptModel.isFieldReadOnly = readOnly;
    return scriptModel;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLFieldModel*)fieldModelForOptionNamed:(NSString*)optionName description:(NSDictionary*)description {
    
    BMLFieldModel* fieldModel = nil;
    if ([description[@"type"] isEqualToString:@"double"] || [description[@"type"] isEqualToString:@"int"]) {
        
        float min = [description[@"min"] floatValue];
        float max = [description[@"max"] floatValue];
        float val = description[@"default"] ? [description[@"default"] floatValue] : (max + min) / 2;
        
        fieldModel = [BMLFieldModelFactory newSliderVal:val
                                                    min:min
                                                    max:max
                                               datatype:description[@"type"]
                                                  title:optionName
                                             importance:nil];
        
    } else if ([description[@"type"] isEqualToString:@"int_range"]) {
        
        float min = [description[@"min"] floatValue];
        float max = [description[@"max"] floatValue];
        float loVal = description[@"default_min"] ? [description[@"default_min"] floatValue] : min;
        float hiVal = description[@"default_max"] ? [description[@"default_max"] floatValue] : max;
        
        fieldModel = [BMLFieldModelFactory newRangeSliderLowVal:loVal
                                                          upVal:hiVal
                                                            min:min
                                                            max:max
                                                       datatype:description[@"type"]
                                                          title:optionName
                                                     importance:nil];
        
    } else if ([description[@"type"] isEqualToString:@"categorical"]) {
        
        NSMutableArray* categories = [NSMutableArray array];
        for (NSString* categoryName in description[@"categories"])
            [categories addObject:categoryName];
        
        fieldModel = [BMLFieldModelFactory newPopupValues:categories
                                             currentValue:description[@"default"]
                                                    title:optionName
                                                 editable:NO
                                                     list:NO
                                               importance:nil];
        
    } else if ([description[@"type"] isEqualToString:@"indexed"]) {
        
        NSMutableArray* categories = [NSMutableArray array];
        for (NSString* categoryName in description[@"categories"])
            [categories addObject:categoryName];
        
        fieldModel = [BMLFieldModelFactory newIndexedPopupValues:categories
                                                    currentValue:[description[@"default"] intValue]
                                                           title:optionName
                                                      importance:nil];
        
        //    } else if ([description[@"type"] isEqualToString:@"fields"]) {
        //
        //        NSLog(@"RES: %@", _resource);
        //        NSMutableArray* categories = [NSMutableArray array];
        //        for (NSString* categoryName in description[@"categories"])
        //            [categories addObject:categoryName];
        //
        //        fieldModel = [BMLFieldModelFactory newPopupValues:categories
        //                                             currentValue:nil
        //                                                    title:optionName
        //                                               importance:nil];
        //        selectedState
    } else if ([description[@"type"] isEqualToString:@"choice"]) {
        
        fieldModel = [BMLFieldModelFactory newRadioGroup:description[@"choices"]
                                            currentValue:nil
                                                   title:optionName
                                              importance:nil];
        
    } else if ([description[@"type"] isEqualToString:@"text"]) {
        
        fieldModel = [BMLFieldModelFactory newTextFieldTitle:optionName
                                                currentValue:description[@"default"]?:@""
                                                  importance:0.0];
        
    } else if ([description[@"type"] isEqualToString:@"bool"]) {
        
        fieldModel = [BMLFieldModelFactory newCheckBoxFieldTitle:optionName
                                                      isSelected:[description[@"default"] boolValue]
                                                      importance:0.0];
        
    } else if ([description[@"type"] isEqualToString:@"string_array"]) {
        
        fieldModel = [BMLFieldModelFactory newTokenFieldTitle:optionName
                                                 currentValue:description[@"default"]
                                                   importance:0.0];
        
    } else {
        
        NSLog(@"UNK FIELD: %@ (%@)", description, description[@"type"]);
    }
    
    if (fieldModel) {
        if (description[@"showOn"]) {
            
            NSArray* showOnTerms =
            [description[@"showOn"] componentsSeparatedByCharactersInSet:
             [NSCharacterSet characterSetWithCharactersInString:@"="]];
            
            if ([showOnTerms count] == 2) {
                fieldModel.showOnProperty = showOnTerms[0];
                fieldModel.showOnValue = showOnTerms[1];
            }
        }
        if (description[@"showOnly"]) {
            fieldModel.showOnly = [description[@"showOnly"] boolValue];
        }
    }

    return fieldModel;
}

@end
