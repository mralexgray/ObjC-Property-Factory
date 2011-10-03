# ObjC-Property-Factory

## Synopsis

ObjC Property Factory lets you create property getter and setter method implementations automatically. In effect it allows you to define your class normally and then automatically generate getter & setter method implementations at runtime.

This can be very handy as a way of providing a property based facade on top of a "objectForKey:" style object such as NSDictionary (hello JSON!) or NSUserDefaults.

## License

This code is licensed under the 2-clause BSD license ("Simplified BSD License" or "FreeBSD License") license. The license is reproduced below:

Copyright 2011 Jonathan Wight. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ''AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Jonathan Wight.

## Example

    #import <Foundation/Foundation.h>

    @interface NSUserDefaults (Example)

    @property (readwrite, nonatomic, retain) NSString *username;
    @property (readwrite, nonatomic, assign) NSPoint position;

    @end

    // #############################################################################

    #import "NSUserDefaults+Example.h"

    #import "CPropertyFactory.h"

    @implementation NSUserDefaults (Example)

    @dynamic username;
    @dynamic position;

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

    // #############################################################################

    [NSUserDefaults standardDefaults].username = @"bob";
    [NSUserDefaults standardDefaults].position = (NSPoint){ 42, 24 };

## TODO/BUGS

* Not very robustly tested.
* Does not support all basic C types, yet.
* Does not support any struct types yet (except NSPoint).
* Needs more robust error handling (mainly to do with property attributes).