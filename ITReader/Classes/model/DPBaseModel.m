//
//  DPBaseModel.m
//  ericDemo
//
//  Created by haowenliang on 14-5-8.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBaseModel.h"
#include <objc/runtime.h>

@implementation DPBaseModel
// 一个class所包含的变量信息，存在ivars当中。
// Ivar包含有变量的信息，名字，类型，及距离一个对象实例本身地址的偏移。
// 比如DODog就含有四个变量, name, year, size, point。
// 取得每个ivar所代表的变量的值，然后将其encode，就可以完成序列化。
- (void)encodeWithCoder:(NSCoder *)encoder {
    Class cls = [self class];
    while (cls != [NSObject class]) {
        unsigned int numberOfIvars = 0;
        // 取得当前class的Ivar数组
        Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
        for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
        {
            Ivar const ivar = *p;
            // 得到ivar的类型
            const char *type = ivar_getTypeEncoding(ivar);
            // 取得它的名字，比如"year", "name".
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if (nil == key || 0 == key.length) {
                continue;
            }
            // 取得某个key所对应的值
            id value = [self valueForKey:key];
            if (value) {
                switch (type[0]) {
                        // 如果是结构体的话，将其转化为NSData，然后encode.
                        // 其实cocoa会自动将CGRect等四种结构转化为NSValue，能够直接用value encode.
                        // 但其他结构体就不可以，所以还是需要我们手动转一下.
                    case _C_STRUCT_B: {
                        NSUInteger ivarSize = 0;
                        NSUInteger ivarAlignment = 0;
                        // 取得变量的大小
                        NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                        // ((const char *)self + ivar_getOffset(ivar))指向结构体变量
                        NSData *data = [NSData dataWithBytes:(const char *)self + ivar_getOffset(ivar) length:ivarSize];
                        [encoder encodeObject:data forKey:key];
                    }break;
                        // 如果是其他数据结构，也与处理结构体类似，未实现。
                        // case _C_CHR:    {
                        //}
                        // break;
                    default:
                        [encoder encodeObject:value forKey:key];
                        break;
                }
            }
        }
        if (ivars) {
            free(ivars);
        }
        cls = class_getSuperclass(cls);
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    // NSObject没有super，所以用了只能用self，应该没什么问题。
    // 因为[self init]内部必然会调用[super init], 如果一个class有super的话。
    // 这是我的理解，不知道对不对。
    self = [self init];
    if (self) {
        Class cls = [self class];
        while (cls != [NSObject class]) {
            unsigned int numberOfIvars = 0;
            Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
            for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
            {
                Ivar const ivar = *p;
                const char *type = ivar_getTypeEncoding(ivar);
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if (nil == key || 0 == key.length) {
                    continue;
                }
                id value = [decoder decodeObjectForKey:key];
                if (value) {
                    switch (type[0]) {
                        case _C_STRUCT_B: {
                            NSUInteger ivarSize = 0;
                            NSUInteger ivarAlignment = 0;
                            NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                            NSData *data = [decoder decodeObjectForKey:key];
                            char *sourceIvarLocation = (char*)self+ ivar_getOffset(ivar);
                            [data getBytes:sourceIvarLocation length:ivarSize];
                            // 在10.1号我碰到一个很奇怪的问题， 在这个方法内部，我能正确的设置结构体的值。
                            // 但是当self被返回后再打印结构体却是（0， 0）；
                            // 我也不知道如何解决，就加了个memcpy函数，实际上什么都没干，自己copy自己。
                            // 但是值却被正确的带出了。
                            // 现在我去掉这个函数，也能正常工作。所以很奇怪，大家看看吧，不知道还会不会出现问题
                            //
                            memcpy((char *)self + ivar_getOffset(ivar), sourceIvarLocation, ivarSize);
                        }break;
                        default:
                            [self setValue:[decoder decodeObjectForKey:key] forKey:key];
                            break;
                            
                    }
                }
            }
            
            if (ivars) {
                free(ivars);
            }
            cls = class_getSuperclass(cls);
        }
    }
    return self;
}


- (NSString *)DPDescription
{
    Class cls = [self class];
    
    NSMutableString* des = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"\n\n%@ : {",NSStringFromClass(cls)]];
    
    while (cls != [NSObject class]) {
        unsigned int numberOfIvars = 0;
        // 取得当前class的Ivar数组
        Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
        for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
        {
            Ivar const ivar = *p;
            
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if (nil == key || 0 == key.length) {
                continue;
            }
            // 取得某个key所对应的值
            id value = [self valueForKey:key];
            if (value) {
                [des appendString:[NSString stringWithFormat:@"\n\t%@: %@",key, value]];
            }
        }
        if (ivars) {
            free(ivars);
        }
        cls = class_getSuperclass(cls);
    }

    [des appendString:@"\n}\n "];
    
    return [des autorelease];
}

@end
