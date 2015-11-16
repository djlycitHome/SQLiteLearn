//
//  UserEntity.h
//  SQLiteLean
//
//  Created by shana on 15/11/16.
//  Copyright © 2015年 jianlong ding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserEntity : NSObject
@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, copy) NSString  *userId;
@property (nonatomic, copy) NSString  *userName;
@property (nonatomic, copy) NSString  *birthday;
@property (nonatomic, copy) NSString  *city;
@end
