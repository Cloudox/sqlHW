//
//  LowOperateVC.m
//  sqlHM
//
//  Created by Cloudox on 15/10/19.
//  Copyright © 2015年 Cloudox. All rights reserved.
//

#import "LowOperateVC.h"

@interface LowOperateVC ()

@end

@implementation LowOperateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Low";
    
    if (!self.lowDB) {//判断数据库是否存在，不存在则创建数据库
        //获取文件路径
        NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dbFilePath = [docs[0] stringByAppendingPathComponent:@"lowDB.sqlite"];
        //获取或创建数据库
        self.lowDB = [FMDatabase databaseWithPath:dbFilePath];
    }
    if (![self.lowDB open]) {//判断数据库是否打开，没打开则提示失败
        NSLog(@"打开数据库失败");
        return;
    }
    [self.lowDB setShouldCacheStatements:YES];//为数据库设置缓存，提高查询效率
    
    if (!self.highDB) {//判断数据库是否存在，不存在则创建数据库
        //获取文件路径
        NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dbFilePath = [docs[0] stringByAppendingPathComponent:@"highDB.sqlite"];
        //获取或创建数据库
        self.highDB = [FMDatabase databaseWithPath:dbFilePath];
    }
    if (![self.highDB open]) {//判断数据库是否打开，没打开则提示失败
        NSLog(@"打开数据库失败");
        return;
    }
    [self.highDB setShouldCacheStatements:YES];//为数据库设置缓存，提高查询效率
}

- (IBAction)addData:(id)sender {
    if (![self.idText.text isEqualToString:@""] & ![self.nameText.text isEqualToString:@""] & ![self.missionText.text isEqualToString:@""]) {// 全不为空
        //向agent表中添加一行数据
        [self.lowDB executeUpdate:@"INSERT INTO agent (Agentid, Name, Mission) VALUES (?, ?, ?)", self.idText.text, self.nameText.text, self.missionText.text];
        NSLog(@"添加成功");
    }
}

- (IBAction)editData:(id)sender {
    if (![self.idText.text isEqualToString:@""]) {
        if (![self.nameText.text isEqualToString:@""] & ![self.missionText.text isEqualToString:@""]) {
            //修改
            [self.lowDB executeUpdate:@"UPDATE agent SET Name = (?) WHERE Agentid = (?) ", self.nameText.text, self.idText.text];
            [self.lowDB executeUpdate:@"UPDATE agent SET Mission = (?) WHERE Agentid = (?) ", self.missionText.text, self.idText.text];
            NSLog(@"修改成功");
        } else if (![self.nameText.text isEqualToString:@""]) {
            //修改
            [self.lowDB executeUpdate:@"UPDATE agent SET Name = (?) WHERE Agentid = (?) ", self.nameText.text, self.idText.text];
            NSLog(@"修改成功");
        } else if (![self.missionText.text isEqualToString:@""]) {
            //修改
            [self.lowDB executeUpdate:@"UPDATE agent SET Mission = (?) WHERE Agentid = (?) ", self.missionText.text, self.idText.text];
            NSLog(@"修改成功");
        }
        
    }
}

- (IBAction)deleteData:(id)sender {
    // 由于高级用户可以查看到所有低级数据，所以删除任意一条，都要在高级数据库中备份
    if (![self.idText.text isEqualToString:@""]) {
        // 检查高级数据库中有无此条数据
        FMResultSet *rshigh = [self.highDB executeQuery:@"SELECT * FROM agent WHERE Agentid = (?)", self.idText.text];
        if ([rshigh next]) {// 如果高级数据库有，则备份过去，只备份高级中为空的数据
            FMResultSet *rslow = [self.lowDB executeQuery:@"SELECT * FROM agent WHERE Agentid = (?)", self.idText.text];
            if ([[rshigh stringForColumn:@"Name"] isEqualToString:@""]) {
                while ([rslow next]) {
                    [self.highDB executeUpdate:@"UPDATE agent SET Name = (?) WHERE Agentid = (?) ", [rslow stringForColumn:@"Name"], self.idText.text];
                    NSLog(@"备份name");
                }
            }
            if ([[rshigh stringForColumn:@"Mission"] isEqualToString:@""]) {
                while ([rslow next]) {
                    NSLog(@"%@", [rslow stringForColumn:@"Mission"]);
                    [self.highDB executeUpdate:@"UPDATE agent SET Mission = (?) WHERE Agentid = (?) ", [rslow stringForColumn:@"Mission"], self.idText.text];
                    NSLog(@"备份mission");
                }
            }
        }
        
        //删除
        [self.lowDB executeUpdate:@"DELETE FROM agent WHERE Agentid = (?)", self.idText.text];
        NSLog(@"删除成功");
    }
//    else if (![self.nameText.text isEqualToString:@""]) {
//        //删除
//        [self.lowDB executeUpdate:@"DELETE FROM agent WHERE Name = (?)", self.nameText.text];
//        NSLog(@"删除成功");
//    } else if (![self.missionText.text isEqualToString:@""]) {
//        //删除
//        [self.lowDB executeUpdate:@"DELETE FROM agent WHERE Mission = (?)", self.missionText.text];
//        NSLog(@"删除成功");
//    }
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
