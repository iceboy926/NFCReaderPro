//
//  BaseTableViewController.m
//  KYHAPDUTool
//
//  Created by 金玉衡 on 16/6/2.
//  Copyright © 2016年 金玉衡. All rights reserved.
//

#import "NRBaseTableViewController.h"


@interface NRBaseTableViewController () <UIAlertViewDelegate>
{
    UIView *activeView;
    
}

@end

@implementation NRBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    self.view.backgroundColor = backGroundColor;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showWait
{
    [SVProgressHUD showWithStatus:@"加载中..."];

}

-(void)showWait:(NSString *)mas
{
    [SVProgressHUD showWithStatus:mas];
}

-(void)hideWait
{
    [SVProgressHUD dismiss];
}


-(void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];

}

-(void)showAlert:(NSString *)title message:(NSString *)msg delegate:(id)delegate tag:(int)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    alert.tag = tag;
    
    [alert show];
}




@end
