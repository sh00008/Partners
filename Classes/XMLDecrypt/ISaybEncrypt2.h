//
//  ISaybEncrypt2.h
//  Partners
//
//  Created by DingLi on 13-6-30.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#ifndef __Partners__ISaybEncrypt2__
#define __Partners__ISaybEncrypt2__

#include <iostream>

// 解析证书证书信息，加密euf（encry user xml file）文件调用
bool ParseServerUserLicense(unsigned char *pLicenseData, int nLength, char  szUserName[256], unsigned char **pDeviceInfo, int &nDeviceLength);

long LoadDecodeBuffer(const char * infile, unsigned char** fileData, const unsigned char* decodeKey, long keyLen);

void FreeBuffer(unsigned char** fileData);

#endif /* defined(__Partners__ISaybEncrypt2__) */
