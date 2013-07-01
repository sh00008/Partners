//===================================================================================================
// Summary:
//		加密的算法。
// Usage:
//		Null	
//===================================================================================================

#ifndef __encryp_h__
#define __encryp_h__

//===================================================================================================

#define SYMMETRIC_CIPHER_AES_128		0		
#define SYMMETRIC_CIPHER_AES_192		1		
#define SYMMETRIC_CIPHER_AES_256		2	
#define CHAIN_MODE_CTR				0<<16	
#define CHAIN_MODE_CBC				1<<16 
//如下为对称加密模式的参数
#define BLOCK_CIPHER_AES_128_AND_CTR		(SYMMETRIC_CIPHER_AES_128 | CHAIN_MODE_CTR)

//===================================================================================================

bool EncodeFunction(const unsigned char  *pInBuffer, long nLength, const unsigned char *pKey,
					long nKeyLength, const unsigned char *pIV, long nIVLength,
					unsigned char *pOutBuffer, long &outlen, int dwEncrypt_ModeID);
bool DecodeFunction(const unsigned char *pInBuffer, const long nLength, const unsigned char *pKey,
					long nKeyLength, const unsigned char  *pIV, long nIVLength,
					unsigned char *pOutBuffer, long &outlen, int dwEncrypt_ModeID);

//===================================================================================================

#endif