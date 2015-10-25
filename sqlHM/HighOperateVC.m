//
//  HighOperateVC.m
//  sqlHM
//
//  Created by Cloudox on 15/10/19.
//  Copyright © 2015年 Cloudox. All rights reserved.
//

#import "HighOperateVC.h"

@interface HighOperateVC ()

@end

@implementation HighOperateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"High";
    
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
        [self.highDB executeUpdate:@"INSERT INTO agent (Agentid, Name, Mission) VALUES (?, ?, ?)", self.idText.text, self.nameText.text, self.missionText.text];
        NSLog(@"添加成功");
    }
}

- (IBAction)editData:(id)sender {
    if (![self.idText.text isEqualToString:@""]) {// id一定不能为空
        // 检查高级数据库中有无此条数据
        FMResultSet *rshigh = [self.highDB executeQuery:@"SELECT * FROM agent WHERE Agentid = (?)", self.idText.text];
        if ([rshigh next]) {// 高级数据库有此条数据
            if (![self.nameText.text isEqualToString:@""] & ![self.missionText.text isEqualToString:@""]) {
                //修改
                [self.highDB executeUpdate:@"UPDATE agent SET Name = (?) WHERE Agentid = (?) ", self.nameText.text, self.idText.text];
                [self.highDB executeUpdate:@"UPDATE agent SET Mission = (?) WHERE Agentid = (?) ", self.missionText.text, self.idText.text];
                NSLog(@"修改成功");
            } else if (![self.nameText.text isEqualToString:@""]) {
                //修改
                [self.highDB executeUpdate:@"UPDATE agent SET Name = (?) WHERE Agentid = (?) ", self.nameText.text, self.idText.text];
                NSLog(@"修改成功");
            } else if (![self.missionText.text isEqualToString:@""]) {
                //修改
                [self.highDB executeUpdate:@"UPDATE agent SET Mission = (?) WHERE Agentid = (?) ", self.missionText.text, self.idText.text];
                NSLog(@"修改成功");
            }
        } else {// 没有，数据在低级中，需要添加数据
            if (![self.nameText.text isEqualToString:@""] & ![self.missionText.text isEqualToString:@""]) {
                [self.highDB executeUpdate:@"INSERT INTO agent (Agentid, Name, Mission) VALUES (?, ?, ?)", self.idText.text, self.nameText.text, self.missionText.text];
                NSLog(@"添加成功（高级数据库无数据）");
            } else if (![self.nameText.text isEqualToString:@""]) {
                [self.highDB executeUpdate:@"INSERT INTO agent (Agentid, Name, Mission) VALUES (?, ?, ?)", self.idText.text, self.nameText.text, @""];
                NSLog(@"添加成功（高级数据库无数据）");
            } else if (![self.missionText.text isEqualToString:@""]) {
                [self.highDB executeUpdate:@"INSERT INTO agent (Agentid, Name, Mission) VALUES (?, ?, ?)", self.idText.text, @"", self.missionText.text];
                NSLog(@"添加成功（高级数据库无数据）");
            }
        }
        
        
        
    }
}

- (IBAction)deleteData:(id)sender {
    if (![self.idText.text isEqualToString:@""]) {
        // 检查高级数据库中有无此条数据
        FMResultSet *rshigh = [self.highDB executeQuery:@"SELECT * FROM agent WHERE Agentid = (?)", self.idText.text];
        if ([rshigh next]) {// 高级数据库有此条数据
            //删除
            [self.highDB executeUpdate:@"DELETE FROM agent WHERE Agentid = (?)", self.idText.text];
            NSLog(@"删除成功");
            [self.highDB executeUpdate:@"INSERT INTO deletelow (Agentid) VALUES (?)", self.idText.text];
            NSLog(@"在deletelow表中注明不再看见");
        } else {// 数据在低级数据库中，需要说明此后不再查询到低级中的此条数据
            [self.highDB executeUpdate:@"INSERT INTO deletelow (Agentid) VALUES (?)", self.idText.text];
            NSLog(@"在deletelow表中注明不再看见");
        }
        
    }
//    else if (![self.nameText.text isEqualToString:@""]) {
//        //删除
//        [self.highDB executeUpdate:@"DELETE FROM agent WHERE Name = (?)", self.nameText.text];
//        NSLog(@"删除成功");
//    } else if (![self.missionText.text isEqualToString:@""]) {
//        //删除
//        [self.highDB executeUpdate:@"DELETE FROM agent WHERE Mission = (?)", self.missionText.text];
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
