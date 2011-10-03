//
//  main.m
//  Test
//
//  Created by Jonathan Wight on 10/3/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMyDefaults.h"
#import "NSUserDefaults+Test.h"

int main (int argc, const char * argv[])
    {
    @autoreleasepool
        {
        CMyDefaults *theDefaults = [[CMyDefaults alloc] init];;
//        theDefaults.name = @"Hello world";
//        theDefaults.timestamp = 42;
        theDefaults.name = @"This is a test";
        NSLog(@"%@", theDefaults.name);

        theDefaults.position = (NSPoint){ 10, 20 };
        NSLog(@"%@", NSStringFromPoint(theDefaults.position));


//        NSLog(@"%g", theDefaults.timestamp);
        
//        [NSUserDefaults standardUserDefaults].username = @"Steve J.";
        
        }
    return 0;
    }

