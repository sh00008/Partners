//===================================================================================================
// Summary:
//		加密的接口。
// Usage:
//		Null	
//===================================================================================================

#ifndef __SmartEncrypt_h__
#define __SmartEncrypt_h__

//===================================================================================================

// 设置密钥，长度必须为16
bool SetEncryptKey(const unsigned char *pKey, long nLength);
// 设置密钥，长度不限制
bool SetEncryptKeyEx(const unsigned char *pKey, long nLength);
// 加密
bool SmartEncode(const unsigned char *pInBuffer, long nLength, unsigned char *pOutBuffer, long &outlen);
// 解密
bool SmartDecode(const unsigned char *pInBuffer, long nLength, unsigned char *pOutBuffer, long &outlen);

// Base64编码
bool SmartBase64Encode(const unsigned char *pInBuffer, long nLength, unsigned char **ppOutBuffer, long &outlen);
// 反Base64编码
bool SmartBase64Decode(const unsigned char *pInBuffer, long nLength, unsigned char **ppOutBuffer, long &outlen);

// MD5摘要
bool HASHMD5(const unsigned char *pInBuffer, long len, unsigned char **ppOutBuffer, long &outlen);

//===================================================================================================

#endif