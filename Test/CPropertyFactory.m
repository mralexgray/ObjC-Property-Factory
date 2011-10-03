//
//  CPropertyFactory.m
//  Test
//
//  Created by Jonathan Wight on 10/3/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CPropertyFactory.h"

#import <objc/runtime.h>

@implementation CPropertyFactory

- (BOOL)configure:(Class)inClass getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter
    {
    unsigned int thePropertyCount = 0;
    objc_property_t *theProperties = class_copyPropertyList(inClass, &thePropertyCount);
    
    for (unsigned int thePropertyIndex = 0; thePropertyIndex != thePropertyCount; ++thePropertyIndex)
        {
        [self configure:inClass property:theProperties[thePropertyIndex] getter:inGetter setter:inSetter];
        }

    return(YES);
    }

- (BOOL)configure:(Class)inClass propertyName:(NSString *)inProperty getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter
    {
    return(NO);
    }
    
- (BOOL)configure:(Class)inClass property:(objc_property_t)inProperty getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter
    {
//        NSLog(@"%s", property_getName(theProperties[thePropertyIndex]));

    BOOL theDynamicFlag = NO;
    BOOL theReadonlyFlag = NO;
    BOOL theNonAtomicFlag = NO;
    const char *theType = NULL;

    unsigned int theAttributeCount = 0;
    #warning We're copying - so we need to free() this?
    objc_property_attribute_t *theAttributes = property_copyAttributeList(inProperty, &theAttributeCount);

    // See http://developer.apple.com/library/ios/#DOCUMENTATION/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html for all flags.
    for (unsigned int theAttributeIndex = 0; theAttributeIndex != theAttributeCount; ++theAttributeIndex)
        {
//            NSLog(@"\t'%s' = '%s'", theAttributes[theAttributeIndex].name, theAttributes[theAttributeIndex].value);
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

    if (theDynamicFlag == NO)
        {
        NSLog(@"Cannot create IMPs for non-dynamic properties");
        return(NO);
        }

    NSString *thePropertyName = [NSString stringWithUTF8String:property_getName(inProperty)];
    NSString *theGetterName = thePropertyName;
    NSString *theSetterName = [NSString stringWithFormat:@"set%@%@:", [[thePropertyName substringToIndex:1] uppercaseString], [thePropertyName substringFromIndex:1]];

    NSString *theGetterType = [NSString stringWithFormat:@"%s@:", theType];
    NSString *theSetterType = [NSString stringWithFormat:@"v@:%s", theType];

    id theGetterBlock = NULL;
    id theSetterBlock = NULL;

    // #####################################################################

    if (theType[0] == '@')
        {
        theGetterBlock = ^(id _self)
            {
            id theValue = inGetter(_self, thePropertyName);
            return(theValue);
            };
        theSetterBlock = ^(id _self, NSString *value)
            {
            inSetter(_self, thePropertyName, value);
            };
        }
    else
        {
        if (strcmp(theType, @encode(int)) == 0)
            {
            theGetterBlock = ^(id _self)
                {
                id theValue = inGetter(_self, thePropertyName);
                return([theValue intValue]);
                };
            theSetterBlock = ^(id _self, int value)
                {
                id theValue = [NSNumber numberWithInt:value];
                [_self setObject:theValue forKey:thePropertyName];
                };
            }
        else if (strcmp(theType, @encode(double)) == 0)
            {
            theGetterBlock = ^(id _self)
                {
                id theValue = inGetter(_self, thePropertyName);
                return([theValue doubleValue]);
                };
            theSetterBlock = ^(id _self, double value)
                {
                id theValue = [NSNumber numberWithDouble:value];
                [_self setObject:theValue forKey:thePropertyName];
                };
            }
        }

    // #####################################################################

    if (theGetterBlock != NULL)
        {
        IMP theGetterFunctionPtr = imp_implementationWithBlock((__bridge void *)theGetterBlock);
        class_addMethod(inClass, NSSelectorFromString(theGetterName), theGetterFunctionPtr, [theGetterType UTF8String]);
        }

    if (theReadonlyFlag == NO && theSetterBlock != NULL)
        {
        IMP theSetterFunctionPtr = imp_implementationWithBlock((__bridge void *)theSetterBlock);
        class_addMethod(inClass, NSSelectorFromString(theSetterName), theSetterFunctionPtr, [theSetterType UTF8String]);
        }

    return(YES);
    }


@end
