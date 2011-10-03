//
//  CPropertyFactory.h
//  Test
//
//  Created by Jonathan Wight on 10/3/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

typedef id (^PropertyGetterBlock)(id _self, NSString *key);
typedef void (^PropertySetterBlock)(id _self, NSString *key, id value);

@interface CPropertyFactory : NSObject

- (BOOL)configure:(Class)inClass getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter;
- (BOOL)configure:(Class)inClass propertyName:(NSString *)inProperty getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter;
- (BOOL)configure:(Class)inClass property:(objc_property_t)inProperty getter:(PropertyGetterBlock)inGetter setter:(PropertySetterBlock)inSetter;


@end
