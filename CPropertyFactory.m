//
//  CPropertyFactory.m
//  Test
//
//  Created by Jonathan Wight on 10/3/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CPropertyFactory.h"

#import <objc/runtime.h>

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
            theGetterIMPBlock = ^(id _self) { return([inGetter(_self, thePropertyName) shortValue]); };
            theSetterIMPBlock = ^(id _self, short value) { inSetter(_self, thePropertyName, [NSNumber numberWithShort:value]); };
            }
        if (strcmp(theType, @encode(int)) == 0)
            {
            theGetterIMPBlock = ^(id _self) { return([inGetter(_self, thePropertyName) intValue]); };
            theSetterIMPBlock = ^(id _self, int value) { inSetter(_self, thePropertyName, [NSNumber numberWithInt:value]); };
            }
        else if (strcmp(theType, @encode(float)) == 0)
            {
            theGetterIMPBlock = ^(id _self) { return([inGetter(_self, thePropertyName) floatValue]); };
            theSetterIMPBlock = ^(id _self, float value) { inSetter(_self, thePropertyName, [NSNumber numberWithFloat:value]); };
            }
        else if (strcmp(theType, @encode(double)) == 0)
            {
            theGetterIMPBlock = ^(id _self) { return([inGetter(_self, thePropertyName) doubleValue]); };
            theSetterIMPBlock = ^(id _self, double value) { inSetter(_self, thePropertyName, [NSNumber numberWithDouble:value]); };
            }
        }
    else if (theType[0] == '{')
        {
        #if TARGET_OS_IPHONE == 0
        if (strcmp(theType, @encode(NSPoint)) == 0)
            {
            theGetterIMPBlock = ^(id _self) { NSPoint value; [inGetter(_self, thePropertyName) getValue:&value]; return(value); };
            theSetterIMPBlock = ^(id _self, NSPoint value) { inSetter(_self, thePropertyName, [NSValue valueWithBytes:&value objCType:@encode(NSPoint)]); };
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
