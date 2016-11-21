//
//  ScanDeviceListViewController.m
//  KYHAPDUTool
//
//  Created by 金玉衡 on 16/8/3.
//  Copyright © 2016年 金玉衡. All rights reserved.
//

#import "ScanDeviceListViewController.h"
#import "BarChart.h"

#define SEARCH_BLE_NAME   @"BLE_NFC"


@interface ScanDeviceListViewController() <DKBleManagerDelegate>
{
    NSMutableArray *_peripheralArray;
    UIActivityIndicatorView *_indicatorVC;
    NSMutableArray *_deviceArray;
    
}

@property (nonatomic, strong) DKBleManager     *bleManager;



@end

@implementation ScanDeviceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
//        [self setEdgesForExtendedLayout:UIRectEdgeNone];
//    
//    if ([self respondsToSelector:@selector( setAutomaticallyAdjustsScrollViewInsets:)]) {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    
    self.bleManager = [DKBleManager sharedInstance];
    self.bleManager.delegate = self;
    
    UIBarButtonItem *scanBar = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(ReScanDevice)];
    
    self.navigationItem.rightBarButtonItem = scanBar;
    
    UIBarButtonItem *backBar = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backup)];
    
    self.navigationItem.leftBarButtonItem = backBar;
    
    
    
    _peripheralArray = [NSMutableArray array];
    
    _deviceArray = [NSMutableArray array];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.

    [self stopscanDevice];
    [_indicatorVC stopAnimating];
    
    [super viewWillDisappear:animated];
}

- (void)backup
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) ReScanDevice
{
    
    [_peripheralArray removeAllObjects];
    [_deviceArray removeAllObjects];
    
    [self.tableView reloadData];
    
    [self stopscanDevice];
    [self scanDevice];
}

/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scanDevice
{
    [self.bleManager startScan];
}

-(void)stopscanDevice
{
    [self.bleManager stopScan];
    
}


/**
 *  CBCentralManagerDelegate
 *
 *  @param central
 */

#pragma mark - DKBleManagerDelegate
-(void)DKCentralManagerDidUpdateState:(CBCentralManager *)central {
    NSError *error = nil;
    switch (central.state) {
        case CBCentralManagerStatePoweredOn://蓝牙打开
        {
            //pendingInit = NO;
            //[self startToGetDeviceList];
            
            [self.bleManager startScan];
        }
            break;
        case CBCentralManagerStatePoweredOff://蓝牙关闭
        {
            error = [NSError errorWithDomain:@"CBCentralManagerStatePoweredOff" code:-1 userInfo:nil];
        }
            break;
        case CBCentralManagerStateResetting://蓝牙重置
        {
            //pendingInit = YES;
        }
            break;
        case CBCentralManagerStateUnknown://未知状态
        {
            error = [NSError errorWithDomain:@"CBCentralManagerStateUnknown" code:-1 userInfo:nil];
        }
            break;
        case CBCentralManagerStateUnsupported://设备不支持
        {
            error = [NSError errorWithDomain:@"CBCentralManagerStateUnsupported" code:-1 userInfo:nil];
        }
            break;
        default:
            break;
    }
}


/**
 * CBCentralManagerDelegate
 *
 *  @param central
 *  @param peripheral
 *  @param advertisementData
 *  @param RSSI
 */

- (float)getDistByRSSI:(int)rssi
{
    int iRssi = abs(rssi);
    float power = (iRssi-59)/(10*2.0);
    return pow(10, power);
}

/*
 * 函数说明：蓝牙搜索回调
 */
#pragma mark - DKBleManagerDelegate
-(void)DKScannerCallback:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([peripheral.name isEqualToString:SEARCH_BLE_NAME]) {
        NSLog(@"搜到设备：%@ %@", peripheral, RSSI);
        
    }
    
    if(peripheral.name != nil)
    {
        //float distance = [self getDistByRSSI:[RSSI intValue]];
        
        NSLog(@"didDiscoverPeripheral peripheral name is %@ RSSI is %@", peripheral.name, RSSI);
        
        NSDictionary *peripheralDic = @{peripheral.name: RSSI};
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:[_peripheralArray count] inSection:0];
        
        [_peripheralArray addObject:peripheralDic];
        
        [_deviceArray addObject:peripheral];
        
        [self.tableView beginUpdates];
        
        [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationRight];
        
        [self.tableView endUpdates];
    }

}


-(void)DKCentralManagerConnectState:(CBCentralManager *)central state:(BOOL)state
{
    if (state) {
        NSLog(@"蓝牙连接成功");
    }
    else {
        NSLog(@"蓝牙连接失败");

    }

}


/**
 *  tableview delegate
 *
 *  @param tableView
 *
 *  @return
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *strTitle = @"附件的蓝牙设备";
    
    return strTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView  *HeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX_WIDTH, 60)];
    HeadView.backgroundColor = [UIColor clearColor];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 100, 30)];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.textColor = [UIColor lightGrayColor];
    textLabel.text = @"附件的蓝牙设备";
    textLabel.font = [UIFont boldSystemFontOfSize:13];
    [HeadView addSubview:textLabel];
    
    UIActivityIndicatorView *indicatorVC = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorVC.frame = CGRectMake(110, 30, 30, 30);
    [HeadView addSubview:indicatorVC];
    
    _indicatorVC = indicatorVC;
    
    [_indicatorVC startAnimating];

    return HeadView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peripheralArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCell = @"BLECell";

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
    

    
    NSDictionary *peripheralDic = [_peripheralArray objectAtIndex:[indexPath row]];
    
    NSNumber *rssiNum = [peripheralDic allValues][0];
    
    float distance = [self getDistByRSSI:[rssiNum intValue]];
    
    BarChart *barCharVC = [[BarChart alloc] initWithFrame:CGRectMake(20, 15, 40, 20)];
    [cell.contentView addSubview:barCharVC];
    
    UILabel *textLB = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, cell.contentView.frame.size.width, 30)];
    
    textLB.font = [UIFont systemFontOfSize:16];
    textLB.text = [peripheralDic allKeys][0];
    textLB.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:textLB];
    
    
    barCharVC.barNum = [self getSignalWithDistance:distance];
    
    
    return cell;
}

-(void)movePosition:(CALayer *)layer fromValue:(CGFloat)numberfrom toValue:(CGFloat)numberto
{
    
    CABasicAnimation *anim =[CABasicAnimation animation];
    anim.keyPath =@"position.x";
    anim.fromValue =[NSNumber numberWithFloat:numberfrom];
    anim.toValue =[NSNumber numberWithFloat:numberto];
    anim.duration =0.2;//持续时间
    anim.repeatCount =1;//  重复的次数
    anim.speed =0.5;// 速度
    
    /**
     removedOnCompletion：默认为YES，代表动画执行完毕后就从图层上移除，图形会恢复到动画执行前的状态。如果想让图层保持显示动画执行后的状态，那就设置为NO，不过还要设置fillMode为
     
     Autoreverses 当设置为yes 时候在他达到目的地时候，取代原来的值
     
     timingFunction   各种状态的设置
     
     fillMode  决定当前对象在非active时间段的行为，比如动画开始之前，动画结束之后
     kCAFillModeRemoved   默认值，动画开始和结束后，对layer没有影响，动画结束后恢复之前
     kCAFillModeForwards  动画结束后，保持最后的状态
     kCAFillModeBackwards 动画添加到layer之上，便处于动画初始状态
     kCAFillModeBoth      动画添加到layer之上，便处于动画初始状态，完成之后保持最后的状态
     */
    anim.fillMode  =kCAFillModeForwards ;
    
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:anim forKey:@"position"];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    unsigned long row = [indexPath row];
    
    NSDictionary *peripheralDic = [_peripheralArray objectAtIndex:row];
    
    __block  CBPeripheral *selectedPeripheral = [_deviceArray objectAtIndex:row];
    
    //[[NSUserDefaults standardUserDefaults] setObject:strPeripheral forKey:BLE_NAME];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    
        [self.bleManager connect:selectedPeripheral callbackBlock:^(BOOL isConnectSucceed) {
            
            if(self.DidCheckBLEDevice)
            {
                self.DidCheckBLEDevice(isConnectSucceed);
                
            }
            
            if (isConnectSucceed) {
                //设备连接成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"success");
                    
                });
            }
            else {
                //设备连接失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"failed");
                });
            }
        }];

    
    
    });
}

- (int)getSignalWithDistance:(float)distance
{
    int signal = 0;
    if(distance > 0)
    {
        if(distance < 5)
        {
            signal = 5;
        }
        else if(distance < 30)
        {
            signal = 4;
        }
        else if(distance < 100)
        {
            signal = 3;
        }
        else if(distance < 500)
        {
            signal = 2;
        }
        else if(distance < 5000)
        {
            signal = 1;
        }
        else
        {
            signal = 0;
        }
    
    }
    return signal;
}

@end
