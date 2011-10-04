//
//  CPropertyFactory.m
//  Test
//
//  Created by Jonathan Wight on 10/3/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY 2011 TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 2011 TOXICSOFTWARE.COM OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of 2011 toxicsoftware.com.

#import "CPropertyFactory.h"

#import <objc/runtime.h>

#define SIMPLE_GETTER(T, T2) ^(id _self) { return([inGetter(_self, thePropertyName) T##Value]); };
#define SIMPLE_SETTER(T, T2) ^(id _self, T value) { inSetter(_self, thePropertyName, [NSNumber numberWith##T2:value]); };

#define STRUCT_GETTER(T) ^(id _self) { T value; [inGetter(_self, thePropertyName) getValue:&value]; return(value); };
#define STRUCT_SETTER(T) ^(id _self, T value) { inSetter(_self, thePropertyName, [NSValue valueWithBytes:&value objCType:@encode(T)]); };

@interface CPropertyFactory ()
@end

@implementation CPropertyFactory

- (BOOL)configure:(Class)inClass getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter error:(NSError **)outError
    {
    unsigned int thePropertyCount = 0;
    objc_property_t *theProperties = class_copyPropertyList(inClass, &thePropertyCount);
    
    for (unsigned int thePropertyIndex = 0; thePropertyIndex != thePropertyCount; ++thePropertyIndex)
        {
        [self configure:inClass property:theProperties[thePropertyIndex] getter:inGetter setter:inSetter error:NULL];
        }

    if (theProperties != NULL)
        {
        free(theProperties);
        }

    return(YES);
    }

- (BOOL)configure:(Class)inClass propertyName:(NSString *)inProperty getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter error:(NSError **)outError
    {
    objc_property_t theProperty = class_getProperty(inClass, [inProperty UTF8String]);
    if (theProperty == NULL)
        {
        return(NO);
        }
    else
        {
        return([self configure:inClass property:theProperty getter:inGetter setter:inSetter error:outError]);
        }
    }
    
- (BOOL)configure:(Class)inClass property:(objc_property_t)inProperty getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter error:(NSError **)outError
    {
    BOOL theDynamicFlag = NO;
    BOOL theReadonlyFlag = NO;
    BOOL theNonAtomicFlag = NO;
    const char *theType = NULL;

    unsigned int theAttributeCount = 0;

    objc_property_attribute_t *theAttributes = property_copyAttributeList(inProperty, &theAttributeCount);

    // See http://developer.apple.com/library/ios/#DOCUMENTATION/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html for all flags.
    for (unsigned int theAttributeIndex = 0; theAttributeIndex != theAttributeCount; ++theAttributeIndex)
        {
        if (strlen(theAttributes[theAttributeIndex].name) == 1)
            {
            switch (theAttributes[theAttributeIndex].name[0]) {
                case 'D':
                    theDynamicFlag = YES;
                    break;
                case 'T':
                    theType = theAttributes[theAttributeIndex].value;
                    break;
                case 'R':
                    theReadonlyFlag = YES;
                    break;
                case 'N':
                    theNonAtomicFlag = YES;
                    break;
                }
            }
        }
    
    if (theAttributes != NULL)
        {
        free(theAttributes);
        }

    if (theDynamicFlag == NO)
        {
//        NSLog(@"Cannot create IMPs for non-dynamic properties");
        return(NO);
        }

    NSString *thePropertyName = [NSString stringWithUTF8String:property_getName(inProperty)];
    NSString *theGetterName = thePropertyName;
    NSString *theSetterName = [NSString stringWithFormat:@"set%@%@:", [[thePropertyName substringToIndex:1] uppercaseString], [thePropertyName substringFromIndex:1]];

    NSString *theGetterType = [NSString stringWithFormat:@"%s@:", theType];
    NSString *theSetterType = [NSString stringWithFormat:@"v@:%s", theType];

    id theGetterIMPBlock = NULL;
    id theSetterIMPBlock = NULL;

    // #####################################################################

    if (theType[0] == '@')
        {
        theGetterIMPBlock = ^(id _self) { return(inGetter(_self, thePropertyName)); };
        theSetterIMPBlock = ^(id _self, NSString *value) { inSetter(_self, thePropertyName, value); };
        }
    else if (theType[0] != '{')
        {
        if (strcmp(theType, @encode(short)) == 0)
            {
            theGetterIMPBlock = SIMPLE_GETTER(short, Short);
            theSetterIMPBlock = SIMPLE_SETTER(short, Short);
            }
        else if (strcmp(theType, @encode(int)) == 0)
            {
            theGetterIMPBlock = SIMPLE_GETTER(int, Int);
            theSetterIMPBlock = SIMPLE_SETTER(int, Int);
            }
        else if (strcmp(theType, @encode(float)) == 0)
            {
            theGetterIMPBlock = SIMPLE_GETTER(float, Float);
            theSetterIMPBlock = SIMPLE_SETTER(float, Float);
            }
        else if (strcmp(theType, @encode(double)) == 0)
            {
            theGetterIMPBlock = SIMPLE_GETTER(double, Double);
            theSetterIMPBlock = SIMPLE_SETTER(double, Double);
            }
        }
    else if (theType[0] == '{')
        {
        #if TARGET_OS_IPHONE == 0
        if (strcmp(theType, @encode(NSPoint)) == 0)
            {
            theGetterIMPBlock = STRUCT_GETTER(NSPoint);
            theSetterIMPBlock = STRUCT_SETTER(NSPoint);
            }
        #endif
        }

    // #####################################################################

    if (theGetterIMPBlock != NULL && inGetter != NULL)
        {
        IMP theGetterFunctionPtr = imp_implementationWithBlock((__bridge void *)theGetterIMPBlock);
        class_addMethod(inClass, NSSelectorFromString(theGetterName), theGetterFunctionPtr, [theGetterType UTF8String]);
        }

    if (theReadonlyFlag == NO && theSetterIMPBlock != NULL && inGetter != NULL)
        {
        IMP theSetterFunctionPtr = imp_implementationWithBlock((__bridge void *)theSetterIMPBlock);
        class_addMethod(inClass, NSSelectorFromString(theSetterName), theSetterFunctionPtr, [theSetterType UTF8String]);
        }

    return(YES);
    }


@end
