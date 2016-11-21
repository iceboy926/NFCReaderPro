//
//  BaseTableViewController.h
//  KYHAPDUTool
//
//  Created by 金玉衡 on 16/6/2.
//  Copyright © 2016年 金玉衡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NRBaseTableViewController : UITableViewController

-(void)showWait;

-(void)showWait:(NSString *)mas;

-(void)hideWait;

-(void)showAlert:(NSString *)msg;

-(void)showAlert:(NSString *)title message:(NSString *)msg delegate:(id)delegate tag:(int)tag;

@end
