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

//-- check: this should go into an umbrella header for bigml-objc
#import "BMLEnums.h"
#import "BMLResource.h"
#import "BMLResourceTypeIdentifier.h"
#import "BMLAPIConnector.h"

#define kTestUsernameFilename @"username"
#define kTestApiKeyFilename @"apikey"
#define kTestFileFailURL1 [NSURL URLWithString:@"/Not/existing/path/to/source/file.csv"]
#define kResourcePath(A,B) [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:(A) ofType:(B)]];

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
    BMLAPIConnector* _ml;
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

    _ml = [[BMLAPIConnector alloc] initWithUsername:username
                                          apiKey:apiKey
                                            mode:BMLModeDevelopment];
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
    [self waitForExpectationsWithTimeout:360 handler:^(NSError* error) {
        NSLog(@"Expect Error: %@", error);
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
//- (void)testLocal {
//    
//    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
//        _workflow =
//        [[BMLWorkflowTaskSequence alloc] initWithSteps:@[@"Test",
//                                             @"Test",
//                                             @"FailTest",
//                                             @"Test"]
//                              configurator:nil];
//
//        [_workflow runWithArguments:nil
//                          inContext:[[BMLWorkflowTaskContext alloc]
//                                     initWithWorkflow:_workflow connector:_ml]
//                          completionBlock:^(NSArray* results, NSError* e) {
//            [exp fulfill];
//            XCTAssert(e, @"Error: \"%@\"", e);
//        }];
//    }];
//}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testFileFail {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithDescriptors:
                     @[[[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeSource],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeModel],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypePrediction]]
                                                                  inputs:nil
                                                            configurator:nil];
        
        NSURL* url = kResourcePath(@"iris", @"csv");
        BMLMinimalResource* resource =
        [[BMLMinimalResource alloc] initWithName:@"test"
                                        fullUuid:[NSString stringWithFormat:@"%@/%@",
                                                  BMLResourceTypeFile, [url path]]
                                      definition:nil];

        [_workflow runWithArguments:@[resource]
                          inContext:[[BMLWorkflowTaskContext alloc]
                                     initWithWorkflow:_workflow connector:_ml]
                          completionBlock:^(NSArray* results, NSError* e) {

                              XCTAssert(e, @"Error: \"%@\"", e);
                              [exp fulfill];
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testBasicContextFlow {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
    
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithDescriptors:
                     @[[[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeSource],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeDataset],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeModel],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypePrediction]]
                                                                  inputs:nil
                                                            configurator:nil];
        
        BMLWorkflowTaskContext* context =
        [[BMLWorkflowTaskContext alloc] initWithWorkflow:_workflow connector:_ml];
        
        NSURL* url = kResourcePath(@"iris", @"csv");
        BMLMinimalResource* resource =
        [[BMLMinimalResource alloc] initWithName:@"test"
                                        fullUuid:[NSString stringWithFormat:@"%@/%@",
                                                  BMLResourceTypeFile, [url path]]
                                      definition:nil];
        [_workflow runWithArguments:@[resource]
                          inContext:context
                    completionBlock:^(NSArray* results, NSError* e) {

                        XCTAssert(!e, @"Error: \"%@\"", e);
                        [exp fulfill];
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testClusterResourceFlow {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithDescriptors:
                     @[[[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeSource],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeDataset],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeCluster],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypePrediction]]
                                                                  inputs:nil
                                                            configurator:nil];
        
        BMLWorkflowTaskContext* context =
        [[BMLWorkflowTaskContext alloc] initWithWorkflow:_workflow connector:_ml];
        
        NSURL* url = kResourcePath(@"iris", @"csv");
        BMLMinimalResource* resource =
        [[BMLMinimalResource alloc] initWithName:@"test"
                                        fullUuid:[NSString stringWithFormat:@"%@/%@",
                                                  BMLResourceTypeFile, [url path]]
                                      definition:nil];
        
        [_workflow runWithArguments:@[resource]
                          inContext:context
                    completionBlock:^(NSArray* results, NSError* e) {
                        
            XCTAssert(!e, @"Error: \"%@\"", e);
                        [exp fulfill];
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)testWrongCredentials {
    
    [self runTestName:NSStringFromSelector(_cmd) block:^(XCTestExpectation* exp) {
        
        _workflow = [[BMLWorkflowTaskSequence alloc] initWithDescriptors:
                     @[[[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeSource],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeDataset],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypeModel],
                       [[BMLWorkflowTaskDescriptor alloc] initWithType:BMLResourceTypePrediction]]
                                                                  inputs:nil
                                                            configurator:nil];
        
        NSURL* url = kResourcePath(@"iris", @"csv");
        BMLMinimalResource* resource =
        [[BMLMinimalResource alloc] initWithName:@"test"
                                        fullUuid:[NSString stringWithFormat:@"%@/%@",
                                                  BMLResourceTypeFile, [url path]]
                                      definition:nil];
        
        BMLAPIConnector* ml = [[BMLAPIConnector alloc] initWithUsername:@"test1"
                                                              apiKey:@"test2"
                                                                   mode:BMLModeDevelopment];
        BMLWorkflowTaskContext* context =
        [[BMLWorkflowTaskContext alloc] initWithWorkflow:_workflow connector:ml];

        
        [_workflow runWithArguments:@[resource]
                          inContext:context
                    completionBlock:^(NSArray* results, NSError* e) {
                        
                        XCTAssert([e code] == 401, @"Error: \"%@\"", e);
                        [exp fulfill];
        }];
    }];
}

@end
