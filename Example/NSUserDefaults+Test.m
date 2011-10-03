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
    @autoreleasepool
        {
        PropertyGetterBlock theGetter = ^(id _self, NSString *key)
            { return([_self objectForKey:key]); };
        PropertySetterBlock theSetter = ^(id _self, NSString *key, id value)
            { [_self setObject:value forKey:key]; };

        [[[CPropertyFactory alloc] init] configure:self getter:theGetter setter:theSetter error:NULL];
        }
    }

@end
