//
//  SZTCard.h
//  ble_nfc_sdk
//
//  Created by sahmoL on 16/6/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFCCard : NSObject
//选择深圳通余额/交易记录文件
+(NSData *)getSelectMainFileCmdByte;

+(NSData *)readCmdByte;

+(NSData *)writeCmdByteWithString:(NSString *)strData;

//获取余额APDU指令
+(NSData *)getBalanceCmdByte;
//获取交易记录APDU指令
+(NSData *)getTradeCmdByte:(Byte)n;

+(NSString *)getBalance:(NSData *)apduData;
+(NSString *)getTrade:(NSData *)apduData;
@end
