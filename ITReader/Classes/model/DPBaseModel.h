//
//  DPBaseModel.h
//  Longan
//
//  Created by haowenliang on 14-5-10.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface DPBaseModel : JSONModel<NSCoding>

-(void)encodeWithCoder:(NSCoder *)encoder;
-(id)initWithCoder:(NSCoder *)decoder;

- (NSString *)DPDescription;

@end
