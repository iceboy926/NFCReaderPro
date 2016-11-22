//
//  NFCCard.m
//  ble_nfc_sdk
//
//  Created by sahmoL on 16/6/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import "NFCCard.h"
#import "NSData+Hex.h"

@implementation NFCCard


typedef  unsigned int DWORD;


DWORD AscToHex(char *Dest,char *Src,DWORD SrcLen)
{
    DWORD i;
    for ( i = 0; i < SrcLen; i ++ )
    {
        sprintf(Dest + i * 2,"%02X",(unsigned char)Src[i]);
    }
    Dest[i * 2] = 0;
    return 2*SrcLen;
}

DWORD HexToAsc(char *pDst, char *pSrc, DWORD nSrcLen)
{
    for(DWORD i=0; i<nSrcLen; i+=2)
    {
        //输出高4位
        if(*pSrc>='0' && *pSrc<='9')
        {
            *pDst = (*pSrc - '0') << 4;
        }
        else if(*pSrc>='A' && *pSrc<='F')
        {
            *pDst = (*pSrc - 'A' + 10) << 4;
        }
        else
        {
            *pDst = (*pSrc - 'a' + 10) << 4;
        }
        
        pSrc++;
        
        // 输出低4位
        if(*pSrc>='0' && *pSrc<='9')
        {
            *pDst |= *pSrc - '0';
        }
        else if(*pSrc>='A' && *pSrc<='F')
        {
            *pDst |= *pSrc - 'A' + 10;
        }
        else
        {
            *pDst |= *pSrc - 'a' + 10;
        }
        
        pSrc++;
        pDst++;
    }
    //返回目标数据长度
    return nSrcLen / 2;
}


//选择深圳通余额/交易记录文件
//00A404000701020304050607
+(NSData *)getSelectMainFileCmdByte{
    Byte bytes[] = {0x00, (Byte)0xa4, 0x04, 0x00, 0x07, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x00};
    return [NSData dataWithBytes:bytes length:12];
}

//

+(NSData *)readCmdByte
{
    Byte bytes[] = {0x00, (Byte)0x02, 0x00, 0x00, 0x00};
    
    return [NSData dataWithBytes:bytes length:5];
}

//000100001E 687474703A2F2F636172742E6A642E636F6D2F636172742E616374696F6E //write URL //http://cart.jd.com/cart.action
//0002000000 //read URL

+(NSData *)writeCmdByteWithString:(NSString *)strData
{
    Byte byte[128] = {0x00};//{0x00, (Byte)0x01, 0x00, 0x00, 0x00};
    int len = 0;
    const char *szInputData = [strData UTF8String];
    
    byte[1] = 0x01;
    byte[4] = (Byte)strlen(szInputData);
    
    memcpy(&byte[5], szInputData, strData.length);
  
    len = strData.length + 5;

    
    return [NSData dataWithBytes:byte length:len];
}


//获取余额APDU指令
+(NSData *)getBalanceCmdByte{
    Byte bytes[] = {(Byte)0x80, (Byte)0x5c, 0x00, 0x02, 0x04};
    return [NSData dataWithBytes:bytes length:5];
}
//获取交易记录APDU指令
+(NSData *)getTradeCmdByte:(Byte)n {
    Byte bytes[] = {(Byte)0x00, (Byte)0xB2, n, (Byte)0xC4, 0x00};
    return [NSData dataWithBytes:bytes length:5];
}

+(NSString *)getBalance:(NSData *)apduData{
    Byte *bytes = (Byte *)[apduData bytes];
    if ((apduData != nil) && (apduData.length == 6) && (bytes[4] == (Byte)0x90) && (bytes[5] == (Byte)0x00)) {
        long balance = ((long) (bytes[1] & 0x00ff) << 16)
        | ((long) (bytes[2] & 0x00ff) << 8)
        | ((long) (bytes[3] & 0x00ff));
        
        return [NSString stringWithFormat:@"%ld.%ld", balance/100, (balance % 100)];
    }
    return nil;
}
+(NSString *)getTrade:(NSData *)apduData{
    Byte *bytes = (Byte *)[apduData bytes];
    if ((apduData.length == 25) && (bytes[24] == 0x00) && (bytes[23] == (Byte) 0x90)) {
        long money = ((long) (bytes[5] & 0x00ff) << 24)
        | ((long) (bytes[6] & 0x00ff) << 16)
        | ((long) (bytes[7] & 0x00ff) << 8)
        | ((long) (bytes[8] & 0x00ff));
        
        NSString* optStr;
        if ((bytes[9] == 6) || (bytes[9] == 9)) {
            optStr = @"扣款";
        } else {
            optStr = @"充值";
        }
        return [NSString stringWithFormat:@"%02x%02x.%02x.%02x %02x:%02x:%02x %@ %ld.%ld 元",
                bytes[16],
                bytes[17],
                bytes[18],
                bytes[19],
                bytes[20],
                bytes[21],
                bytes[22],
                optStr,
                money / 100,
                money % 100];
    }
    return nil;
}
@end
