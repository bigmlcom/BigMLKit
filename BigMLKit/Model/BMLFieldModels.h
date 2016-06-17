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

#import "BMLWorkflowTask.h"
#import "BMLWorkflowTaskConfigurationOption.h"

static NSString* const kBMLScriptArgumentCellNeedsDisplay = @"kBMLScriptArgumentCellNeedsDisplay";

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
typedef enum BMLDragDropStatus {
    BMLDragDropStatusNone,
    BMLDragDropStatusStarted,
    BMLDragDropStatusDenied,
    BMLDragDropStatusPerformed,
    BMLDragDropStatusExited
} BMLDragDropStatus;

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLFieldModel : BMLWorkflowTaskConfigurationOption

/**
 *  This property specifies the name of the input.
 */
@property (nonatomic, copy) NSString* name;

/**
 *  This property specifies the title that should be displayed in the UI for the input.
 */
@property (nonatomic, copy) NSString* title;

/**
 *  This property provides a description text for the input.
 */
@property (nonatomic, copy) NSString* fieldDescription;

/**
 *  This property specifies the importance that this input field has in predictions.
 */
@property (nonatomic) float importance;

/**
 *  This property specifies the name of a related property that determines whether the field
 *  should be displayed or not. The field is only displayed if that property has the value
 *  specified by showOnValue.
 *  Defaults to nil.
 */
@property (nonatomic, strong) NSString* showOnProperty;

/**
 *  This property specifies the value that the showOnProperty shall have for the field
 *  to be displayed. The field is only displayed if that property has the value
 *  specified by showOnValue.
 *  Defaults to nil.
 */
@property (nonatomic, strong) NSString* showOnValue;

/**
 *  This property represents the current drag&drop status for the control.
 *  Defaults to BMLDragDropStatusNone.
 */
@property (nonatomic) BMLDragDropStatus dragDropStatus;


@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLSliderFieldModel : BMLFieldModel

@property (nonatomic) float rawValue;
@property (nonatomic) float min;
@property (nonatomic) float max;
@property (nonatomic) int inc;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLRangeSliderFieldModel : BMLFieldModel

@property (nonatomic) float lowerValue;
@property (nonatomic) float upperValue;
@property (nonatomic) float min;
@property (nonatomic) float max;
@property (nonatomic) int inc;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLPopUpFieldModel : BMLFieldModel

@property (nonatomic, copy) NSString* itemValue;
@property (nonatomic, strong) NSArray* values;
@property (nonatomic) BOOL isEditable;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLIndexedPopUpFieldModel : BMLPopUpFieldModel

@property (nonatomic) NSUInteger itemIndex;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLRadioGroupFieldModel : BMLFieldModel

@property (nonatomic, copy) NSString* currentValue;
@property (nonatomic, strong) NSArray* choices;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLTextFormFieldModel : BMLFieldModel

@property (nonatomic, copy) NSString* currentValue;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLStepperFieldModel : BMLFieldModel

@property (nonatomic, copy) NSNumber* currentValue;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLCheckBoxFieldModel : BMLFieldModel

@property (nonatomic, copy) NSNumber* currentValue;
@property (nonatomic) BOOL isSelected; //-- rawValue

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLTokenFieldModel : BMLFieldModel

@property (nonatomic, copy) NSString* rawValue;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLDragDropFieldModel : BMLFieldModel

@property (nonatomic, strong) NSArray<BMLResourceTypeIdentifier*>* resourceTypes;
@property (nonatomic) NSUInteger currentResourceType;
@property (nonatomic, copy) NSString* resourceName;
@property (nonatomic, copy) NSString* fullUuid;
@property (nonatomic, readonly) NSImage* image;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLScriptArgumentFieldModel : BMLFieldModel

@property (nonatomic, copy) NSString* defaultValue;
@property (nonatomic, strong) BMLFieldModel* typeModel;
@property (nonatomic) BOOL isFieldExpanded;
@property (nonatomic) BOOL isFieldReadOnly;

@end
