//
//  ScanDeviceListViewController.h
//  KYHAPDUTool
//
//  Created by 金玉衡 on 16/8/3.
//  Copyright © 2016年 金玉衡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRBaseTableViewController.h"

@interface ScanDeviceListViewController : NRBaseTableViewController

@property (nonatomic, copy) void (^DidCheckBLEDevice)(BOOL isConnect);

@end
