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

#if TARGET_OS_IPHONE

#warning The BMLWorkflowManager class is only available on OS X

#else

#import "BMLResource.h"
#import "BMLWorkflowManager.h"
#import "BMLWorkflowTask.h"
#import "BMLWorkflowTaskSequence.h"
#import "MAKVONotificationCenter.h"

#import "BMLCoreDataLayer.h"
#import "BMLUserDefaults.h"
#import "BMLUtils.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowManager ()

@property (nonatomic, weak) BMLExecutionResource* currentWorkflowResource;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowManager {
    
    NSArray* _stashedTasks;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
 
    if (self = [super init]) {
        _keepTasksAfterCompletion = YES;
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMLExecutionResource*)createTaskNamed:(NSString*)name
                              definition:(NSDictionary*)definition
                                fullUuid:(BMLResourceFullUuid*)fullUuid {
    
    NSAssert([NSThread isMainThread], @"This method can only be called on the main thread");
    
    if (!fullUuid) {
        fullUuid = [NSString stringWithFormat:@"%@/%@",
                    BMLResourceTypeWhizzmlExecution.stringValue,
                    [NSUUID UUID].UUIDString];
    }
    
    NSManagedObjectContext* context = [BMLCoreDataLayer dataLayer].managedObjectContext;
    BMLResource* res = [BMLResource createPseudoResource:fullUuid
                                                    name:name
                                              definition:definition
                                                 context:context];
    res.isRemote = @NO;
    NSError* error = nil;
    [context saveToPersistentStore:&error];
    if (error)
        NSLog(@"ERROR CREATING TASK: %@", error);
    
    return res;
}

//////////////////////////////////////////////////////////////////////////////////////
- (id<BMLResource>)resourceFromTask:(BMLWorkflow*)task count:(NSUInteger)count {

    NSMutableDictionary* dict = [@{ @"name":task.name?:[NSString stringWithFormat:@"Task %d: %@",
                                                       (int)count,
                                                       task.statusMessage],
                                   @"task":task,
                                   @"status":@(task.status),
                                   @"count":@(count)} mutableCopy];
    
    if ([NSStringFromClass(task.currentTask.class) isEqualToString:@"BMLWorkflowTaskCreateExecution"])
        dict[@"execution"] = task.currentTask;

    BMLExecutionResource* resource = [self createTaskNamed:dict[@"name"]
                                                definition:@{}
                                                  fullUuid:nil];
    
    resource.status = BMLResourceStatusUndefined;
    return resource;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)addWorkflowAsCurrent:(BMLWorkflow*)task {

    self.runningTasksCount = _runningTasksCount + 1;
    BMLMinimalResource* resource = [self resourceFromTask:task count:NSNotFound];
    [_tasks insertObject:resource atArrangedObjectIndex:0];
    self.currentWorkflowResource = resource;
    
    [task addObserver:self
              keyPath:NSStringFromSelector(@selector(status))
              options:0
                block:^(MAKVONotification* notification) {

                    dispatch_async(dispatch_get_main_queue(), ^{
                        resource.status = [(BMLWorkflow*)notification.target status];
                    });
                }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)removeTask:(BMLWorkflow*)task {
    
    NSUInteger index = [_tasks.arrangedObjects indexOfObject:task];
    if (index != NSNotFound)
        [_tasks removeObjectAtArrangedObjectIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)cleanUpWorkflow:(BMLWorkflow*)task {
    
    [task removeObserver:self keyPath:NSStringFromSelector(@selector(status))];
    self.runningTasksCount = _runningTasksCount - 1;
    if (!_keepTasksAfterCompletion) {
        [self removeTask:task];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)stashWorkflows {
    
    _stashedTasks = [_tasks.arrangedObjects copy];
    for (BMLWorkflowTask* t in _tasks.arrangedObjects) {
        [self removeTask:t];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)popWorkflows {
    
    for (BMLWorkflowTask* t in _tasks.arrangedObjects) {
        [self removeTask:t];
    }
    for (BMLWorkflowTask* t in _stashedTasks) {
        [_tasks addObject:t];
    }
    _stashedTasks = nil;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSNumber*)areThereAnyTasks {

    return @([[_tasks arrangedObjects] count] > 0);
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)selectCurrentWorkflowAtIndex:(NSUInteger)index {
 
    NSArray* arrangedObjects = _tasks.arrangedObjects;
    if (index < [arrangedObjects count])
        self.currentWorkflowResource = arrangedObjects[index];
    else
        self.currentWorkflowResource = nil;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)selectCurrentWorkflow:(BMLResource*)resource {
    
    NSUInteger index = [_tasks.arrangedObjects indexOfObject:resource];
    [self selectCurrentWorkflowAtIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)macro {
    
    if ([_tasks.arrangedObjects count] == 0)
        return nil;
    
    NSMutableArray* macro = [NSMutableArray new];
    for (long i = [_tasks.arrangedObjects count] - 1; i >= 0 ; --i) {
        BMLResource* r =  _tasks.arrangedObjects[i];
        [macro addObject:@{ @"name" : r.name,
                            @"fullUuid" : r.fullUuid}];
    }

    BMLResource* mainTask =
    [BMLResource
     fetchByType:[BMLResourceTypeIdentifier typeFromFullUuid:macro.firstObject[@"fullUuid"]]
     uuid:[BMLResourceTypeIdentifier uuidFromFullUuid:macro.firstObject[@"fullUuid"]]];
    
    NSString* creationDate = [BMLUtils stringFromDate:[NSDate new]];
    NSString* uuid = [[NSUUID UUID] UUIDString];
    return @{ @"name" : _name ?: @"Custom macro",
              @"description" : @"",
              @"tags" : @[],
              @"created" : creationDate,
              @"updated" : creationDate,
              @"resource" : [NSString stringWithFormat:@"macro/%@", uuid],
              @"macro" : macro,
              @"project" : @"",
              @"inputs" : [mainTask jsonDefinition][@"inputs"] ?: @[]
              };
}


@end
#endif