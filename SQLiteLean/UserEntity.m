//
//  UserEntity.m
//  SQLiteLean
//
//  Created by shana on 15/11/16.
//  Copyright © 2015年 jianlong ding. All rights reserved.
//

#import "UserEntity.h"

@implementation UserEntity

- (NSString *)description{
    return [NSString stringWithFormat:@"the pid is:%@, the userId is %@, the userName is %@, the country is %@", @(self.pid), self.userId, self.userName, self.country];
}
@end
