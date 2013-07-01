//===================================================================================================
// Summary:
//		加密的接口。
// Usage:
//		Null	
//===================================================================================================

// #include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "base64.h"
#include "encryp.h"
#include "md5.h"
#include "SmartEncrypt.h"

//===================================================================================================

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//===================================================================================================

#define MD5_DIGEST_LENGTH 16

// 用于加密传输数据的密钥长度
const int SMARTDATA_ENCRYPTKEY_LENGTH	= 16;
// 用于加密传输数据的密钥
const unsigned char SMARTDATA_ENCRYPTKEY[]	= "jialidingliyangx";

// 用户自定义密钥
unsigned char g_customKey[16];
bool g_bCustomKey = false;

//===================================================================================================

// 设置密钥
bool SetEncryptKey(const unsigned char *pKey, long nLength)
{
	if (pKey == NULL || nLength != SMARTDATA_ENCRYPTKEY_LENGTH)
		return false;

	g_bCustomKey = true;
	memcpy(g_customKey, pKey, nLength);
	return true;
}

// 设置密钥，长度不限制
bool SetEncryptKeyEx(const unsigned char *pKey, long nLength)
{
	if (pKey == NULL)
		return false;

	g_bCustomKey = true;
	if (nLength == SMARTDATA_ENCRYPTKEY_LENGTH)
		memcpy(g_customKey, pKey, nLength);
	else
	{
		unsigned char *ppOutBuffer = NULL;
		long outlen = 0;
		if (HASHMD5(pKey, nLength, (unsigned char **)&ppOutBuffer, outlen))
		{
			// ASSERT(outlen == SMARTDATA_ENCRYPTKEY_LENGTH);
			memcpy(g_customKey, ppOutBuffer, SMARTDATA_ENCRYPTKEY_LENGTH);
			free(ppOutBuffer);
		}
		else
		{
			return false;
		}
	}	
	return true;
}

// 加密
bool SmartEncode(const unsigned char *pInBuffer, long nLength, unsigned char *pOutBuffer, long &outlen)
{
	if (!g_bCustomKey)
	{
		return EncodeFunction((const unsigned char *)pInBuffer, nLength,(unsigned char const*)SMARTDATA_ENCRYPTKEY, SMARTDATA_ENCRYPTKEY_LENGTH, 
								(unsigned char const*)SMARTDATA_ENCRYPTKEY, SMARTDATA_ENCRYPTKEY_LENGTH, pOutBuffer, outlen, BLOCK_CIPHER_AES_128_AND_CTR);
	}
	else
	{
		g_bCustomKey = false;
		return EncodeFunction((const unsigned char *)pInBuffer, nLength,(unsigned char const*)g_customKey, SMARTDATA_ENCRYPTKEY_LENGTH, 
							(unsigned char const*)g_customKey, SMARTDATA_ENCRYPTKEY_LENGTH, pOutBuffer, outlen, BLOCK_CIPHER_AES_128_AND_CTR);
	}

}

// 解密
bool SmartDecode(const unsigned char *pInBuffer, long nLength, unsigned char *pOutBuffer, long &outlen)
{
	if (!g_bCustomKey)
	{
		return DecodeFunction((const unsigned char *)pInBuffer, nLength,(unsigned char const*)SMARTDATA_ENCRYPTKEY, SMARTDATA_ENCRYPTKEY_LENGTH, 
							(unsigned char const*)SMARTDATA_ENCRYPTKEY, SMARTDATA_ENCRYPTKEY_LENGTH, pOutBuffer, outlen, BLOCK_CIPHER_AES_128_AND_CTR);
	}
	else
	{
		g_bCustomKey = false;
		return DecodeFunction((const unsigned char *)pInBuffer, nLength,(unsigned char const*)g_customKey, SMARTDATA_ENCRYPTKEY_LENGTH, 
							(unsigned char const*)g_customKey, SMARTDATA_ENCRYPTKEY_LENGTH, pOutBuffer, outlen, BLOCK_CIPHER_AES_128_AND_CTR);
	}
}

// Base64编码
bool SmartBase64Encode(const unsigned char *pInBuffer, long nLength, unsigned char **ppOutBuffer, long &outlen)
{
	bool bInsertLineBreak = false;

	ENCODE_CTX ctx;
	int result;
	int base64Len = (((nLength+2)/3)*4) + 1; // Base64 text length
	if (bInsertLineBreak) // 格式化处理
	{ 
		outlen = base64Len + base64Len/64 + 1; // PEM adds a newline every 64 bytes
		*ppOutBuffer = (unsigned char*)malloc(outlen);
		if (*ppOutBuffer == NULL)
		{
			return false;
		}
		Base64_EncodeInit(&ctx);
		Base64_EncodeUpdate(&ctx, *ppOutBuffer, &result, pInBuffer, nLength);
		outlen= result;
		Base64_EncodeFinal(&ctx, &(*ppOutBuffer)[result], &result);
		outlen += result;
		
	}
	else // 非格式化处理
	{
		*ppOutBuffer = (unsigned char *)malloc(base64Len);
		if(*ppOutBuffer == NULL)
		{
			return false;
		}	
		outlen = Base64_EncodeBlock(*ppOutBuffer, pInBuffer, nLength);
	}
	return true;
}

// 反Base64编码
bool SmartBase64Decode(const unsigned char *pInBuffer, long nLength, unsigned char **ppOutBuffer, long &outlen)
{
	bool bInsertLineBreak = false;

	ENCODE_CTX ctx;
	int orgLen = (((nLength+3)/4)*3);
	int i, pad;
	const unsigned char *p;
	int result, tmpLen;
	*ppOutBuffer = (unsigned char*)malloc(orgLen);
	if(*ppOutBuffer == NULL)
		return false;

	if (bInsertLineBreak)
	{
		Base64_DecodeInit(&ctx);
		Base64_DecodeUpdate(&ctx, *ppOutBuffer, &result, pInBuffer, nLength);
		Base64_DecodeFinal(&ctx, &(*ppOutBuffer)[result], &tmpLen);
		result += tmpLen;
		outlen = result;
	}
	else
	{
		p = pInBuffer + nLength -1;
		pad = 0;
		for (i=0; i<4; i++)
		{
			if(*p == '=')
				pad++;
			p--;
		}
		outlen =Base64_DecodeBlock(*ppOutBuffer, pInBuffer, nLength)-pad;
	}
	return true;
}

bool HASHMD5(const unsigned char *pInBuffer, long len, unsigned char **ppOutBuffer, long &outlen)
{
	outlen = MD5_DIGEST_LENGTH;
	*ppOutBuffer = (unsigned char*)malloc(outlen);
	if (*ppOutBuffer == NULL)
		return false;
	
	MD5(pInBuffer, len, *ppOutBuffer);
	return true;
}