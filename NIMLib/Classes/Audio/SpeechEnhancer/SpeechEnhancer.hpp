#ifndef SPEECHENHANCER_H_
#define SPEECHENHANCER_H_
#include "SpectrumEngine.hpp"
//#include "DataType_Used.h"
#include "NoiseEstimater_MMSE.hpp"
#include <list>

namespace NIM {

class SpeechEnhancer_Android
{
public:
	SpeechEnhancer_Android(void);
	~SpeechEnhancer_Android(void);
};

enum SampleRate_Surported{
	SampleRate_8000 = 8000,
	SampleRate_16000 = 16000,
	SampleRate_22050 = 22050,
	SampleRate_44100 = 44100,
};
inline int getFFTSize(SampleRate_Surported sampleRate){
	switch(sampleRate){
	case(SampleRate_8000) : return 256;
	case(SampleRate_16000) : return 512;
	case(SampleRate_22050) : return 512;
	case(SampleRate_44100) : return 1024;
	}
	assert(false);
};
inline int getFFTHop(SampleRate_Surported sampleRate){
	return getFFTSize(sampleRate) / 2;
};


template<typename NoiseEstimateT , typename SpectrumRestorerT>
class SpeechEnhancer
{
protected:
	const int kFFTSize;
	const int kFFTHop;
	const float kFrameInreament;
	const int kSpectrumDim;

	//static const int kFFTSizeBase = 256;
	//static const int kFFTHopBase = 128;
	////static const int kFreqUsed = kFFTSize/2 + 1;
	//static const int kBaseSampleRate = 8000;

public:
	SpeechEnhancer(int sampleRate)	
		:kFFTSize(getFFTSize(static_cast<SampleRate_Surported>(sampleRate)))
		,kFFTHop(getFFTHop(static_cast<SampleRate_Surported>(sampleRate)))
		,kFrameInreament(static_cast<float>(kFFTHop) / static_cast<float>(sampleRate))
		,kSpectrumDim(kFFTSize / 2 + 1)
		,noiseEstimater(kSpectrumDim,kFrameInreament)
		,spectrumEngine(kFFTSize,kFFTHop)
		,spectrumRestorer(kSpectrumDim,kFrameInreament)
		,noiseSpectrum(kSpectrumDim,0.)
		,isInitialzed(false)
	{};
	~SpeechEnhancer(void){};
	std::vector<float> apply(const float* signal,int lengh){
		assert(lengh > 0);
		ComplexArray2D signalSpecturm = spectrumEngine.wave2Spectrum(signal,lengh);
		const int kNumFrame = (const int)signalSpecturm.shape()[0];
		if (kNumFrame <= 0){
			return std::vector<float>(); 
		}
		if (isInitialzed){
			//FloatArray2D noiseSpectrum( boost::extents[kNumFrame][kSpectrumDim]);
			return enhanceFromSpectrum(signalSpecturm,kNumFrame);
		}
		else{
			for (int nFrame = 0; nFrame != kNumFrame ; ++nFrame){
				isInitialzed = noiseEstimater.template setInitFrame < ComplexType* > (signalSpecturm.data() + nFrame * kSpectrumDim);
				if (isInitialzed){
					break;
				}
			}
			specturmList.insert(specturmList.end(),signalSpecturm);
			if (isInitialzed){
				std::vector<float> enhancedAudio;
				for (std::list<ComplexArray2D>::iterator it = specturmList.begin(); it !=  specturmList.end(); ++it){
					const int kNumFrame = (const int)it->shape()[0];
					std::vector<float> enhancedAudioPart = enhanceFromSpectrum(*it,kNumFrame);
                    for (std::vector<float>::iterator it = enhancedAudioPart.begin(); it != enhancedAudioPart.end(); it++)
                    {
                        enhancedAudio.push_back(*it);
                    }
				}
				return enhancedAudio;
			}
		}
		return std::vector<float>();
	}

private:
	bool isInitialzed;
	std::vector<float> noiseSpectrum;
	std::list<ComplexArray2D> specturmList;
	int numInitFrame;
	//std::vector<float> noiseInitialBuffer;
	//int idxInitialBuffer;

	std::vector<float> enhanceFromSpectrum(ComplexArray2D &signalSpecturm , int kNumFrame)
	{
		assert(signalSpecturm.shape()[0] == kNumFrame);
		assert(signalSpecturm.shape()[1] == kSpectrumDim);
		for (int nFrame = 0; nFrame != kNumFrame ; ++nFrame){
			noiseEstimater.template apply<const ComplexType*,float*>(signalSpecturm.data() + nFrame * kSpectrumDim ,&noiseSpectrum[0]);
			spectrumRestorer.template apply<const ComplexType*,const float*,ComplexType*>(signalSpecturm.data() + nFrame * kSpectrumDim,&noiseSpectrum[0],signalSpecturm.data() + nFrame * kSpectrumDim);
		}

		static const float quantilizeMax = (float)0.9999;
		static const float quantilizeMin = (float)-0.9999;
		std::vector<float> enhancedAudio = spectrumEngine.spectrum2Wave(signalSpecturm);
		for (int i=0; i<enhancedAudio.size(); ++i)
		{
			enhancedAudio[i] = enhancedAudio[i] < quantilizeMax ? enhancedAudio[i] : quantilizeMax;
			enhancedAudio[i] = enhancedAudio[i] > quantilizeMin ? enhancedAudio[i] : quantilizeMin;
		}
		return enhancedAudio;
	}



	NoiseEstimateT noiseEstimater;
	SpectrumRestorerT spectrumRestorer;
	SpectrumEngine<Complex> spectrumEngine;

};
    
}
#endif // SPEECHENHANCER_H_

