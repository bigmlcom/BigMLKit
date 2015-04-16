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

#import <XCTest/XCTest.h>

#import "BMLWorkflowTaskSequence.h"
#import "BMLWorkflowTask.h"
#import "BMLWorkflowTaskContext.h"
#import "BMLResourceProtocol.h"
#import "ML4iOS.h"

#define kTestUsernameFilename @"username"
#define kTestApiKeyFilename @"apikey"
#define kTestFileFailURL1 [NSURL URLWithString:@"/Not/existing/path/to/source/file.csv"]
#define kResourcePath(A,B) [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:(A) ofType:(B)]];

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLResource : NSObject <BMLResourceProtocol>

@property (nonatomic, strong) BMLResourceFullUuid* fullUuid;
@property (nonatomic, strong) NSString* name;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLResource


@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowTestTests : XCTestCase

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowTestTests {
    
    BMLWorkflowTaskSequence* _workflow;
    ML4iOS* _ml;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUp
{
    [super setUp];
    
    NSString* path = [[NSBundle bundleForClass:[self class] ] pathForResource:kTestUsernameFilename ofType:@"txt"];

    NSString* username = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]
                          stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    path = [[NSBundle bundleForClass:[self class] ] pathForResource:kTestApiKeyFilename ofType:@"txt"];
    NSString* apiKey = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]
                        stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    _ml = [[ML4iOS alloc] initWithUsername:username key:apiKey developmentMode:NO];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)runTestName:(NSString*)name block:(void(^)(XCTestExpectation* exp))block {
    
    XCTestExpectation* exp = [self expectationWithDescription:name];
    block(exp);
    [self waitForExpectationsWithTimeout:30 handler:^(NSError* error) {
        NSLog(@"Expect Error: %@", error);
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testLocal {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        _workflow =
        [[BMLWorkflowTaskSequence alloc] initWithSteps:@[@"Test",
                                             @"Test",
                                             @"FailTest",
                                             @"Test"]
                              configurator:nil];

        [_workflow runInContext:[[BMLWorkflowTaskContext alloc] initWithWorkflow:_workflow connector:_ml]
                          completionBlock:^(NSError* e) {
            [exp fulfill];
            XCTAssert(e, @"Error: \"%@\"", e);
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testFileFail {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithSteps:@[@"CreateSource",
                                                         @"CreateDataset",
                                                         @"CreateModel",
                                                         @"CreatePrediction"]
                                          configurator:nil];
        
        [_workflow runInContext:[[BMLWorkflowTaskContext alloc] initWithWorkflow:_workflow connector:_ml]
                          completionBlock:^(NSError* e) {
            [exp fulfill];
            XCTAssert(e, @"Error: \"%@\"", e);
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testBasicContextFlow {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
    
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithSteps:@[@"CreateSource",
                                                         @"CreateDataset",
                                                         @"CreateModel",
                                                         @"CreatePrediction"]
                                          configurator:nil];
        
        BMLWorkflowTaskContext* context =
        [[BMLWorkflowTaskContext alloc] initWithWorkflow:_workflow connector:_ml];
        
        context.info[kCSVSourceFilePath] = kResourcePath(@"iris", @"csv");
        context.info[kWorkflowName] = @"test";
        
        [_workflow runInContext:context completionBlock:^(NSError* e) {
            [exp fulfill];
            XCTAssert(!e, @"Error: \"%@\"", e);
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testBasicResourceFlow {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithSteps:@[@"CreateSource",
                                                                     @"CreateDataset",
                                                                     @"CreateModel",
                                                                     @"CreatePrediction"]
                                                      configurator:nil];
        
        BMLResource* resource = [BMLResource new];
        NSURL* url = kResourcePath(@"iris", @"csv");
        resource.fullUuid = [NSString stringWithFormat:@"%@/%@", kFileEntityType, [url path]];
        resource.name = @"test";
        
        [_workflow runWithResource:resource connector:_ml completionBlock:^(NSError* e) {
            [exp fulfill];
            XCTAssert(!e, @"Error: \"%@\"", e);
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testClusterResourceFlow {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithSteps:@[@"CreateSource",
                                                                     @"CreateDataset",
                                                                     @"CreateCluster",
                                                                     @"CreatePrediction"]
                                                      configurator:nil];
        
        BMLResource* resource = [BMLResource new];
        NSURL* url = kResourcePath(@"iris", @"csv");
        resource.fullUuid = [NSString stringWithFormat:@"%@/%@", kFileEntityType, [url path]];
        resource.name = @"test";
        
        [_workflow runWithResource:resource connector:_ml completionBlock:^(NSError* e) {
            [exp fulfill];
            XCTAssert(!e, @"Error: \"%@\"", e);
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testWrongCredentials {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithSteps:@[@"CreateSource",
                                                                     @"CreateDataset",
                                                                     @"CreateModel",
                                                                     @"CreatePrediction"]
                                                      configurator:nil];
        
        BMLResource* resource = [BMLResource new];
        NSURL* url = kResourcePath(@"iris", @"csv");
        resource.fullUuid = [NSString stringWithFormat:@"%@/%@", kFileEntityType, [url path]];
        resource.name = @"test";
        
        ML4iOS* ml = [[ML4iOS alloc] initWithUsername:@"test1" key:@"test2" developmentMode:NO];

        [_workflow runWithResource:resource connector:ml completionBlock:^(NSError* e) {
            [exp fulfill];
            XCTAssert([e.userInfo[BMLExtendedErrorDescriptionKey][@"Response"][@"code"] intValue] == 401, @"Error: \"%@\"", e);
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testFailingSingleTaskAsWorkflow {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        
        BMLWorkflow* workflow = [BMLWorkflowTask newTaskForStep:@"CreateSource" configurator:nil];
        
        BMLWorkflowTaskContext* context =
        [[BMLWorkflowTaskContext alloc] initWithWorkflow:workflow connector:_ml];
        
        context.info[kCSVSourceFilePath] = [NSURL URLWithString:@"iris.csv"];
        context.info[kWorkflowName] = @"test";
        
        [workflow runInContext:context completionBlock:^(NSError* e) {
            [exp fulfill];
            XCTAssert(e, @"Error: \"%@\"", e);
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testSingleTaskAsWorkflow {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        
        BMLWorkflow* workflow = [BMLWorkflowTask newTaskForStep:@"CreateSource" configurator:nil];
        
        BMLWorkflowTaskContext* context =
        [[BMLWorkflowTaskContext alloc] initWithWorkflow:workflow connector:_ml];
        
        context.info[kCSVSourceFilePath] = kResourcePath(@"iris", @"csv");
        context.info[kWorkflowName] = @"test";
        
        [workflow runInContext:context completionBlock:^(NSError* e) {
            [exp fulfill];
            XCTAssert(!e, @"Error: \"%@: %@\"", workflow.name, e);
        }];
    }];
}

@end
