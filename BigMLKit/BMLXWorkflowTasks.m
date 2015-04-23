//
//  BMLXWorkflowTasks.m
//  BigMLX
//
//  Created by sergio on 25/03/15.
//  Copyright (c) 2015 sergio. All rights reserved.
//

#if TARGET_OS_IPHONE

#warning The BMLXWorkflowTaskCreatePrediction class is only available on OS X

#else

#import "BigMLKit.h"
#import "BMLWorkflowTask.h"
#import "BMLWorkflowTaskContext.h"
#import "BMLWorkflowTaskConfiguration.h"
#import "BMLWorkflowConfigurator.h"
#import "ML4iOS.h"

#import "BMLResource.h"
#import "BMLResourceDefinition.h"
#import "BMLCoreDataLayer.h"

#import "BMLWorkflowTask+Private.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLXWorkflowTaskCreatePrediction : BMLWorkflowTask
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLXWorkflowTaskCreatePrediction

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithResourceType:kPredictionEntityType]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runInContext:(BMLWorkflowTaskContext*)context completionBlock:(void(^)(NSError*))completion {
    
    if (context.info[kModelId] || context.info[kClusterId]) {
        
        [super runInContext:context completionBlock:nil];
        
        BMLResourceType* type = nil;
        BMLResourceUuid* uuid = nil;
        NSDictionary* definition = nil;
        
        if (context.info[kModelId]) { //-- predicting from tree
            
            type = kModelEntityType;
            uuid = context.info[kModelId];
            definition = context.info[kModelDefinition];
            
        } else if (context.info[kClusterId]) { //-- predicting from cluster
            
            type = kClusterEntityType;
            uuid = context.info[kClusterId];
            definition = context.info[kClusterDefinition];
        }
        if (!definition) {
            
            BMLResource* model = [[BMLResource fetchByPredicate:
                                   [NSPredicate predicateWithFormat:@"type = %@ AND uuid = %@",
                                    type, uuid]] firstObject];
            if (!(definition = model.definition.json)) {
            
                NSInteger status = 0;
                if ([type isEqualToString:kModelEntityType]) {
                    definition = [context.ml getModelWithIdSync:context.info[kModelId]
                                                     statusCode:&status];
                } else if ([type isEqualToString:kClusterEntityType]) {
                    definition = [context.ml getClusterWithIdSync:context.info[kClusterId]
                                                       statusCode:&status];
                }
            }
            if (definition) {
                if (context.info[kModelId]) {
                    context.info[kModelDefinition] = definition;
                } else if (context.info[kClusterId]) {
                    context.info[kClusterDefinition] = definition;
                }
                self.bmlStatus = BMLWorkflowTaskEnded;

            } else {
                
                self.error = [NSError errorWithInfo:@"The model this prediction was based upon has not been found" code:-1];
                self.bmlStatus = BMLWorkflowTaskFailed;
            }
        }
        //        NSDictionary* options = [self optionStringForCurrentConfiguration:context];
        
        
    } else {
        self.error = [NSError errorWithInfo:@"Could not find requested model/cluster" code:-1];
        self.bmlStatus = BMLWorkflowTaskFailed;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)message {
    
    return @"Making Prediction";
}
@end

#endif