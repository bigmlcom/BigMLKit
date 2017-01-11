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

#import "BMLFieldModels.h"
#import <QuartzCore/CIFilter.h>

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary*)options {
    if (!_options)
        _options = [NSMutableDictionary new];
    return _options;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLSliderFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  @(_rawValue);
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(id)value {
    _rawValue = [value floatValue];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"currentValue"]) {
        [keyPaths addObject:@"rawValue"];
    }
    
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLRangeSliderFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  @[@(_lowerValue), @(_upperValue)];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(NSArray*)value {
    _lowerValue = [value[0] floatValue];
    _upperValue = [value[1] floatValue];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"currentValue"]) {
        [keyPaths addObject:@"lowerValue"];
        [keyPaths addObject:@"upperValue"];
    }
    
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLPopUpFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    if (_isList)
        return _values;
    else
        return _itemValue;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(id)value {
    _itemValue = value;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setValues:(NSArray*)values {
    
    if (values != _values) {
        _values = values;
        if (![values containsObject:self.itemValue])
            self.itemValue = values.firstObject;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"currentValue"]) {
        NSArray* affectingKeys = @[@"itemValue"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLIndexedPopUpFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  @(_itemIndex);
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(id)value {
    _itemIndex = [value intValue];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"currentValue"]) {
        NSArray* affectingKeys = @[@"itemIndex"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLRadioGroupFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {

    if (_currentButtonIndex >= 0 && _currentButtonIndex < _choices.count)
        return _choices[_currentButtonIndex];
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(id)value {
    
    self.currentButtonIndex = [_choices indexOfObject:value];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"currentValue"]) {
        NSArray* affectingKeys = @[@"currentButtonIndex"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLTextFormFieldModel

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLStepperFieldModel

- (NSNumber*)currentValue {
    return @(_currentValue.intValue);
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLDragDropFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)currentValue {
    if ((id)_fullUuid == [NSNull null])
        return nil;
    return _fullUuid;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(id)value {
    _fullUuid = value;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)displayValue {
    
    if (!self.resourceName)
        return _fullUuid;
    
    if ([BMLResourceTypeIdentifier typeFromFullUuid:_fullUuid] == BMLResourceTypeFile) {
        return [self.resourceName lastPathComponent];
    }
    return self.resourceName;
}

//////////////////////////////////////////////////////////////////////////////////////
- (CIImage*)sepiaImage:(CGImageRef)cgImage i:(float)i {

    CIImage* beginImage = [CIImage imageWithCGImage:cgImage];
    return [[CIFilter filterWithName:@"CISepiaTone" keysAndValues:
             kCIInputImageKey, beginImage,
             kCIInputIntensityKey, [NSNumber numberWithFloat:i], nil] valueForKey:@"outputImage"];
}

//////////////////////////////////////////////////////////////////////////////////////
- (CIImage*)falseColoredImage:(CGImageRef)cgImage
              foregroundColor:(NSColor*)foregroundColor
              backgroundColor:(NSColor*)backgroundColor {
    
    CIColor* fColor = [[CIColor alloc] initWithCGColor:foregroundColor.CGColor];
    CIColor* bColor = [[CIColor alloc] initWithCGColor:backgroundColor.CGColor];
    CIImage* beginImage = [CIImage imageWithCGImage:cgImage];
    return [[CIFilter filterWithName:@"CIFalseColor" keysAndValues:
             kCIInputImageKey, beginImage,
             @"inputColor0", fColor, @"inputColor1", bColor, nil] valueForKey:@"outputImage"];
}

//////////////////////////////////////////////////////////////////////////////////////
- (CIImage*)grayImage:(CGImageRef)cgImage b:(float)b c:(float)c s:(float)s {
    
    CIImage* beginImage = [CIImage imageWithCGImage:cgImage];
    CIImage* blackAndWhite = [[CIFilter filterWithName:@"CIColorControls" keysAndValues:
                               kCIInputImageKey, beginImage,
                               @"inputBrightness", [NSNumber numberWithFloat:b],
                               @"inputContrast", [NSNumber numberWithFloat:c],
                               @"inputSaturation", [NSNumber numberWithFloat:s], nil] valueForKey:@"outputImage"];
    return [[CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:
             kCIInputImageKey, blackAndWhite,
             @"inputEV", [NSNumber numberWithFloat:0.5], nil] valueForKey:@"outputImage"];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSImage*)imageWithCIImage:(CIImage*)ciImage size:(NSSize)size {
    
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithCIImage:ciImage];
    CGImageRef cgImage = CGImageCreateCopy(rep.CGImage);
    NSImage* image = [[NSImage alloc] initWithCGImage:cgImage size:size];
    CGImageRelease(cgImage);
    return image;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSImage*)image {

    NSImage* baseImage = [NSImage imageNamed:[NSString stringWithFormat:@"btnCreate%@",
                                              [[_resourceTypes[_currentResourceType] stringValue]
                                               capitalizedString]]];
    if (!baseImage)
        return nil;
    
    CGImageRef cgImage = [baseImage CGImageForProposedRect:NULL context:NULL hints:nil];

    if (self.dragDropStatus == BMLDragDropStatusNone || self.dragDropStatus == BMLDragDropStatusExited) {
        
        return [self imageWithCIImage:[self grayImage:cgImage b:0.0 c:1.0 s:0.0] size:baseImage.size];
        
    } else if (self.dragDropStatus == BMLDragDropStatusStarted) {

        return [self imageWithCIImage:[self falseColoredImage:cgImage
                                              foregroundColor:[BMLAppCore BMLGreenColor]
                                              backgroundColor:[BMLAppCore BMLGreenColor]]
                                 size:baseImage.size];

    } else if (self.dragDropStatus == BMLDragDropStatusDenied) {

        return [self imageWithCIImage:[self falseColoredImage:cgImage
                                              foregroundColor:[NSColor redColor]
                                              backgroundColor:[NSColor redColor]]
                                 size:baseImage.size];
    }
    return baseImage;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray* affectingKeys = nil;
    if ([key isEqualToString:@"image"]) {
        affectingKeys = @[@"dragDropStatus"];
        affectingKeys = @[@"currentResourceType"];
        affectingKeys = @[@"fullUuid"];
    }
    if ([key isEqualToString:@"currentValue"]) {
        affectingKeys = @[@"fullUuid"];
    }
    if ([key isEqualToString:@"displayValue"]) {
        affectingKeys = @[@"resourceName"];
        affectingKeys = @[@"fullUuid"];
    }
    return [keyPaths setByAddingObjectsFromArray:affectingKeys];
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLCheckBoxFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
 
    return [NSNumber numberWithBool:self.isSelected];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(id)value {
    self.isSelected = [value boolValue];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)selectedState {
    
    return _isSelected ? NSOnState : NSOffState;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"state"]) {
        NSArray* affectingKeys = @[@"isSelected"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    if ([key isEqualToString:@"currentValue"]) {
        NSArray* affectingKeys = @[@"isSelected"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLTokenFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  [_rawValue componentsSeparatedByString:@","];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(NSArray*)value {
    _rawValue = [value componentsJoinedByString:@","];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"currentValue"]) {
        [keyPaths addObject:@"rawValue"];
    }
    
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLListFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)currentValue {
    
    return _currentValue ?: @[];
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLMapFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)currentValue {
    
    return _currentValue ?: @{};
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLScriptArgumentFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    return self.name;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(id)value {
    self.name = value;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setName:(NSString*)name {
    [super setName:name];
    self.title = name;
}

@end
