//
//  ViewController.m
//  NFCReaderPro
//
//  Created by 金玉衡 on 16/11/21.
//
//

#import "MainViewController.h"
#import "ScanDeviceListViewController.h"
#import "WebViewController.h"

@interface MainViewController ()

@property (nonatomic, strong)UIButton *bleManagerBtn;
@property (nonatomic, strong) DKDeviceManager  *deviceManager;
@property (nonatomic, strong) NSMutableString  *msgBuffer;
@property (nonatomic, strong)UITextView *msgTextView;
@property (nonatomic, strong) UIButton *readerCardBtn;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.view addSubview:self.bleManagerBtn];
    [self.view addSubview:self.msgTextView];
    [self.view addSubview:self.readerCardBtn];

    [self setupNavigationView];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addUIConstraints];
}


- (void)setupNavigationView
{
    self.view.backgroundColor = backGroundColor;
    [self setTitle:@"NFCReader"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ui layout

- (void)addUIConstraints
{
    [self.bleManagerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 50));
        
    }];
    
    [self.msgTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_bleManagerBtn.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.3);
    }];
    
    [self.readerCardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_msgTextView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 50));
        
    }];
}

#pragma mark lazy load

- (UIButton *)bleManagerBtn
{
    if(_bleManagerBtn == nil)
    {
        _bleManagerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_bleManagerBtn setTitle:@"查找蓝牙设备" forState:UIControlStateNormal];
        [_bleManagerBtn setTitleColor:navigaterBarColor forState:UIControlStateNormal];
        [_bleManagerBtn setBackgroundColor:[UIColor clearColor]];
        
        [_bleManagerBtn addTarget:self action:@selector(bleManangerClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _bleManagerBtn;
}

- (UITextView *)msgTextView
{
    if(_msgTextView == nil)
    {
        _msgTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        
        _msgTextView.textColor = navigaterBarColor;

    }
    
    return _msgTextView;
}

- (UIButton *)readerCardBtn
{
    if(_readerCardBtn == nil)
    {
        _readerCardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_readerCardBtn setTitle:@"读卡操作" forState:UIControlStateNormal];
        [_readerCardBtn setTitleColor:navigaterBarColor forState:UIControlStateNormal];
        [_readerCardBtn setBackgroundColor:[UIColor clearColor]];
        [_readerCardBtn addTarget:self action:@selector(readerCardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _readerCardBtn;
}

- (DKDeviceManager *)deviceManager
{
    if(_deviceManager == nil)
    {
        _deviceManager = [[DKDeviceManager alloc] init];
        
    }
    
    return _deviceManager;
}

- (NSMutableString *)msgBuffer
{
    if(_msgBuffer == nil)
    {
        _msgBuffer = [[NSMutableString alloc] init];
    }
    
    return _msgBuffer;
}


#pragma mark 

- (void)bleManangerClicked:(UIButton *)sender
{
    
    ScanDeviceListViewController *scanDeviceVC = [[ScanDeviceListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    scanDeviceVC.title = @"蓝牙设备";
    
    scanDeviceVC.DidCheckBLEDevice = ^(BOOL blConnect){
    
        [self showWait:@"正在连接设备"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            [self hideWait];
        
            if(blConnect)
            {
                [self showAlert:@"连接设备成功"];
                [self getDeviceMsg];
            }
            else
            {
                [self showAlert:@"连接设备失败"];
            }

        });
       };
    
    [self.navigationController pushViewController:scanDeviceVC animated:YES];
}


- (void)readerCardBtnClicked:(UIButton *)sender
{
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.title = @"";
    
    [self.navigationController pushViewController:webVC animated:YES];
}


-(void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}

-(void)showWait:(NSString *)mas
{
    [SVProgressHUD showWithStatus:mas];
}

-(void)hideWait
{
    [SVProgressHUD dismiss];
}


//获取设备信息
-(void)getDeviceMsg {
    
    [self.msgBuffer setString:@""];
    self.msgTextView.text = @"";
    [self.deviceManager requestDeviceVersionWithCallbackBlock:^(NSUInteger versionNum) {
        [self.msgBuffer appendString:@"SDK版本v1.4.0 20161026\r\n"];
        [self.msgBuffer appendString:[NSString stringWithFormat:@"设备版本：%02lx\r\n", (unsigned long)versionNum]];
        self.msgTextView.text = self.msgBuffer;
        [self.deviceManager requestDeviceBtValueWithCallbackBlock:^(float btVlueMv) {
            [self.msgBuffer appendString:[NSString stringWithFormat:@"设备电池电压：%.2fV\r\n", btVlueMv]];
            if (btVlueMv < 3.4) {
                [self.msgBuffer appendString:@"设备电池电量低，请及时充电！\r\n"];
            }
            else {
                [self.msgBuffer appendString:@"设备电池电量充足！\r\n"];
            }
            self.msgTextView.text = self.msgBuffer;
        }];
    }];
}



@end
