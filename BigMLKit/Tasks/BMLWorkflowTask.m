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
#import "BMLWorkflowTask+Private.h"
#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflowConfigurator.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskDescriptor

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier
                        verb:(NSString*)verb
                  properties:(NSDictionary*)properties {
    
    if (self = [super init]) {
        self.verb = verb ?: @"create";
        self.type = typeIdentifier;
        self.properties = properties;
    }
    return  self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier {

    return [self initWithType:typeIdentifier verb:nil properties:nil];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)taskName {
    
    return [NSString stringWithFormat:@"%@%@",
            [_verb capitalizedString],
            [[_type stringValue] capitalizedString] ?: @"Resource"];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)typeAsString {
    
    return _type.stringValue;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowInputDescriptor

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier
                        name:(NSString*)name
                        verb:(NSString*)verb
                  properties:(NSDictionary*)properties {
    
    if (self = [super initWithType:typeIdentifier verb:nil properties:nil]) {
        self.name = name;
    }
    return  self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier
                        name:(NSString*)name {
    
    return [self initWithType:typeIdentifier name:name verb:nil properties:nil];
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier
                        verb:(NSString*)verb
                  properties:(NSDictionary*)properties {
    
    NSAssert(NO, @"WorkflowTask initWithType:verb:... Should not be here!");
    return  nil;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithType:(BMLResourceTypeIdentifier*)typeIdentifier {
    
    NSAssert(NO, @"WorkflowTask initWithType: Should not be here!");
    return  nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTask ()
@property (nonatomic, strong, readwrite) NSString* name;
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTask

@synthesize name;

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLWorkflowTask*)newTaskWithDescriptor:(BMLWorkflowTaskDescriptor*)descriptor
                             configurator:(BMLWorkflowConfigurator*)configurator {
    
    NSString* taskClassName = [NSString stringWithFormat:@"BMLWorkflowTask%@", descriptor.taskName];
    return [[NSClassFromString(taskClassName) alloc] initWithDescriptor:descriptor configurator:configurator];
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithDescriptor:(BMLWorkflowTaskDescriptor*)descriptor
                      configurator:(BMLWorkflowConfigurator*)configurator {
    
    if (self = [super init]) {
    
        self.descriptor = descriptor;
        self.name = descriptor.taskName;
        self.configurator = configurator;
        //    item.configuration = [configurator configurationForResourceType:item.inputResourceType];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {

    return [self initWithDescriptor:nil configurator:nil];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithArguments:(NSArray*)inputs
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {

    [super runWithArguments:inputs inContext:context completionBlock:completion];
    self.resourceStatus = BMLResourceStatusStarted;
    self.runningResource = inputs.firstObject;
    
    [self addObserver:self
           forKeyPath:@"resourceStatus"
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:NULL];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"";
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMLWorkflowStatus)status {

    switch (self.resourceStatus) {
        case BMLResourceStatusUndefined:
            return [super status];
        case BMLResourceStatusWaiting:
        case BMLResourceStatusQueued:
        case BMLResourceStatusStarted:
            return BMLWorkflowStarted;
        case BMLResourceStatusEnded:
            return BMLWorkflowEnded;
        case BMLResourceStatusFailed:
            return BMLWorkflowFailed;
        default:
            NSAssert(NO, @"Should not be here: wrong resourceStatus found.");
            break;
    }
    NSAssert(NO, @"Should not be here: wrong resourceStatus found.");
    return BMLWorkflowIdle;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"status"]) {
        [keyPaths addObject:@"resourceStatus"];
    }
    
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowNoOpTask

@end

