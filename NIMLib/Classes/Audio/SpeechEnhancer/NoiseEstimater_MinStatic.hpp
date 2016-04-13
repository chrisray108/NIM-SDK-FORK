#ifndef NOISEESTIMATE_MS_H_
#define NOISEESTIMATE_MS_H_
#include <assert.h>
#include <vector>

namespace NIM {

class NoiseEstimater_MinStatic
{
public:
	NoiseEstimater_MinStatic(int freqNum, float frameIncrement):m_freqNum(freqNum), m_frameIncrement(frameIncrement){
		m_frameAccumulate = 0;
		m_alphaC = (float)0.7;
		m_alphaC_min = (float)0.7;
		m_alphaMax = 0.96;
		m_alphaMin = 0.3;
		m_betaMax = 0.8;
		float tpfall = 0.064;//time constant for P to fall (12)
		m_snrPower = - frameIncrement / tpfall;
		m_numU = 8;
		float timePiece = 1.536;//time to take minimum over
		assert(m_frameIncrement > 0.001);
		m_numV = (int)(timePiece/(m_numU * m_frameIncrement) + 0.5);
		assert(m_numV >= 4);
		m_numD = m_numU * m_numV;
		m_qeqiMax = (float)(1.0 / 2.0);
		m_qeqiMin = (float)(1.0 / 14.0);
		m_av = 2.12;
		m_qith = std::vector<float>(4);
		m_qith[0] = (float)0.03;
		m_qith[1] = (float)0.05;
		m_qith[2] = (float)0.06;
		m_qith[3] = (float)FLT_MAX;
		m_nsmdb = std::vector<float>(4);
		m_nsmdb[0] = (float)47;
		m_nsmdb[1] = (float)31.4;
		m_nsmdb[2] = (float)15.7;
		m_nsmdb[3] = (float)4.1;
		calculateMH(m_numD, m_mD, m_hD);
		calculateMH(m_numV, m_mV, m_hV);
		for (int i=0; i<(int)m_nsmdb.size(); ++i){
			m_nsms.push_back(powf(10.0, m_nsmdb[i]*m_numV*m_frameIncrement/10.0));
		}
	};

	template<typename SepcrumInputT,typename NoiseT>
	bool apply(SepcrumInputT signal,NoiseT noise){
		if (m_frameAccumulate == 0){
			m_p = std::vector<float>(m_freqNum);
			for (int i=0; i<m_freqNum; ++i){
				m_p[i] = signal[i].power();
			}
			m_ac = 1.0;
			m_sn2 = m_p;
			m_pb = m_p;
			m_pb2 = m_pb;
			for (int i=0; i<m_freqNum; ++i){
				m_pb2[i] = m_pb2[i] * m_pb2[i];
			}
			m_pminu = m_p;
			m_actmin.clear();
			for (int i=0; i<m_freqNum; ++i){
				m_actmin.push_back(FLT_MAX);
			}
			m_actminsub = m_actmin;
			m_subwc = m_numV;
			m_actbuf.clear();
			for (int i=0; i<m_numU; ++i){
				m_actbuf.push_back(m_actmin);
			}
			m_ibuf = -1;
			m_lminflag = std::vector<int>(m_freqNum, 0);
		}

		std::vector<float> yft;
		float sum_p = 0.0;
		float sum_yft = 0.0;
		float sum_sn2 = 0.0;
		for (int i=0; i<m_freqNum; ++i){
			yft.push_back(signal[i].power());
			sum_p += m_p[i];
			sum_sn2 += m_sn2[i];
			sum_yft += signal[i].power();
		}
		float zeroEnergy = 1e-10;//protection for all zero input
		if (sum_yft < zeroEnergy){
			for (int i=0; i<m_freqNum; ++i){
				noise[i] = signal[i].power();
			}
			return true;
		}
		float acb = 1.0 / (1.0 + (sum_p/sum_yft - 1.0)*(sum_p/sum_yft - 1.0));
		m_ac = m_alphaC * m_ac + (1 - m_alphaC) * (acb > m_alphaC_min ? acb : m_alphaC_min);
		std::vector<float> ah;
		for (int i=0; i<m_freqNum; ++i){
			ah.push_back((m_alphaMax * m_ac) / ((1.0 + (m_p[i]/m_sn2[i] - 1.0)*(m_p[i]/m_sn2[i] - 1.0))));
		}
		float snr = sum_p / sum_sn2;
		float alphaHat = m_alphaMin < powf(snr, m_snrPower) ? m_alphaMin : powf(snr, m_snrPower);
		for (int i=0; i<m_freqNum; ++i){
			ah[i] = ah[i] > alphaHat ? ah[i] : alphaHat;
			m_p[i] = ah[i] * m_p[i] + (1.0 - ah[i]) * yft[i];//smoothed noisy speech power
		}
		std::vector<float> b;
		for (int i=0; i<m_freqNum; ++i){
			b.push_back(ah[i]*ah[i] < m_betaMax ? ah[i]*ah[i] : m_betaMax);//smoothing constant
			m_pb[i] = b[i] * m_pb[i] + (1.0 - b[i]) * m_p[i];//smoothed periodogram (20)
			m_pb2[i] = b[i] * m_pb2[i] + (1.0 - b[i]) * m_p[i] * m_p[i];//smoothed periodogram squared (21)
		}

		std::vector<float> qeqi;
		float qiav = 0.0;
		for (int i=0; i<m_freqNum; ++i){
			float qeqiBuf = (m_pb2[i] - m_pb[i] * m_pb[i])/(2.0 * m_sn2[i] * m_sn2[i]) < m_qeqiMax ? (m_pb2[i] - m_pb[i] * m_pb[i])/(2.0 * m_sn2[i] * m_sn2[i]) : m_qeqiMax;
			qeqi.push_back(qeqiBuf > m_qeqiMin/(m_frameAccumulate + 1.0) ? qeqiBuf : m_qeqiMin/(m_frameAccumulate + 1.0));
			qiav += qeqi[i];
		}
		qiav = qiav / m_freqNum;
		float bc = 1.0 + m_av * sqrtf(qiav);//bias correction factor
		std::vector<float> bmind;
		std::vector<float> bminv;
		std::vector<int> kmod;
		for (int i=0; i<m_freqNum; ++i){
			bmind.push_back(1.0 + 2.0*(m_numD-1)*(1-m_mD)/(1.0/qeqi[i] - 2.0*m_mD));
			bminv.push_back(1.0 + 2.0*(m_numV-1)*(1-m_mV)/(1.0/qeqi[i] - 2.0*m_mV));
			if (bc * m_p[i] * bmind[i] < m_actmin[i]){
				kmod.push_back(1);
				m_actmin[i] = bc * m_p[i] * bmind[i];
				m_actminsub[i] = bc * m_p[i] * bminv[i];
			}
			else{
				kmod.push_back(0);
			}
		}

		if (m_subwc > 1 && m_subwc < m_numV){
			for (int i=0; i<m_freqNum; ++i){
				m_lminflag[i] = (int)(m_lminflag[i] || kmod[i]);
				m_pminu[i] = m_actminsub[i] < m_pminu[i] ? m_actminsub[i] : m_pminu[i];
				m_sn2[i] = m_pminu[i];
			}
		} 
		else if (m_subwc >= m_numV){
			m_ibuf = (m_ibuf + 1) % m_numU;//do buffer switch
			for (int i=0; i<m_freqNum; ++i){
				m_actbuf[m_ibuf][i] = m_actmin[i];
				m_pminu[i] = m_actbuf[0][i];
				for (int j=0; j<(int)m_actbuf.size(); ++j){
					m_pminu[i] = m_pminu[i] < m_actbuf[j][i] ? m_pminu[i] : m_actbuf[j][i];
				}
			}
			float nsm = 0.0;
			for (int i=0; i<(int)m_qith.size(); ++i){
				if (qiav < m_qith[i]){
					nsm = m_nsms[i];
					break;
				}
			}
			for (int i=0; i<m_freqNum; ++i){
				if (m_lminflag[i] == 1 && kmod[i] == 0 && m_actminsub[i] < nsm * m_pminu[i] && m_actminsub[i] > m_pminu[i]){
					m_pminu[i] = m_actminsub[i];
					for (int k=0; k<(int)m_actbuf.size(); ++k){
						m_actbuf[k][i] = m_pminu[i];
					}
				}
				m_lminflag[i] = 0;
				m_actmin[i] = FLT_MAX;
				m_subwc = 0;
			}
		}

		for (int i=0; i<m_freqNum; ++i){
			noise[i] = m_sn2[i];
		}
		m_subwc++;
		m_frameAccumulate++;

		return true;
	};

	template<typename SepcrumInputT>
	bool setInitFrame(const SepcrumInputT& signal){
		m_frameAccumulate = 0;
		return true;
	};

private:
	const int m_freqNum;
	const float m_frameIncrement;
	int m_frameAccumulate;//number of frames processed
	float m_alphaC;//smoothing constant for alpha c in equ(11)
	float m_alphaC_min;//minimum value of alpha c in equ(11)
	float m_alphaMax;//max smoothing constant in (3)
	float m_alphaMin;//min smoothing constant in (3)
	float m_betaMax;//max smoothing constant in (20)
	float m_snrPower;//power of snr
	int m_numU;//number of subwindows
	int m_numV;//number of frames in each subwindow
	int m_numD;//number of frames in the whole window
	float m_qeqiMax;//maximum value of Qeq inverse (23)
	float m_qeqiMin;//minimum value of Qeq per frame inverse
	float m_av;//fudge factor for bc calculation (23 + 13 lines)
	std::vector<float> m_qith;//noise slope thresholds in dB/s
	std::vector<float> m_nsmdb;//maximum permitted +ve noise slope in dB/s
	std::vector<float> m_nsms;
	float m_mD;//calculate the constants M(D) and H(D) from Table 3
	float m_hD;
	float m_mV;
	float m_hV;
	//the following parameters are to be initialized when processing the first frame
	std::vector<float> m_p;//smoothed power spectrum
	float m_ac;//correction factor (9)
	std::vector<float> m_sn2;//estimated noise power
	std::vector<float> m_pb;//smoothed noisy speech power (20)
	std::vector<float> m_pb2;//smoothed periodogram squared (21)
	std::vector<float> m_pminu;
	std::vector<float> m_actmin;//Running minimum estimate
	std::vector<float> m_actminsub;//sub-window minimum estimate
	int m_subwc;
	std::vector<std::vector<float>> m_actbuf;//buffer to store subwindow minimum
	int m_ibuf;
	std::vector<int> m_lminflag;//flag to remember local minimum

	void calculateMH(int d, float& m, float& h){
		struct DMH{
			int m_d;
			float m_m;
			float m_h;
			DMH(int d, float m, float h):m_d(d), m_m(m), m_h(h){};
		};
		std::vector<DMH> dmhTable;
		dmhTable.push_back(DMH(1, 0.0, 0.0));
		dmhTable.push_back(DMH(2, 0.26, 0.15));
		dmhTable.push_back(DMH(5, 0.48, 0.48));
		dmhTable.push_back(DMH(8, 0.58, 0.78));
		dmhTable.push_back(DMH(10, 0.61, 0.98));
		dmhTable.push_back(DMH(15, 0.668, 1.55));
		dmhTable.push_back(DMH(20, 0.705, 2.0));
		dmhTable.push_back(DMH(30, 0.706, 2.3));
		dmhTable.push_back(DMH(40, 0.8, 2.52));
		dmhTable.push_back(DMH(60, 0.841, 3.1));
		dmhTable.push_back(DMH(80, 0.865, 3.38));
		dmhTable.push_back(DMH(120, 0.89, 4.15));
		dmhTable.push_back(DMH(140, 0.9, 4.35));
		dmhTable.push_back(DMH(160, 0.91, 4.25));
		dmhTable.push_back(DMH(180, 0.92, 3.9));
		dmhTable.push_back(DMH(220, 0.93, 4.1));
		dmhTable.push_back(DMH(260, 0.935, 4.7));
		dmhTable.push_back(DMH(300, 0.94, 5.0));

		int dIndex_i = (int)dmhTable.size() - 1;
		int dIndex_j = (int)dmhTable.size() - 1;
		for (int i=0; i<(int)dmhTable.size(); ++i){
			if (d <= dmhTable[i].m_d){
				dIndex_i = i;
				dIndex_j = i - 1;
				break;
			}
		}
		if (d == dmhTable[dIndex_i].m_d){
			m = dmhTable[dIndex_i].m_m;
			h = dmhTable[dIndex_i].m_h;
		} 
		else{
			float qj = sqrtf(dmhTable[dIndex_i - 1].m_d);
			float qi = sqrtf(dmhTable[dIndex_i].m_d);
			float q = sqrtf(d);
			h = dmhTable[dIndex_i].m_h + (q - qi)*(dmhTable[dIndex_j].m_h - dmhTable[dIndex_i].m_h)/(qj - qi);
			m = dmhTable[dIndex_i].m_m + (qi*qj/q - qj)*(dmhTable[dIndex_j].m_m - dmhTable[dIndex_i].m_m)/(qi - qj);
		}
	};
};
    
}

#endif //NOISEESTIMATE_MS_H_