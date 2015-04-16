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

#import <Foundation/Foundation.h>

/**
 *  The BMLResourceProtocol represents the traits that any concrete BMLResource implementation
 *  should expose.
 */
@protocol BMLResourceProtocol <NSObject>

/**
 *  The full UUID of the resource, e.g. model/AF98D23890SD...
 */
@property (nonatomic, strong) BMLResourceFullUuid* fullUuid;

/**
 *  The named assigned to the resource.
 */
@property (nonatomic, strong) NSString* name;


@end
