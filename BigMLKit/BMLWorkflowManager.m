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

#import "BMLWorkflowManager.h"
#import "BMLWorkflowTask.h"
#import "BMLWorkflowTaskSequence.h"
#import "MAKVONotificationCenter.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowManager ()

@property (nonatomic, weak) BMLWorkflowTask* currentWorkflow;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowManager

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
 
    if (self = [super init]) {
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)dictFromTask:(BMLWorkflow*)task count:(NSUInteger)count {
    
    static int counter = 0;
    if (count == NSNotFound)
        count = ++counter;
    return @{ @"title":task.name?:[NSString stringWithFormat:@"Task %d: %@", (int)count, task.statusMessage],
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
                    
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"task == %@", wtask];
                    for (NSMutableDictionary* dict in [[wself.tasks arrangedObjects] filteredArrayUsingPredicate:predicate]) {
                        NSUInteger index = [[wself.tasks arrangedObjects] indexOfObject:dict];
                        [wself.tasks removeObjectAtArrangedObjectIndex:index];
                        [wself.tasks insertObject:[self dictFromTask:wtask count:[dict[@"count"] intValue]] atArrangedObjectIndex:index];
                    }
                    
                    NSLog(@"Task %@ status changed to %d", wtask, wtask.status);
                }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)removeWorkflow:(BMLWorkflow*)task {
    
    self.runningTasksCount = _runningTasksCount - 1;
#ifndef DEBUG
    [_tasks removeObjectAtArrangedObjectIndex:[_tasks.arrangedObjects count] - 1];
#endif
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)workflows {
 
    return [_tasks arrangedObjects];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentWorkflowAtIndex:(NSUInteger)index {
 
    NSArray* arrangedObjects = _tasks.arrangedObjects;
    if (index < [arrangedObjects count])
        self.currentWorkflow = arrangedObjects[index][@"task"];

}

@end
