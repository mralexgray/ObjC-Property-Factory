//
//  NSUserDefaults+Test.m
//  Test
//
//  Created by Jonathan Wight on 10/3/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "NSUserDefaults+Test.h"

#import "CPropertyFactory.h"

@implementation NSUserDefaults (Test)

@dynamic username;

+ (void)load
    {
    [[[CPropertyFactory alloc] init] configure:self getter:NULL setter:NULL];
    }


@end
