
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include "typedef.h"
#include "interf_enc.h"
#include "amr_encoder.h"

namespace NIM {

void* AMREncodeInit(int dtx)
{
	return Encoder_Interface_init(dtx);
}

int AMREncode( void *st,short *speech, unsigned char *serial )
{
	enum Mode req_mode = MR122;
	return Encoder_Interface_Encode(st,req_mode,speech,serial,0);
}

void AMREncodeExit( void *state )
{
	Encoder_Interface_exit(state);
}
        
}
