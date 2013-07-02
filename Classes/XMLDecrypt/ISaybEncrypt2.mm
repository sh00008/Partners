//
//  ISaybEncrypt2.cpp
//  Partners
//
//  Created by DingLi on 13-6-30.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#include "ISaybEncrypt2.h"
#include "encryp.h"
#include "SmartEncrypt.h"
#include <algorithm>
#include <string>
using namespace std;

// 用于加密传输数据的密钥长度
const int SERVER_LIC_ENCRYPTKEY_LENGTH	= 16;
// 用于加密传输数据的密钥
const unsigned char SERVER_LIC_ENCRYPTKEY[]	= "yanghaolin2008ji";

#define SYMMETRIC_CIPHER_AES_128		0
#define SYMMETRIC_CIPHER_AES_192		1
#define SYMMETRIC_CIPHER_AES_256		2
#define CHAIN_MODE_CTR				0<<16
#define CHAIN_MODE_CBC				1<<16
//»Áœ¬Œ™∂‘≥∆º”√‹ƒ£ Ωµƒ≤Œ ˝
#define BLOCK_CIPHER_AES_128_AND_CTR		(SYMMETRIC_CIPHER_AES_128 | CHAIN_MODE_CTR)

// 解析证书证书信息，加密euf（encry user xml file）文件调用
bool ParseServerUserLicense(unsigned char *pLicenseData, int nLength, char szUserName[256], unsigned char **pDeviceInfo, int &nDeviceLength)
{
	if (pLicenseData == nil || nLength == 0)
		return false;
    
	// 第一步，反Base64编码
	unsigned char *pDestKey = nil;
	long lOutLen = 0;
	SmartBase64Decode(pLicenseData, nLength, &pDestKey, lOutLen);
	if (pDestKey == nil || lOutLen <= 0)
		return false;
    
	// 第二步，加密证书信息
	SetEncryptKey(SERVER_LIC_ENCRYPTKEY, SERVER_LIC_ENCRYPTKEY_LENGTH);
	long nSrcLength = lOutLen;
	unsigned char *pLicSrcData = new unsigned char[nSrcLength];
    if (!SmartDecode(pDestKey, lOutLen, pLicSrcData, nSrcLength))
	{
		free(pDestKey);
		return false;
	}
	free(pDestKey);
//	ASSERT(nSrcLength == lOutLen);
    
	// 第三步，字节转换为证书信息
	string strInfo;
    strInfo.append((const char*)pLicSrcData, nLength);
    
	// 第四步，解析证书
	// 1、版本号
	size_t nStartIndex = strInfo.find("&Version=");
	if (nStartIndex == string::npos)
		return false;
    
//	CString strVersion = strInfo.Mid(nStartIndex+9, 1);
//	int nVersion = _ttoi(strVersion);
//	if (nVersion != 1)
//		return false;
//    
//	// 6、产品信息
//	CString strRealProduct = _T("isayb");
//	nStartIndex = strInfo.Find(_T("&Product="));
//	if (nStartIndex == -1)
//		return false;
//	CString strProduct = strInfo.Mid(nStartIndex+9, strRealProduct.GetLength());
//	if (strProduct.Compare(strRealProduct) != 0)
//		return false;
//    
	// 用户信息
	nStartIndex = strInfo.find("&User=");
	size_t nEndIndex = strInfo.find("&Device=");
	if (nStartIndex == string::npos || nEndIndex == string::npos)
		return false;
	string strUserName = strInfo.substr(nStartIndex+6, nEndIndex-nStartIndex-6);
    
	memset(szUserName, 0, 256);
    memcpy(szUserName, strUserName.c_str(), 256 > strUserName.size() ? 256 : strUserName.size());
    
	// 密钥
	string strDevice = strInfo.substr(nStartIndex+8, strInfo.size()-nStartIndex);
    
	nDeviceLength = strDevice.size();
	*pDeviceInfo = new unsigned char[nDeviceLength + 1];
	memcpy(*pDeviceInfo, strDevice.c_str(), nDeviceLength);
    
	return true;
}

long LoadDecodeBuffer(const char * infile, unsigned char** fileData, const unsigned char* decodeKey, long keyLen)
{
    FILE * fid = fopen(infile,"rb");
    // file length
    fseek(fid, 0, SEEK_END);
    long filelen = ftell(fid);
    unsigned char* buffer = new unsigned char[filelen];
    fseek(fid, 0, SEEK_SET);
    fread(buffer, 1, filelen, fid);
    fclose(fid);
    
    SetEncryptKeyEx(decodeKey, keyLen);
    long fileDecodeLen = filelen;
    *fileData = new unsigned char[fileDecodeLen];
    SmartDecode((const unsigned char *)buffer, filelen, *fileData, fileDecodeLen);
    return fileDecodeLen;
}

void FreeBuffer(unsigned char **fileData)
{
    if (*fileData) {
        delete [] *fileData;
    }
}
