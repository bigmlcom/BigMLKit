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

/**
 *  An NSArrayController representing all tasks in execution.
 *  For each handled task, the array controller provides access to a NSDictionary
 *  with the following keys:
 *
 *   - task: task title, a NSString
 *   - status: task status, a BMLWorkflowStatus
 *   - task: the task itself, aBMLWorkflowTask
 *   - count: the sequence index of the task, an integer.
 */
//@property (nonatomic, weak) NSArrayController* tasks;

@property (nonatomic, weak) BMLWorkflowTask* currentWorkflow;

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
- (NSDictionary*)dictFromTask:(BMLWorkflow*)task count:(NSUInteger)count {
    
    static int counter = 0;
    if (count == NSNotFound)
        count = ++counter;

    if ([NSStringFromClass(task.currentTask.class) isEqualToString:@"BMLWorkflowTaskCreateExecution"])
        return @{ @"name":task.name?:[NSString stringWithFormat:@"Task %d: %@", (int)count, task.statusMessage],
                  @"task":task,
                  @"execution":task.currentTask,
                  @"status":@(task.status),
                  @"count":@(count)};
    else
        return @{ @"name":task.name?:[NSString stringWithFormat:@"Task %d: %@", (int)count, task.statusMessage],
                  @"task":task,
                  @"status":@(task.status),
                  @"count":@(count)};
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)addWorkflowAsCurrent:(BMLWorkflow*)task {
    
    self.runningTasksCount = _runningTasksCount + 1;
    [_tasks insertObject:[self dictFromTask:task count:NSNotFound] atArrangedObjectIndex:0];
    self.currentWorkflow = task;
    
    BMLWorkflowManager* __weak wself = self;
    BMLWorkflow* __weak wtask = task;
    [task addObserver:self
              keyPath:NSStringFromSelector(@selector(status))
              options:0
                block:^(MAKVONotification* notification) {

                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"task == %@", wtask];
                        for (NSMutableDictionary* dict in [[wself.tasks arrangedObjects] filteredArrayUsingPredicate:predicate]) {
                            NSUInteger index = [[wself.tasks arrangedObjects] indexOfObject:dict];
                            [wself.tasks removeObjectAtArrangedObjectIndex:index];
                            [wself.tasks insertObject:[self dictFromTask:wtask count:[dict[@"count"] intValue]] atArrangedObjectIndex:index];
                        }
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
        self.currentWorkflow = arrangedObjects[index][@"task"];

}

//////////////////////////////////////////////////////////////////////////////////////
- (void)selectCurrentWorkflow:(BMLWorkflow*)task {
    
    NSArray* arrangedObjects =
    [_tasks.arrangedObjects filteredArrayUsingPredicate:
     [NSPredicate predicateWithFormat:@"task == %@", task]];
    
    NSUInteger index = [_tasks.arrangedObjects indexOfObject:arrangedObjects.firstObject];
    [self selectCurrentWorkflowAtIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)composite {
    
    NSMutableArray* composite = [NSMutableArray new];
    for (long i = [_tasks.arrangedObjects count] - 1; i >= 0 ; --i) {
        NSDictionary* w =  _tasks.arrangedObjects[i];
        [composite addObject:@{ @"name" : w[@"name"],
                                @"fullUuid" : [w[@"task"] workflowUuid]}];
    }

    BMLResource* mainTask =
    [BMLResource fetchByType:[BMLResourceTypeIdentifier typeFromFullUuid:composite.firstObject[@"fullUuid"]]
                        uuid:[BMLResourceTypeIdentifier uuidFromFullUuid:composite.firstObject[@"fullUuid"]]].firstObject;
     
    NSString* creationDate = [BMLUtils stringFromDate:[NSDate new]];
    NSString* uuid = [[NSUUID UUID] UUIDString];
    return @{ @"name" : @"Composite",
              @"description" : @"",
              @"tags" : @[],
              @"created" : creationDate,
              @"updated" : creationDate,
              @"resource" : [NSString stringWithFormat:@"composite/%@", uuid],
              @"composite" : composite,
              @"project" : @"",
              @"parameters" : [mainTask jsonDefinition][@"parameters"] ?: @[]
              };
}


@end
#endif