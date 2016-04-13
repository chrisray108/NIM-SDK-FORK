#ifndef NOISEESTIMATER_H_
#define NOISEESTIMATER_H_

#include <vector>

namespace NIM {

class NoiseEstimater_MMSE
{
public:
	NoiseEstimater_MMSE(int sepcrumBins,float frameIncreament)	
		:kTimeForInitialize(0.064)
		,kInitSpeechProb(0.5)
		,kSepcrumBins(sepcrumBins)
		,kFrameIncreament(frameIncreament)
		,kNeededFrameNum(1 + kTimeForInitialize / frameIncreament)
		,previousNoise(sepcrumBins,0.)
		,postSpeechPresentPorbSmooth(sepcrumBins,kInitSpeechProb)
		,currentInitFrame(0)
	{
	}
	~NoiseEstimater_MMSE(void){};
	inline int neededInitFrameNum() const { return kNeededFrameNum;};

	template<class SepcrumInputT>
	bool setInitFrame(SepcrumInputT signal){
		if (currentInitFrame == kNeededFrameNum){
			return true;
		}
		for (int n = 0; n !=  kSepcrumBins; ++n){
			previousNoise[n] += signal[n].power();
		}
		if (++currentInitFrame == kNeededFrameNum){
			for (int n = 0; n !=  kSepcrumBins; ++n){
				previousNoise[n] *= (kInitSpeechProb / static_cast<float>(kNeededFrameNum));
			}
			return true;
		}
		return false;
	}
	template<typename SepcrumInputT,typename NoiseT>
	bool apply(SepcrumInputT signal,NoiseT noise){
		static const float tax = 0.0717; //  */% noise output smoothing time constant = -tinc/log(0.8) (8)
		static const float tap = 0.152;//    % noise output smoothing time constant = -tinc/log(0.9) (23)
		static const float kPostSpeechPresentPorb_Min = 0.99;  //% threshold for smoothed speech probability [0.99] (24)
		static const float kNoiseProbSafe = 0.01;  /// % noise probability safety value [0.01] (24)
		static const float kProirSpeechPorb = 0.5;//       % prior speech probability [0.5] (18)
		static const float kActiveSNR = 15.;// active SNR in dB [15] (18)

		// derived algorithm constants
		static const float kNoiseSmoothCoef = exp(-kFrameIncreament/tax);
		static const float kNoiseSmoothCoef_C = 1.- kNoiseSmoothCoef;
		static const float kSpeechPresentPorbSmoothCoe = exp(-kFrameIncreament/tap);
		static const float kSpeechPresentPorbSmoothCoe_C = 1. - kSpeechPresentPorbSmoothCoe;
		static const float kSpeechPresentSNR = pow(10, kActiveSNR/10);//% speech-present SNR
		static const float kSpeechPresentSNR_v = 1. / (1. +kSpeechPresentSNR) - 1.;
		static const float kPorbNSR = (1./kProirSpeechPorb - 1.) * (1. + kSpeechPresentSNR);// % p(noise)/p(speech) (18)

		static const float kMinNoise = 1e-10;

		for (int j = 0; j != kSepcrumBins ; ++j){
			float postSpeechPresentPorb = 1.;
			if (previousNoise[j] >= kMinNoise){
				postSpeechPresentPorb = 1. / (1. + kPorbNSR * exp(kSpeechPresentSNR_v * signal[j].power() / previousNoise[j]));
			}
			postSpeechPresentPorbSmooth[j] = kSpeechPresentPorbSmoothCoe * postSpeechPresentPorbSmooth[j] + kSpeechPresentPorbSmoothCoe_C * postSpeechPresentPorb;
			postSpeechPresentPorb = std::min<float>(postSpeechPresentPorb, 1.-kNoiseProbSafe*(postSpeechPresentPorbSmooth[j] > kPostSpeechPresentPorb_Min ? 1. : 0.));
			float rawNoise = (1 - postSpeechPresentPorb) * signal[j].power() + postSpeechPresentPorb * previousNoise[j];
			previousNoise[j] = kNoiseSmoothCoef * previousNoise[j] + kNoiseSmoothCoef_C * rawNoise;
			noise[j] = previousNoise[j];
		}
		return true;
	};
private:
	
	float kTimeForInitialize;
	float kInitSpeechProb;

	const int kNeededFrameNum;
	int currentInitFrame;
	const float kFrameIncreament;
	const int kSepcrumBins;
	std::vector<float> previousNoise;
	std::vector<float> postSpeechPresentPorbSmooth;
};
    
}

#endif // NOISEESTIMATER_H_

