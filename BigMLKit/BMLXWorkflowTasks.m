//
//  BMLXWorkflowTasks.m
//  BigMLX
//
//  Created by sergio on 25/03/15.
//  Copyright (c) 2015 sergio. All rights reserved.
//

#if TARGET_OS_IPHONE

#warning The BMLWorkflowTaskDisplayPrediction class is only available on OS X

#else

#import "BigMLKit.h"
#import "BMLWorkflowTask.h"
#import "BMLWorkflowTaskContext.h"

#import "BMLResource.h"
#import "BMLResourceDefinition.h"
#import "BMLCoreDataLayer.h"

#import "BMLWorkflowTask+Private.h"
#import "BMLResourceTypeIdentifier+BigML.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTaskDisplayPrediction : BMLWorkflowTaskCreatePrediction
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTaskDisplayPrediction

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kPredictionEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runWithResources:(NSArray*)resources
              inContext:(BMLWorkflowTaskContext*)context
        completionBlock:(BMLWorkflowCompletedBlock)completion {
    
    id<BMLResource> resource = resources.firstObject;
    if (!resource.jsonDefinition) {
        
        BMLResource* model = [[BMLResource fetchByType:[[BMLResourceTypeIdentifier alloc] initWithRawType:resource.type]
                                                  uuid:resource.uuid] firstObject];
        if (model.jsonDefinition) {
            resource.jsonDefinition = model.jsonDefinition;
        }
    }
    [super runWithResources:resources inContext:context completionBlock:completion];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Making Prediction";
}
@end

#endif