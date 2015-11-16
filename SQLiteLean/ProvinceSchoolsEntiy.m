//
//  ProvinceSchoolsEntiy.m
//  MSC
//
//  Created by shana on 14-8-7.
//  Copyright (c) 2014年 Wisorg. All rights reserved.
//

#import "ProvinceSchoolsEntiy.h"


@implementation ProvinceSchoolsEntiy

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.provinceName = @"";
        self.provinceCode = @"";
        self.schoolList = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"the province is:%@, the code is %@",self.provinceName,self.provinceCode];
}

@end
