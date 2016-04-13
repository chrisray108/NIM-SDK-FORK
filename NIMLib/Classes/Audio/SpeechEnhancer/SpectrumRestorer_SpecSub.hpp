#ifndef SPEC_SUB_H_
#define SPEC_SUB_H_

namespace NIM {

class SpectrumRestorer_Sub//spectrum subtraction in magnitude domain
{
public:
	SpectrumRestorer_Sub(int freqBins,float uselessParam = float(0.0)):m_freqBins(freqBins){
		m_noiseFloor = (float)0.01;
		m_aLow = -5;
		m_aHigh = 20;
		m_gainMax = 1;
		m_am = 3;
	};
	~SpectrumRestorer_Sub(void){};

	template<typename SepcrumInputT,typename NoiseInputT,typename OutputT>
	bool apply(SepcrumInputT signal,NoiseInputT noise, OutputT restored){
		float signalPower_sum = (float)0.0;
		float noisePower_sum = (float)0.0;
		for (int i=0; i<m_freqBins; ++i){
			signalPower_sum += signal[i].power();
			noisePower_sum += noise[i];
		}
		float af;//calculate parameter af
		float zeroPower_thres = (float)(1e-10);
		if (noisePower_sum < zeroPower_thres){
			af = (float)1.0;
		}
		else{
			float af_1 = (float)((10.0 * log10f(signalPower_sum/noisePower_sum)) > m_aLow ? (10.0 * log10f(signalPower_sum/noisePower_sum)) : m_aLow);
			af_1 = af_1 < m_aHigh ? af_1 : m_aHigh;
			af = (float)(1.0 + (m_am - 1)*(af_1 - m_aHigh)/(m_aLow - m_aHigh));
		}
		float* v = new float[m_freqBins];//calculate parameter v
		if (signalPower_sum < zeroPower_thres){
			for (int i=0; i<m_freqBins; ++i){
				v[i] = sqrtf(noise[i]);
			}
		} 
		else{
			for (int i=0; i<m_freqBins; ++i){
				v[i] = sqrtf(noise[i]/signal[i].power());
			}
		}
		af = sqrtf(af);//calculate spectrum gain
		float bf = sqrtf(m_noiseFloor);
		float* specGain = new float[m_freqBins];
		for (int i=0; i<m_freqBins; ++i){
			if (v[i] >= 1.0/(af + bf)){
				specGain[i] = (bf*v[i]) < m_gainMax ? (bf*v[i]) : m_gainMax;
			}
			else{
				specGain[i] = (float)(1.0 - af * v[i]);
			}
			restored[i] = signal[i] * specGain[i];
		}
		delete[] v;
		delete[] specGain;

		return true;
	};
private:
	const int m_freqBins;
	float m_noiseFloor;
	float m_aLow;
	float m_aHigh;
	float m_gainMax;
	float m_am;
};
    
}
#endif//SPEC_SUB_H_
