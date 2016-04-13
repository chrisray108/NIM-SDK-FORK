#include "wav_amr.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "interf_dec.h"
#include "wavreader.h"
#include "wavwriter.h"

namespace NIM {

const int sizes[] = { 12, 13, 15, 17, 19, 20, 26, 31, 5, 6, 5, 5, 0, 0, 0, 0 };
int decode_amr(const char* infile, const char* outfile)
{
	FILE* in = fopen(infile, "rb");
	if (!in) {
		return 1;
	}
	char header[6];
	int n = (int)fread(header, 1, 6, in);
	if (n != 6 || memcmp(header, "#!AMR\n", 6)) {
		fprintf(stderr, "Bad header\n");
		return 1;
	}
    
    void* wav = wav_write_open(outfile, 8000, 16, 1);
    if (wav == 0)
    {
        return 1;
    }
	void* amr = Decoder_Interface_init();
    if (amr == 0)
    {
        return 1;
    }
	while (1)
    {
		uint8_t buffer[500];
		/* Read the mode byte */
		n = (int)fread(buffer, 1, 1, in);
		if (n <= 0)
			break;
		/* Find the packet size */
		int size = sizes[(buffer[0] >> 3) & 0x0f];
		if (size <= 0)
            continue;
		n = (int)fread(buffer + 1, 1, size, in);
		if (n != size)
			break;
		/* Decode the packet */
		int16_t outbuffer[160];
		Decoder_Interface_Decode(amr, buffer, outbuffer, 0);
		/* Convert to little endian and write to wav */
		uint8_t littleendian[320];
		uint8_t* ptr = littleendian;
		int i;
		for (i = 0; i < 160; i++) {
			*ptr++ = (outbuffer[i] >> 0) & 0xff;
			*ptr++ = (outbuffer[i] >> 8) & 0xff;
		}
        wav_write_data(wav, littleendian, 320);
	}
	fclose(in);
	Decoder_Interface_exit(amr);
    wav_write_close(wav);
	return 0;
}

}
