//
//  CMyDefaults.m
//  Test
//
//  Created by Jonathan Wight on 10/3/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CMyDefaults.h"

#import "CPropertyFactory.h"

@interface CMyDefaults ()
@property (readwrite, nonatomic, retain) NSMutableDictionary *storage;
@end

@implementation CMyDefaults

@dynamic name;
@dynamic timestamp;
@dynamic position;

@synthesize storage;

+ (void)initialize
    {
    if (self != [CMyDefaults class])
        {
        return;
        }

    @autoreleasepool
        {
        PropertyGetterBlock theGetter = ^(id _self, NSString *key)
            { return([((CMyDefaults *)_self).storage objectForKey:key]); };
        PropertySetterBlock theSetter = ^(id _self, NSString *key, id value)
            { [((CMyDefaults *)_self).storage setObject:value forKey:key]; };

        [[[CPropertyFactory alloc] init] configure:self getter:theGetter setter:theSetter error:NULL];
        }
    }

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        storage = [NSMutableDictionary dictionary];
        }
    return self;
    }

@end
