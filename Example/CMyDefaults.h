//
//  CMyDefaults.h
//  Test
//
//  Created by Jonathan Wight on 10/3/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMyDefaults : NSObject

@property (readwrite, nonatomic, retain) NSString *name;
@property (readwrite, nonatomic, assign) NSTimeInterval timestamp;
@property (readwrite, nonatomic, assign) NSPoint position;

@end
