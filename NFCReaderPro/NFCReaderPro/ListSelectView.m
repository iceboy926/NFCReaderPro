//
//  ListSelectView.m
//  cjh
//
//  Created by wbb on 16/10/31.
//  Copyright © 2016年 njcjh. All rights reserved.
//

#import "ListSelectView.h"

#define SEARCH_BLE_NAME   @"BLE_NFC"

@interface ListSelectView()<UITableViewDelegate,UITableViewDataSource,DKBleManagerDelegate>{
    CGFloat kSingleTitleHeight;
    CGFloat kSingleBtnHeight;
    UITableView *mytableView;
    NSMutableArray *_peripheralArray;
}
@property (strong, nonatomic) UIView *selectView;
@property (assign, nonatomic) CGFloat collectionViewHeight;

@property (assign, nonatomic) BOOL isAnimated;
@property (nonatomic,copy)NSString *title_str;
@property (copy,   nonatomic) dismissViewWithButton completionBlock;
@property (copy,   nonatomic) SureButtonBlock sureButtonBlock;

@property (nonatomic, strong) DKBleManager     *bleManager;

@end
@implementation ListSelectView

- (instancetype _Nonnull)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.bleManager = [DKBleManager sharedInstance];
        self.bleManager.delegate = self;
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            if([self.bleManager isConnect])
            {
                [self.bleManager cancelConnect];
                
                [self scanDevice];
            }
            else
            {
                [self scanDevice];
            }
        });
    }
    return self;
}
- (void)addTitleString:(NSString *__nullable)titleStr animated:(BOOL)animated completionHandler:(dismissViewWithButton __nullable)completionHandler withSureButtonBlock:(SureButtonBlock __nullable)sureButtonBlock {

    
    _peripheralArray = [NSMutableArray array];
    
    self.isAnimated = animated;
    self.completionBlock = completionHandler;
    self.sureButtonBlock = sureButtonBlock;
    self.title_str = titleStr;
    self.choose_type = MORECHOOSETITLETYPE;
    [self setupHeight];
    if (!_isShowTitle) {
        kSingleTitleHeight = 0.f;
    }else{
        kSingleTitleHeight = 50.f;
    }
    if (_isShowSureBtn||_isShowCancelBtn) {
        kSingleBtnHeight = 50;
    }else {
        kSingleBtnHeight = 0;
    }
    [self initSelectView];
    
    
    if (self.isAnimated) {
        [self addPopAnimation];
    }
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
}

- (void)scanDevice
{
    [self.bleManager startScan];
}

-(void)stopscanDevice
{
    [self.bleManager stopScan];
    
}

#pragma mark - DKBleManagerDelegate
-(void)DKCentralManagerDidUpdateState:(CBCentralManager *)central {
    NSError *error = nil;
    switch (central.state) {
        case CBCentralManagerStatePoweredOn://蓝牙打开
        {
            //pendingInit = NO;
            //[self startToGetDeviceList];
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
        
        if(![_peripheralArray containsObject:peripheral])
        {
            
            NSIndexPath *index = [NSIndexPath indexPathForRow:[_peripheralArray count] inSection:0];
            
            [_peripheralArray addObject:peripheral];
            
            
            [mytableView beginUpdates];
            
            [mytableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationRight];
            
            [mytableView endUpdates];
        }
    
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


// 根据文字大小和控件宽度计算控件高度
- (CGFloat)heightForText:(NSString *)text textFont:(CGFloat)fontSize standardWidth:(CGFloat)controlWidth
{
    if ([text length]==0) {
        return 0;
    }else {
        NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
        return [text boundingRectWithSize:CGSizeMake(controlWidth, 2000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrbute context:nil].size.height;
    }
}
#pragma mark - setup methods

- (void)setupHeight {
    
    if(_choose_type == MORECHOOSETITLETYPE){
        self.collectionViewHeight = 4 * kSingleSelectCellHeight;
    }else if (_choose_type == ONLYTEXTTYPE) {
        self.collectionViewHeight = [self heightForText:self.content_text textFont:kSingleContentTextFount standardWidth:SCREEN_WIDTH-80]+10;
    }
    
    if (self.collectionViewHeight + 200 > SCREENH_HEIGHT) {
        self.collectionViewHeight = SCREENH_HEIGHT-200;
    }
}

- (void)initSelectView {
    
    self.selectView = [[UIView alloc]initWithFrame:CGRectMake(30, (SCREENH_HEIGHT-(self.collectionViewHeight+101))/2-80, SCREEN_WIDTH-60, self.collectionViewHeight+kSingleTitleHeight+kSingleBtnHeight+1)];
    self.selectView.backgroundColor = [UIColor whiteColor];
    self.selectView.layer.cornerRadius = 10;
    self.selectView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.selectView.layer.shadowOffset = CGSizeMake(10, 10);
    self.selectView.layer.shadowOpacity = 0.5;
    self.selectView.layer.shadowRadius = 5;
    self.selectView.center = self.center;
    [self addSubview:self.selectView];
    /**
     标题Label
     */
    UILabel *tilteLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.selectView.frame.size.width, kSingleTitleHeight)];
    tilteLabel.hidden = _isShowTitle?NO:YES;;
    tilteLabel.text = _title_str;//@"请选择适合的选项";
    tilteLabel.font = [UIFont systemFontOfSize:18.f];
    tilteLabel.textAlignment = NSTextAlignmentCenter;
    [self.selectView addSubview:tilteLabel];
    /**
     横线
     */
    UILabel *horizontal1 = [[UILabel alloc]initWithFrame:CGRectMake(0 , tilteLabel.frame.size.height-1, self.selectView.frame.size.width, 0.5)];
    horizontal1.hidden = _isShowTitle?NO:YES;
    horizontal1.backgroundColor = [UIColor grayColor];
    [tilteLabel addSubview:horizontal1];
    
    if(_choose_type == MORECHOOSETITLETYPE) {
        /**
         *  注册tableview
         */
        mytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.selectView.frame.size.width, self.collectionViewHeight) style:UITableViewStylePlain];
//        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        mytableView.backgroundColor = [UIColor whiteColor];
        mytableView.delegate = self;
        mytableView.dataSource = self;
        [self.selectView addSubview:mytableView];
    }else {
        /**
         注册contentLabel
         */
        UILabel *lab_content = [[UILabel alloc] initWithFrame:CGRectMake(10, kSingleTitleHeight, self.selectView.frame.size.width-20, self.collectionViewHeight)];
        lab_content.numberOfLines = 0;
        lab_content.font = [UIFont systemFontOfSize:kSingleContentTextFount];
        lab_content.text = self.content_text;
        [self.selectView addSubview:lab_content];
    }
    
    /**
     取消Button
     */
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.selectView.frame.size.height-50,_isShowSureBtn&&_isShowCancelBtn?self.selectView.frame.size.width/2-1: self.selectView.frame.size.width, kSingleBtnHeight)];
    [cancelButton setTitle:@"取 消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
    cancelButton.hidden = _isShowCancelBtn?NO:YES;
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchDown];
    [self.selectView addSubview:cancelButton];
    /**
     确定Button
     */
    UIButton *okButton = [[UIButton alloc]initWithFrame:CGRectMake(_isShowSureBtn&&_isShowCancelBtn?self.selectView.frame.size.width/2+1:0, self.selectView.frame.size.height-50, _isShowSureBtn&&_isShowCancelBtn?self.selectView.frame.size.width/2-1: self.selectView.frame.size.width, kSingleBtnHeight)];
    okButton.hidden = _isShowSureBtn?NO:YES;
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonAction) forControlEvents:UIControlEventTouchDown];
    [self.selectView addSubview:okButton];
    /**
     竖线
     */
    UILabel *verticalline = [[UILabel alloc]initWithFrame:CGRectMake(cancelButton.frame.size.width, cancelButton.frame.origin.y, 0.5, cancelButton.frame.size.height)];
    verticalline.backgroundColor = [UIColor grayColor];
    verticalline.hidden = _isShowCancelBtn&&_isShowSureBtn?NO:YES;
    [self.selectView addSubview:verticalline];
    /**
     横线
     */
    UILabel *horizontal2 = [[UILabel alloc]initWithFrame:CGRectMake(0 , cancelButton.frame.origin.y-1, self.selectView.frame.size.width, 0.5)];
    horizontal2.hidden = _isShowCancelBtn||_isShowSureBtn?NO:YES;
    horizontal2.backgroundColor = [UIColor grayColor];
    [self.selectView addSubview:horizontal2];
    
}

#pragma mark listViewdataSource method and delegate method
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    return _peripheralArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellid=@"listviewid";
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellid];
        
        CBPeripheral *peripheral = _peripheralArray[indexPath.row];
        
        cell.textLabel.text = peripheral.name;
        
    }
    
   
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kSingleSelectCellHeight;
}
//当选择下拉列表中的一行时，设置文本框中的值，隐藏下拉列表
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
     __block  CBPeripheral *selectedPeripheral = [_peripheralArray objectAtIndex:[indexPath row]];
    
    WEAK_SELF(weakself)
    [self.bleManager connect:selectedPeripheral callbackBlock:^(BOOL isConnectSucceed){
    
        if(weakself.completionBlock)
        {
            
            weakself.completionBlock(isConnectSucceed);
        }
    }];
     

    [self removeFromSuperview];
}

#pragma make - Action

- (void)cancelButtonAction {
    self.bleManager.delegate = nil;
    [self stopscanDevice];
    [self removeFromSuperview];
    
}
- (void)okButtonAction {
    self.sureButtonBlock();
    [self removeFromSuperview];
}
#pragma make - Animation

- (void)addPopAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithDouble:0.f];
    animation.toValue   = [NSNumber numberWithDouble:1.f];
    animation.duration  = .25f;
    animation.fillMode  = kCAFillModeBackwards;
    [self.layer addAnimation:animation forKey:nil];
}
@end
