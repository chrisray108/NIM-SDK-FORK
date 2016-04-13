#ifndef VOICEACTIVEDETECTOR_H_
#define VOICEACTIVEDETECTOR_H_
#include <vector>
#include <boost\math\special_functions\bessel.hpp>

namespace NIM {

class VoiceActiveDetector
{
public:
	VoiceActiveDetector(int sepcrumBins,float frameIncreament)
		:kSepcrumBins(sepcrumBins)
		,probRatioLog(0)
		,previousSNR(sepcrumBins,1.)
		,postSNR(sepcrumBins,0.)
		,modifiedPostSNR(sepcrumBins,0.)
		,kFrameIncreament(frameIncreament){

			kTimeConstForSmooth = 0.396;// time const for smoothing SNR estimate [0.396 seconds]
			kSmoothCoe_previous = std::exp(-kFrameIncreament/kTimeConstForSmooth); //SNR smoothing coefficient for Previous
			kSmoothCoe_current = 1. - kSmoothCoe_previous;
	};
	~VoiceActiveDetector(void){};
	bool initialize();

	template<typename SepcrumInputT,typename NoiseInputT>
	float apply(SepcrumInputT signal,NoiseInputT noise){
		float vadPorb = calVADProb<SepcrumInputT,NoiseInputT>(noise, signal);
		UpdataSNR();
		return vadPorb;
	};



private:
	const float kFrameIncreament;
	const int kSepcrumBins;
	float probRatioLog;
	std::vector<float> previousSNR;
	std::vector<float> postSNR;
	std::vector<float> modifiedPostSNR;
	//std::vector<float> currentSNR;

	float kTimeConstForSmooth;// time const for smoothing SNR estimate [0.396 seconds]
	float kSmoothCoe_previous; //SNR smoothing coefficient for Previous
	float kSmoothCoe_current;
	void UpdataSNR() 
	{
		for (int i = 0; i != kSepcrumBins ; ++i){
			float gain =(0.277+ 2*modifiedPostSNR[i])/postSNR[i];         //  % accurate to 0.02 dB for v>0.5
			if (modifiedPostSNR[i] < 0.5){
				float bessel_i_0 = boost::math::cyl_bessel_i(0, modifiedPostSNR[i]);
				float bessel_i_1 = boost::math::cyl_bessel_i(1, modifiedPostSNR[i]);
				static const float PI = 3.1415926;
				static const float kk = sqrt(2 * PI);
				gain = kk * sqrt(modifiedPostSNR[i]) * ((0.5 + modifiedPostSNR[i]) * bessel_i_0 + modifiedPostSNR[i] * bessel_i_1) / (postSNR[i]* exp(modifiedPostSNR[i]));
			}
			previousSNR[i]=postSNR[i]*gain*gain;    
		}
	}

	template<typename SepcrumInputT,typename NoiseInputT>
	float calVADProb( NoiseInputT noise, SepcrumInputT &signal) 
	{
		static const float kMinNoise = 1e-10;
		static const float kMinPosteriorSNR = 1e-3;
		static const float kMaxPosteriorSNR = 1000;
		static const float kMinPosteriorSNR_Estimate = 0;
		static const float kBasePriorSNR = 1.;
		static const float kMinPriorSNR = 0.;

		static const float kLengthVoiceSpurt=0.1;//  % mean talkspurt length (100 ms)
		static const float kLengthSilence=0.05;// % mean silence length (50 ms)

		static const float a01 = kFrameIncreament / kLengthSilence;// % a01=P(silence->speech)
		static const float a00 = 1. - a01;                   // % a00=P(silence->silence)
		static const float a10 = kFrameIncreament / kLengthVoiceSpurt;// % a10=P(speech->silence)
		static const float a11 = 1. - a10;                   //  % a11=P(speech->speech)

		static const float b11 = a11/a10;
		static const float b01 = a01/a00;
		static const float b00 = a01 - a00 * a11 / a10;
		static const float b10 = a11 - a10 * a01 / a00;
		static const float kSilenceVoiceProbRatio = log(a10/a01);   //  % log (P(silence)/P(speech))

		static const int kDCIdx = 0;

		float meanLikelihoodRatio_withoutDC(0);   // % mean log LR omitting DC term [1](4)
		for (int i = 0; i != kSepcrumBins ; ++i){
			postSNR[i] = kMaxPosteriorSNR;
			if(noise[i] > kMinNoise){
				postSNR[i] = std::min(std::max(signal[i].power()/noise[i],kMinPosteriorSNR),kMaxPosteriorSNR);
			}		
			float priorSNR = kSmoothCoe_previous*kBasePriorSNR*previousSNR[i] + kSmoothCoe_current*std::max<float>(postSNR[i]-1.,kMinPosteriorSNR_Estimate);
			priorSNR = priorSNR > kMinPriorSNR ? priorSNR : kMinPriorSNR;
			modifiedPostSNR[i] = 0.5 * priorSNR * postSNR[i] / (priorSNR + 1.); //  % defined in [2], note that this is 0.5*vk in [2]
			float likelihoodRatio = 2.*modifiedPostSNR[i] -log(priorSNR + 1.);              //% log likelihood ratio [1](3)
			if (i != kDCIdx){
				meanLikelihoodRatio_withoutDC += likelihoodRatio;
			}
		}
		meanLikelihoodRatio_withoutDC /= static_cast<float>(kSepcrumBins - 1);
		if (probRatioLog < 0)
		{
			probRatioLog = kSilenceVoiceProbRatio + meanLikelihoodRatio_withoutDC + log(b11 + b00 / (a00 + a10 * exp(probRatioLog)));
		}
		else
			probRatioLog = kSilenceVoiceProbRatio + meanLikelihoodRatio_withoutDC + log(b01 + b10 / (a10 + a00 * exp(-probRatioLog)));

		float vadPorb ;
		if (probRatioLog < 0)
		{
			float gg = exp(probRatioLog);
			vadPorb = gg / (1+gg);
		}
		else{
			vadPorb = 1 / (1 + exp(-probRatioLog));
		}
		return vadPorb;
	}

	
};
}
#endif // VOICEACTIVEDETECTOR_H_