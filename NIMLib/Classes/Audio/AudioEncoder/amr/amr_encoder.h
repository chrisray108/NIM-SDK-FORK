/*
 * encoder.h
 *
 *  Created on: Jan 21, 2013
 *      Author: Liu
 */

#ifndef ENCODER_H_
#define ENCODER_H_

namespace NIM {

void* AMREncodeInit(int dtx);
int AMREncode( void *st,short *speech, unsigned char *serial );
void AMREncodeExit( void *state );
        
}

#endif /* ENCODER_H_ */
