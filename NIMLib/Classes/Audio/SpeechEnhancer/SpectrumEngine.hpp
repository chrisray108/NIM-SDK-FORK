#ifndef FFT_WRAPPER_H_
#define FFT_WRAPPER_H_

#include <vector>
#include "kiss_fftr.h"
#include <boost/multi_array.hpp>

namespace NIM {

#define hammingPI 3.14159265358979323846
typedef float RealType ;
struct ComplexType{
	RealType real;
	RealType image;
	ComplexType(RealType r, RealType i):real(r),image(i){};
	inline ComplexType complexMultiply(const ComplexType& complexNum){
		return ComplexType(real*complexNum.real - image*complexNum.image, real*complexNum.image + image*complexNum.real);
	};
	inline float power() const{
		return real*real + image*image;
	}
	ComplexType(){};
	~ComplexType(){};
};
typedef nimboost::multi_array<ComplexType, 2> ComplexArray2D;
inline ComplexType operator*(const ComplexType& left, float right){
	return ComplexType(	left.real*right, left.image*right);
};
enum FFTWindowType{
	Hamming,
	Hamming_Gain1,
	Hanning
};
enum SpectrumType{Power, Amp,Complex};
template<SpectrumType ST >
struct SpectrumType2DataType{typedef RealType DataType;};
template<>
struct SpectrumType2DataType<Complex>{typedef ComplexType DataType;};

template<FFTWindowType W > inline std::vector<RealType> getFFTWindow(int fftSize, int hopSize);
template<> 
inline std::vector<RealType> getFFTWindow<Hamming>(int fftSize, int hopSize){
	std::vector<RealType> windowCoef;
	for (int i=0; i<fftSize; ++i){
		windowCoef.push_back((RealType)sqrt(0.54 - 0.46 * cos(2*hammingPI*i/fftSize)));
	}
	RealType normalizeCoef = (RealType)(0.0);
	for (int i=0; i<fftSize; i = i+hopSize){
		normalizeCoef += windowCoef[i] * windowCoef[i];
	}
	normalizeCoef = sqrt(1.1 * normalizeCoef);
	for (int i=0; i<(int)(windowCoef.size()); ++i){
		windowCoef[i] = windowCoef[i]/normalizeCoef;
	}
	return windowCoef;
};
template<> 
inline std::vector<RealType> getFFTWindow<Hamming_Gain1>(int fftSize, int hopSize){
	std::vector<RealType> windowCoef;
	for (int i=0; i<fftSize; ++i){
		windowCoef.push_back((RealType)(0.54 - 0.46 * cos(2*hammingPI*i/fftSize)));
	}
	RealType normalizeCoef = (RealType)(0.0);
	for (int i=0; i<fftSize; i = i+hopSize){
		normalizeCoef += windowCoef[i] * windowCoef[i];
	}
	normalizeCoef = sqrt(normalizeCoef);
	for (int i=0; i<(int)(windowCoef.size()); ++i){
		windowCoef[i] = windowCoef[i]/normalizeCoef;
	}
	return windowCoef;
};

template<SpectrumType ST,typename ReturnT>
inline ReturnT getFFTResults(kiss_fft_cpx& kfftOut);

template<>
inline SpectrumType2DataType<Power>::DataType getFFTResults<Power,SpectrumType2DataType<Power>::DataType>(kiss_fft_cpx& kfftOut){
	return kfftOut.r * kfftOut.r + kfftOut.i * kfftOut.i;
};
template<>
inline SpectrumType2DataType<Amp>::DataType getFFTResults<Amp,SpectrumType2DataType<Amp>::DataType>(kiss_fft_cpx& kfftOut){
	return sqrt(kfftOut.r * kfftOut.r + kfftOut.i * kfftOut.i);
};
template<>
inline SpectrumType2DataType<Complex>::DataType getFFTResults<Complex,SpectrumType2DataType<Complex>::DataType>(kiss_fft_cpx& kfftOut){
	return ComplexType(kfftOut.r,kfftOut.i);
};

template<SpectrumType ST, FFTWindowType W = Hamming>
class SpectrumEngine
{
private:
	typedef typename SpectrumType2DataType<ST>::DataType ReturnT;
public:
	SpectrumEngine(int fftSize, int hopSize):m_fftSize(fftSize), m_fftHop(hopSize), m_freqUsed(fftSize/2 + 1)
    {
		m_fftState = kiss_fftr_alloc(m_fftSize, 0, NULL, NULL);
		m_ifftState = kiss_fftr_alloc(m_fftSize, 1, NULL, NULL);
		m_fftOut = new kiss_fft_cpx[m_freqUsed];
		m_ifftIn = new kiss_fft_cpx[m_freqUsed];
		m_ifftOut = new kiss_fft_scalar[m_fftSize];
		m_fftWindow = getFFTWindow<W>(m_fftSize, m_fftHop);
		m_dataWindowed = std::vector<RealType>(m_fftSize);
		m_outputTail = std::vector<RealType>(m_fftSize - m_fftHop, RealType(0.0));
		m_ifftParam_t = std::vector<ComplexType>(m_freqUsed);
		for (int i=0; i<m_freqUsed; ++i){
			m_ifftParam_t[i].real = (RealType)(0.5 + 0.5 * sin(2*hammingPI*i/m_fftSize));
			m_ifftParam_t[i].image = (RealType)(-0.5 * cos(2*hammingPI*i/m_fftSize));
		}
	};

	~SpectrumEngine(void){
		free(m_fftState);
		free(m_ifftState);
		delete[] m_fftOut;
		delete[] m_ifftIn;
		delete[] m_ifftOut;
	};

	/*inline int getTotalFrame(const int dataNum ){
		return (dataNum - kFFTNum) / kFFTHop;
	}
	inline int getUsedDataNum(const int dataNum ){
		return getTotalFrame()*kFFTHop + kFFTNum;
	}*/

	nimboost::multi_array<ReturnT, 2> wave2Spectrum(const RealType* audioData,const int dataNum){
		int dataLength = dataNum + (int)m_inputTail.size();
		if (dataLength < m_fftSize){
			for (int i=0; i<dataNum; ++i){
				m_inputTail.push_back(audioData[i]);
			}
			return nimboost::multi_array<ReturnT, 2>();
		}
		int frameNum = (dataLength - m_fftSize)/m_fftHop + 1;
		nimboost::multi_array<ReturnT, 2> fftResult(nimboost::extents[frameNum][m_freqUsed]);
		
		for(int i=0; i<frameNum; i++){
			if (i < m_fftSize/m_fftHop && i*m_fftHop < (int)m_inputTail.size()){
				RealType* inputAudio = new RealType[m_fftSize];
				for (int startIndex = i*m_fftHop; startIndex < (int)m_inputTail.size(); ++startIndex){
					inputAudio[startIndex - i*m_fftHop] = m_inputTail[startIndex];
				}
				for (int startIndex = 0; startIndex < (m_fftSize - (int)m_inputTail.size() + i*m_fftHop); ++startIndex){
					inputAudio[startIndex + (int)m_inputTail.size() - i*m_fftHop] = audioData[startIndex];
				}
				applyWindow(inputAudio);
				delete[] inputAudio;
			}
			else{
				int startIndex = i*m_fftHop - (int)m_inputTail.size();
				applyWindow(audioData + startIndex);
			}
			kiss_fftr(m_fftState, &(m_dataWindowed[0]), m_fftOut);
			for(int k=0; k<m_freqUsed; ++k){
				fftResult[i][k] = getFFTResults<ST,ReturnT>(m_fftOut[k]);
			}
		}

		int tailIndex = frameNum * m_fftHop - (int)m_inputTail.size();
		std::vector<RealType> inputTailBuf = m_inputTail;
		m_inputTail.clear();
		for (int i = tailIndex; i<dataNum; ++i){
			if (i < 0){
				m_inputTail.push_back(inputTailBuf[inputTailBuf.size() + i]);
			} 
			else{
				m_inputTail.push_back(audioData[i]);
			}
		}

		return fftResult;
	};

	std::vector<RealType> spectrum2Wave(nimboost::multi_array<ComplexType, 2>& audioSpectrum){
		assert(audioSpectrum.shape()[1] == m_freqUsed);
		std::vector<RealType> ifftResult;
		for(int i=0; i<audioSpectrum.shape()[0]; ++i){
			audioSpectrum[i][m_freqUsed-1].image = (RealType)(0.0);
			for (int j=0; j<audioSpectrum.shape()[1]; ++j){
				m_ifftIn[j].r = audioSpectrum[i][j].real;
				m_ifftIn[j].i = audioSpectrum[i][j].image;
			}
			kiss_fftri(m_ifftState, m_ifftIn, m_ifftOut);
			for (int k=0; k<m_fftSize; ++k){
				m_ifftOut[k] = m_ifftOut[k] / (float)m_fftSize;
			}

			applyWindow(m_ifftOut);

			for (int k=0; k<m_outputTail.size(); ++k){
				m_dataWindowed[k] += m_outputTail[k];
			}
			for (int k=0; k<m_fftHop; ++k){
				ifftResult.push_back(m_dataWindowed[k]);
			}
			for (int k=m_fftHop; k<(int)m_dataWindowed.size(); ++k){
				m_outputTail[k-m_fftHop] = m_dataWindowed[k];
			}
		}

		return ifftResult;
	};

	void clearBuf(){
		m_inputTail.clear();
		m_outputTail.clear();
	}

private:
	kiss_fftr_cfg m_fftState;
	kiss_fftr_cfg m_ifftState;
	kiss_fft_cpx* m_fftOut;
	kiss_fft_cpx* m_ifftIn;
	kiss_fft_scalar* m_ifftOut;

	const int m_fftSize, m_fftHop, m_freqUsed;

	std::vector<RealType> m_fftWindow;
	std::vector<RealType> m_dataWindowed;

	std::vector<ComplexType> m_ifftParam_t;

	std::vector<RealType> m_inputTail;
	std::vector<RealType> m_outputTail;

	void applyWindow(const RealType* data){
		for (int j = 0; j != m_fftSize; ++j){
			m_dataWindowed[j] = data[j] * m_fftWindow[j];
		}
	}
};

}
#endif // FFT_WRAPPER_H_
