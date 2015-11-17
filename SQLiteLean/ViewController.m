//
//  ViewController.m
//  SQLiteLean
//
//  Created by jianlong ding on 15/11/9.
//  Copyright © 2015年 jianlong ding. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "ProvinceSchoolsEntiy.h"
#import "UserEntity.h"

#define DOCUMENTS                   @"Documents"
#define DOCUMENT_FOLDER             [NSHomeDirectory() stringByAppendingPathComponent:DOCUMENTS]

NSString *const     FILES_DB                     =  @"msc.db";
NSString *const     DATABASE_FILE_NAME           =  @"msc";
NSString *const     DATABASE_RESOURCE_TYPE       =  @"db";

NSString *const     WALLET_DB                    =  @"wallet.db";
NSString *const     WALLET_DB_FILE_NAME          =  @"wallet";

NSUInteger const    PAGE_NUMBER                  = 3;

@interface ViewController ()
@property (nonatomic, strong)FMDatabase *db;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //简单应用
    [self simple];
    
    //复杂应用
    [self complex];
    
}

#pragma mark - simple
//简单应用
- (void)simple{
    //从plist拷贝数据库文件
    [self createEditableDatabase];
    
    //查询数据
    NSArray *values = [self provinces];
    NSLog(@"the value is %@",values);
    
    //关闭数据库
    [self close_DB];
}

- (void)createEditableDatabase
{
    NSString *writableDBPath = [DOCUMENT_FOLDER stringByAppendingPathComponent:FILES_DB];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    BOOL success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) {
        //        [fileManager removeItemAtPath:writablePlistPath error:nil];
        return;
    };
    
    // The writable plist does not exist, so copy the default to the appropriate location.
    NSString *defaultPlistPath = [[NSBundle mainBundle] pathForResource:DATABASE_FILE_NAME ofType:DATABASE_RESOURCE_TYPE];
    //NSString *defaultPlistPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabaseName];
    
    NSError *error;
    success = [fileManager copyItemAtPath:defaultPlistPath toPath:writableDBPath error:&error];
    if (!success)
    {
        NSAssert1(0, @"Failed to create writable image cache plist file with message '%@'.", [error localizedDescription]);
    }
    
    //打开数据库文件
    [self open_DBWithPath:writableDBPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)open_DBWithPath:(NSString *) filePath{
    BOOL ret = false;
    self.db = [FMDatabase databaseWithPath:filePath];
    
    if (![self.db open])
    {
        NSLog(@"Open database error!");
    }else{
        ret = YES;
    }
    
    return ret;
}

- (void)close_DB{
    [self.db close];
}

-(NSArray *)provinces
{
    NSString *sql = @"select * from t_code_district where LEV_DISTRICT = 1";
    NSMutableArray *districtArray = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [self.db executeQuery:sql];
    
    while ([rs next]) {
        ProvinceSchoolsEntiy *province = [[ProvinceSchoolsEntiy alloc] init];
        province.provinceName = [rs stringForColumn:@"NAME_DISTRICT"];
        province.provinceCode = [rs stringForColumn:@"CODE_DISTRICT"];
        [districtArray addObject:province];
    }
    [rs close];
    
    return districtArray;
}

#pragma complex
- (void)complex{
    //创建数据库--------1
    [self createWalletDatabase];
    
    //创建表-----------2
    [self createTable];
    
    //创建数据
    NSArray *userList = [self createData];
    
    //插入数据----------3
    [self saveUserList:userList];
    
    //查询-------------4
    NSArray *users = [self getUsersWithLimitStart:3];
    NSLog(@"the users are %@",users);
    
    //修改表结构--------5
    [self alterUserTable];
    
    //查询新数据-------6
    NSArray *newUsers = [self getNewUsersWithLimitStart:3];
    NSLog(@"the new users are %@",newUsers);
}

//创建数据库
- (BOOL)createWalletDatabase{
    BOOL ret = false;
    NSString *writableDBPath = [DOCUMENT_FOLDER stringByAppendingPathComponent:WALLET_DB];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) {
         //存在先删除吧
         [fileManager removeItemAtPath:writableDBPath error:nil];
    };
    
    //打开数据库文件,不存在则创建
    ret = [self open_DBWithPath:writableDBPath];
    return ret;
}

//创建表
- (BOOL)createTable{
    BOOL ret = false;
    
    NSString *strCreatUsertable = [NSString stringWithFormat:
                                   @"create table if not exists T_User\n"
                                   "(pid INTEGER PRIMARY KEY AUTOINCREMENT,\n"
                                   "userId VARCHAR(20) NOT NULL UNIQUE,\n"
                                   "userName VARCHAR(64) NOT NULL,\n"
                                   "birthday VARCHAR(64),\n"
                                   "city VARCHAR(20))\n"
                                   ];
    NSLog(@"%@",strCreatUsertable);
    
    ret = [self.db executeUpdate:strCreatUsertable];
    return ret;
}

- (BOOL)saveUserList:(NSArray *) userList{
    BOOL ret = false;
    [self.db beginTransaction];
    for (UserEntity *userEntity in userList)
    {
        [self.db executeUpdate:@"insert or replace into T_User(userId,userName,birthday,city) VALUES(?,?,?,?)",userEntity.userId, userEntity.userName, userEntity.birthday,userEntity.city,nil];
    }
    ret = [self.db commit];
    
    return ret;
}

//创建数据
- (NSArray *)createData{
    UserEntity *user1 = [[UserEntity alloc]init];
    user1.userId = @"A001";
    user1.userName = @"小明";
    user1.birthday = @"1985-02-01";
    user1.city = @"北京";
    
    UserEntity *user2 = [[UserEntity alloc]init];
    user2.userId = @"A002";
    user2.userName = @"小红";
    user2.birthday = @"1986-03-15";
    user2.city = @"南京";
    
    UserEntity *user3 = [[UserEntity alloc]init];
    user3.userId = @"A003";
    user3.userName = @"花花";
    user3.birthday = @"1984-10-18";
    user3.city = @"东京";
    
    UserEntity *user4 = [[UserEntity alloc]init];
    user4.userId = @"A004";
    user4.userName = @"阿黄";
    user4.birthday = @"1988-12-01";
    user4.city = @"天京";
    
    UserEntity *user5 = [[UserEntity alloc]init];
    user5.userId = @"A005";
    user5.userName = @"大白";
    user5.birthday = @"1990-02-01";
    user5.city = @"上海";
    
    UserEntity *user6 = [[UserEntity alloc]init];
    user6.userId = @"A005";
    user6.userName = @"大白";
    user6.birthday = @"1990-02-01";
    user6.city = @"上海";
    
    return @[user1, user2, user3, user4, user5];
}


//获取当前最大的pid
- (int)getMaxPid{
    int pid = 0;
    NSString *sql = @"select pid from sqlite_sequence where name = 'T_User'";
    
    FMResultSet *rs = [self.db executeQuery:sql];
    
    while ([rs next])
    {
        pid = [rs intForColumn:@"pid"];
    }
    
    [rs close];
    
    return pid;
}

//查询数据
- (NSArray *)getUsersWithLimitStart:(int) index{

    NSString *sql = @"select pid, userId, userName, birthday, city from T_User limit ?, ?";
    NSMutableArray *districtArray = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [self.db executeQuery:sql,@(index),@(PAGE_NUMBER)];
    while ([rs next]) {
        UserEntity *user = [[UserEntity alloc] init];
        user.pid = [rs intForColumn:@"pid"];
        user.userId = [rs stringForColumn:@"userId"];
        user.userName = [rs stringForColumn:@"userName"];
        user.birthday = [rs stringForColumn:@"birthday"];
        user.city = [rs stringForColumn:@"city"];
        [districtArray addObject:user];
    }
    [rs close];
    
    return districtArray;
}

//修改表结构
- (BOOL)alterUserTable{
        
    BOOL ret = FALSE;

    NSString *strAlterUserTable = [NSString stringWithFormat:
                                              @"ALTER TABLE T_User ADD country VARCHAR(64) default '中国';"
                                              ];
    ret = [self.db executeUpdate:strAlterUserTable];
        
    
    return ret;
}

//查询数据
- (NSArray *)getNewUsersWithLimitStart:(int) index{
    
    NSString *sql = @"select pid, userId, userName, birthday, city, country from T_User limit ?, ?";
    NSMutableArray *districtArray = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [self.db executeQuery:sql,@(index),@(PAGE_NUMBER)];
    while ([rs next]) {
        UserEntity *user = [[UserEntity alloc] init];
        user.pid = [rs intForColumn:@"pid"];
        user.userId = [rs stringForColumn:@"userId"];
        user.userName = [rs stringForColumn:@"userName"];
        user.birthday = [rs stringForColumn:@"birthday"];
        user.city = [rs stringForColumn:@"city"];
        user.country = [rs stringForColumn:@"country"];
        [districtArray addObject:user];
    }
    [rs close];
    
    return districtArray;
}

@end
