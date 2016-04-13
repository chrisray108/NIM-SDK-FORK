#ifndef SEPCRUMRESTORE_H_
#define SEPCRUMRESTORE_H_
#include <boost/math/special_functions/expint.hpp>
#include "SpectrumEngine.hpp"

namespace NIM {

class SpectrumRestorer_MMSE
{
public:
	SpectrumRestorer_MMSE(int sepcrumBins,float frameIncreament)
		:kSepcrumBins(sepcrumBins)
		,previousSNR(sepcrumBins,1)
		,kFrameIncreament(frameIncreament){

			kTimeConstForSmooth = 0.396;// time const for smoothing SNR estimate [0.396 seconds]
			kSmoothCoe_previous = std::exp(-kFrameIncreament/kTimeConstForSmooth); //SNR smoothing coefficient for Previous
			kSmoothCoe_current = 1. - kSmoothCoe_previous;
	};
	~SpectrumRestorer_MMSE(void){};
	bool initialize();

	template<typename SepcrumInputT,typename NoiseInputT,typename OutputT>
	bool apply(SepcrumInputT signal,NoiseInputT noise, OutputT restored){
		static const float kMinNoise = 1e-10;
		static const float kMinPosteriorSNR = 1e-3;
		static const float kMaxPosteriorSNR = 1000;
		static const float kMinPosteriorSNR_Estimate = 0;
		static const float kBasePriorSNR = 1.;
		static const float kMinPriorSNR = 0.;

		for (int i = 0; i != kSepcrumBins ; ++i){
			float posteriorSNR = kMaxPosteriorSNR;
			if(noise[i] > kMinNoise){
				posteriorSNR = std::min(std::max(signal[i].power()/noise[i],kMinPosteriorSNR),kMaxPosteriorSNR);
			}		
			float priorSNR = kSmoothCoe_previous*kBasePriorSNR*previousSNR[i] + kSmoothCoe_current*std::max(posteriorSNR-1,kMinPosteriorSNR_Estimate);
			priorSNR = priorSNR > kMinPriorSNR ? priorSNR : kMinPriorSNR;
			float rSNR = priorSNR / (1. + priorSNR);
			float gain =rSNR *exp (-0.5*nimboost::math::expint(-rSNR*posteriorSNR));
			restored[i] = signal[i] * gain;
			previousSNR[i] = posteriorSNR * gain * gain;
		}
		return true;
	};
private:
	const float kFrameIncreament;
	const int kSepcrumBins;
	std::vector<float> previousSNR;
	//std::vector<float> currentSNR;

	float kTimeConstForSmooth;// time const for smoothing SNR estimate [0.396 seconds]
	float kSmoothCoe_previous; //SNR smoothing coefficient for Previous
	float kSmoothCoe_current;

};
    
}
#endif // SEPCRUMRESTORE_H_

