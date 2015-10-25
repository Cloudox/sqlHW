//
//  HighLoginVC.m
//  sqlHM
//
//  Created by Cloudox on 15/10/19.
//  Copyright © 2015年 Cloudox. All rights reserved.
//

#import "HighLoginVC.h"
#import "HighDataVC.h"

@interface HighLoginVC ()

@end

@implementation HighLoginVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UITabBarItem *item = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemContacts tag:2];//设置tabbar样式
    self.tabBarItem = item;
    
    if (!self.highDB) {//判断数据库是否存在，不存在则创建数据库
        //获取文件路径
        NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dbFilePath = [docs[0] stringByAppendingPathComponent:@"highDB.sqlite"];
        //获取或创建数据库
        self.highDB = [FMDatabase databaseWithPath:dbFilePath];
    }
    if (![self.highDB open]) {//判断数据库是否打开，没打开则提示失败
        NSLog(@"打开数据库失败");
        return self;
    }
    [self.highDB setShouldCacheStatements:YES];//为数据库设置缓存，提高查询效率
    
    if (![self.highDB tableExists:@"user"]) {//判断user表是否存在，不存在则创建表
        //这里给id设置为自增并且为key
        [self.highDB executeUpdate:@"CREATE TABLE user(_id INTEGER PRIMARY KEY, Username VARCHAR(50), Password VARCHAR(50))"];
        NSLog(@"创建user表成功");
    
        //向user表中添加一行用户名和密码分别为Cloudox和123456的数据
        [self.highDB executeUpdate:@"INSERT INTO user (Username, Password) VALUES (?, ?)", @"high", @"123"];
        NSLog(@"添加数据成功");
    }
    if (![self.highDB tableExists:@"agent"]) {//判断agent表是否存在，不存在则创建表
        //这里给id设置为自增并且为key
        [self.highDB executeUpdate:@"CREATE TABLE agent(_id INTEGER PRIMARY KEY, Agentid VARCHAR(10), Name VARCHAR(50), Mission VARCHAR(50))"];
        NSLog(@"创建agent表成功");
    }
    if (![self.highDB tableExists:@"deletelow"]) {//存储删除的在低级数据库中的数据id
        //这里给id设置为自增并且为key
        [self.highDB executeUpdate:@"CREATE TABLE deletelow(_id INTEGER PRIMARY KEY, Agentid VARCHAR(10))"];
        NSLog(@"创建deletelow表成功");
    }
    
//        //向agent表中添加一行数据
//        [self.highDB executeUpdate:@"INSERT INTO agent (Agentid, Name, Mission) VALUES (?, ?, ?)", @"001", @"agent1", @"Kill"];
//        //向agent表中添加一行数据
//        [self.highDB executeUpdate:@"INSERT INTO agent (Agentid, Name, Mission) VALUES (?, ?, ?)", @"002", @"agent2", @"back"];
//        NSLog(@"添加数据成功");
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"High";
    }

// 登陆
- (IBAction)login:(id)sender {
    FMResultSet *rs = [self.highDB executeQuery:@"SELECT * FROM user WHERE Username = (?)", self.username.text];
    //循环读取所有搜索到的数据获取想要的列信息，这里只有一行，获取对应的密码
    while ([rs next]) {
        if ([self.password.text isEqualToString:[rs stringForColumn:@"Password"]]) {
            NSLog(@"login");
            HighDataVC *highDataVC = [[HighDataVC alloc] initWithNibName:@"HighDataVC" bundle:nil];
            [self.navigationController pushViewController:highDataVC animated:YES];
        }
    }
    
//    HighDataVC *highDataVC = [[HighDataVC alloc] initWithNibName:@"HighDataVC" bundle:nil];
//    [self.navigationController pushViewController:highDataVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
