//===================================================================================================
// Summary:
//		base64À„∑®°£
// Usage:
//		Null	
//===================================================================================================

#ifndef __base64_h__
#define __base64_h__

//===================================================================================================

typedef struct Encode_Ctx_st
{
	int num;	/* number saved in a partial encode/decode */
	int length;	/* The length is either the output line length
				* (in input bytes) or the shortest input line
				* length that is ok.  Once decoding begins,
				* the length is adjusted up each time a longer
				* line is decoded */
	unsigned char enc_data[80];	/* data to encode */
	int line_num;	/* number read on current line */
	int expect_nl;
} ENCODE_CTX;

//===================================================================================================

void Base64_EncodeInit(ENCODE_CTX *ctx);
void Base64_EncodeUpdate(ENCODE_CTX *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl);
void Base64_EncodeFinal(ENCODE_CTX *ctx, unsigned char *out, int *outl);
int Base64_EncodeBlock(unsigned char *t, const unsigned char *f, int n);

void Base64_DecodeInit(ENCODE_CTX *ctx);
int Base64_DecodeUpdate(ENCODE_CTX *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl);
int Base64_DecodeFinal(ENCODE_CTX *ctx, unsigned char* out, int *outl);
int Base64_DecodeBlock(unsigned char *t, const unsigned char *f, int n);

//===================================================================================================

#endif