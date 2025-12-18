# FastPitch Korean TTS

한국어 음성 합성 (Text-to-Speech) 프로젝트
**Jetson Orin Nano 최적화 완료** (JetPack 6.1 / PyTorch 2.5)

---

## 빠른 시작 (Jetson Orin Nano)

### 1. 프로젝트 다운로드
```bash
git clone https://github.com/your-repo/FastPitch_Korean.git
cd FastPitch_Korean
```

### 2. 가상환경 설치 (한 번만 실행)
```bash
chmod +x setup_venv_jetson.sh
./setup_venv_jetson.sh
```

### 3. 실행

**방법 A: 간편 실행 (권장)**
```bash
./run.sh
```

**방법 B: 수동 실행**
```bash
source .venv/bin/activate
python tts_gui.py
```

**끝!** GUI 창이 열리면 텍스트를 입력하고 "음성 합성" 버튼을 클릭하세요.

**가상환경 종료**: `deactivate`

---

## 시스템 요구사항

### Jetson Orin Nano (권장)
- **JetPack**: 6.1 (L4T 36.4)
- **Python**: 3.10.12
- **CUDA**: 12.6
- **RAM**: 8GB 권장
- **Storage**: 최소 6GB

### PC (개발용)
- **OS**: Ubuntu 20.04+ / Windows 10+
- **Python**: 3.8+
- **CUDA**: 11.0+ (GPU 사용 시)
- **RAM**: 16GB 권장

---

## 주요 기능

- ✅ 한국어 텍스트를 자연스러운 음성으로 변환
- ✅ GUI 인터페이스 (자동 재생 기능)
- ✅ Jetson Orin Nano 최적화 (실시간 합성 가능)
- ✅ FastSpeech2 기반 고품질 음성
- ✅ VocGAN Vocoder 사용

---

## 상세 설치 가이드

### Jetson Orin Nano

#### 방법 1: 가상환경 사용 (권장)
```bash
git clone https://github.com/your-repo/FastPitch_Korean.git
cd FastPitch_Korean

# 가상환경 설치
chmod +x setup_venv_jetson.sh
./setup_venv_jetson.sh

# 가상환경 활성화
source .venv/bin/activate

# 프로그램 실행
python tts_gui.py
```

#### 방법 2: 시스템 전역 설치
```bash
git clone https://github.com/your-repo/FastPitch_Korean.git
cd FastPitch_Korean
chmod +x setup_jetson.sh
./setup_jetson.sh
python3 tts_gui.py
```

#### 방법 3: 수동 설치

**1. 시스템 패키지**
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential cmake git \
    libopenblas-dev libomp-dev \
    ffmpeg libsndfile1 \
    python3-pip python3-dev \
    default-jdk python3-tk cython3
```

**2. PyTorch 2.5 (JetPack 6.1 전용)**
```bash
pip3 install --no-cache \
    https://developer.download.nvidia.com/compute/redist/jp/v61/pytorch/torch-2.5.0a0+872d972e41.nv24.08.17622132-cp310-cp310-linux_aarch64.whl
```

**3. Python 패키지**
```bash
pip3 install \
    librosa==0.10.2 soundfile==0.12.1 resampy==0.4.3 \
    jamo==0.4.1 g2pK==0.1.2 JPype1==1.5.0 konlpy==0.6.0 \
    numpy scipy scikit-learn matplotlib tqdm pyyaml \
    inflect unidecode tgt pygame==2.6.0 pyworld
```

### PC (Windows/Linux)

**1. Python 패키지**
```bash
pip install -r requirements.txt
```

**2. PyTorch 설치** (GPU 사용 시)
```bash
# CUDA 11.8
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.1
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
```

---

## 사용 방법

### GUI 모드 (권장)

**가상환경 사용 시**:
```bash
source .venv/bin/activate  # 가상환경 활성화
python tts_gui.py
```

**시스템 전역 설치 시**:
```bash
python3 tts_gui.py
```

1. GUI 창이 열리면 텍스트 입력
2. "음성 합성" 버튼 클릭
3. 자동으로 음성 재생

**종료 후 가상환경 비활성화**: `deactivate`

### CLI 모드

**가상환경 사용 시**:
```bash
source .venv/bin/activate
python synthesize.py --step 350000
```

**시스템 전역 설치 시**:
```bash
python3 synthesize.py --step 350000
```

텍스트를 입력하면 `results/` 폴더에 WAV 파일 생성

---

## 성능

### Jetson Orin Nano 8GB (JetPack 6.1)

| 문장 길이 | 합성 시간 | 메모리 사용 |
|----------|---------|-----------|
| 짧음 (3-5초) | 0.8-1.5초 | 3.5GB |
| 중간 (5-10초) | 1.5-3초 | 3.8GB |
| 긴 (10-15초) | 3-5초 | 4.2GB |

**모델 로드**: 3-5초 (최초 1회)

### 성능 최적화 팁

**1. MAX 성능 모드**
```bash
sudo nvpmodel -m 0
sudo jetson_clocks
```

**2. Swap 메모리 추가** (메모리 부족 시)
```bash
sudo fallocate -l 8G /mnt/8GB.swap
sudo chmod 600 /mnt/8GB.swap
sudo mkswap /mnt/8GB.swap
sudo swapon /mnt/8GB.swap
echo '/mnt/8GB.swap none swap sw 0 0' | sudo tee -a /etc/fstab
```

**3. FP16 사용** (고급)
코드 수정으로 메모리 30% 절약, 속도 20-30% 향상 가능

---

## 프로젝트 구조

```
FastPitch_Korean/
├── .venv/                      # Python 가상환경 (설치 후 생성)
├── ckpt/                       # 학습된 모델
│   └── archive/data/kss/
│       └── checkpoint_350000.pth.tar (330MB)
├── vocoder/                    # VocGAN vocoder
│   └── pretrained_models/
│       └── vocgan_kss_pretrained_model_epoch_4500.pt (104MB)
├── preprocessed/kss/           # 전처리 데이터
│   ├── mel_stat.npy
│   ├── f0_stat.npy
│   └── energy_stat.npy
├── text/                       # 텍스트 처리
├── tts_gui.py                  # GUI 프로그램 ⭐
├── synthesize.py               # CLI 프로그램
├── fastspeech2.py              # FastSpeech2 모델
├── hparams.py                  # 설정 파일
├── utils.py                    # 유틸리티
├── setup_venv_jetson.sh        # 가상환경 설치 스크립트 ⭐
├── setup_jetson.sh             # 시스템 전역 설치 스크립트
├── run.sh                      # 간편 실행 스크립트 ⭐
├── requirements_jetson.txt     # Python 패키지 목록
└── README.md                   # 이 파일
```

---

## 문제 해결

### 1. "CUDA out of memory" 오류

**해결책**: Swap 메모리 추가
```bash
sudo fallocate -l 8G /mnt/8GB.swap
sudo chmod 600 /mnt/8GB.swap
sudo mkswap /mnt/8GB.swap
sudo swapon /mnt/8GB.swap
```

### 2. "No module named 'jamo'" 오류

**해결책**: 패키지 재설치
```bash
pip3 install jamo==0.4.1 g2pK==0.1.2
```

### 3. "Java not found" 오류 (KoNLPy)

**해결책**: Java 설치
```bash
sudo apt-get install -y default-jdk
```

### 4. pyworld 설치 실패

**해결책**: 의존성 설치 후 재시도
```bash
sudo apt-get install -y cython3 python3-dev
pip3 install numpy
pip3 install pyworld --no-binary pyworld
```

### 5. pygame 오디오 재생 안됨

**해결책**: PulseAudio 재시작
```bash
pulseaudio --check
pulseaudio --start
pip3 install --upgrade pygame==2.6.0
```

### 6. 음성 품질이 나쁨 (잡음)

**원인**: 전처리 통계 파일 문제

**해결책**: 데이터 재전처리 필요 (PC에서)
```bash
# PC에서 실행
python preprocess.py
```

---

## JetPack 6.1 마이그레이션 정보

이 프로젝트는 JetPack 6.1 (PyTorch 2.5)에 최적화되었습니다.

### 주요 변경사항

1. **torch.load() 호환성**
   - PyTorch 2.5 요구사항에 따라 `weights_only=False` 추가
   - 파일: `synthesize.py`, `utils.py`, `tts_gui.py`

2. **CUDA 최적화**
   - `hparams.py`에 cudnn 최적화 코드 추가
   ```python
   torch.backends.cudnn.benchmark = True
   torch.backends.cudnn.enabled = True
   ```

3. **Python 3.10 호환**
   - 모든 코드 Python 3.10.12 테스트 완료

### 이전 버전 (JetPack 5.x)

JetPack 5.x를 사용하는 경우:
- PyTorch 1.6 버전 필요
- 코드 수정 필요 (`weights_only` 파라미터 제거)

---

## 개발자 가이드

### 데이터 전처리 (PC에서 수행)

**1. KSS 데이터셋 다운로드**
```bash
# KSS 데이터셋을 dataset/kss/ 에 배치
# dataset/kss/wavs/ - 음성 파일
# dataset/kss/transcript.v.1.4.txt - 스크립트
```

**2. Montreal Forced Aligner (MFA)**
```bash
# TextGrid 생성
# 자세한 내용은 MFA 공식 문서 참조
```

**3. 전처리 실행**
```bash
python preprocess.py
```

### 학습 (PC/워크스테이션)

```bash
python train_fastpitch.py
```

**요구사항**:
- GPU: NVIDIA GPU (16GB+ VRAM 권장)
- 시간: 약 12-24시간 (GPU 성능에 따라)

---

## 기술 스택

- **모델**: FastSpeech2 (Non-autoregressive TTS)
- **Vocoder**: VocGAN
- **텍스트 처리**:
  - g2pK (Grapheme-to-Phoneme)
  - jamo (한글 자모 분해)
  - KoNLPy (형태소 분석)
- **오디오**: librosa, soundfile, pyworld
- **딥러닝**: PyTorch 2.5 (Jetson) / PyTorch 1.6+ (PC)

---

## 라이선스

이 프로젝트는 연구 및 교육 목적으로 사용 가능합니다.

---

## 참고 자료

### 공식 문서
- **NVIDIA Jetson Forum**: https://forums.developer.nvidia.com/c/agx-autonomous-machines/jetson-embedded-systems/
- **PyTorch for Jetson**: https://forums.developer.nvidia.com/t/pytorch-for-jetson/72048

### 관련 프로젝트
- **FastSpeech2**: https://github.com/ming024/FastSpeech2
- **KSS Dataset**: https://www.kaggle.com/datasets/bryanpark/korean-single-speaker-speech-dataset
- **g2pK**: https://github.com/Kyubyong/g2pK
- **원본 프로젝트**: https://github.com/jeromeryu/FastPitch_Korean

---

## Changelog

### v2.0 (2025-12-18)
- ✅ JetPack 6.1 (PyTorch 2.5) 마이그레이션 완료
- ✅ Jetson Orin Nano 최적화
- ✅ 간편 설치 스크립트 추가 (`setup_jetson.sh`)
- ✅ `python -m tts_gui` 실행 지원
- ✅ README 통합 및 간소화

### v1.0
- 초기 버전 (JetPack 5.x 기반)

---

## 문의 및 지원

문제가 발생하면 다음 정보를 포함하여 이슈를 생성해주세요:

1. **환경**:
   ```bash
   cat /etc/nv_tegra_release  # Jetson
   python3 --version
   python3 -c "import torch; print(torch.__version__)"
   ```

2. **에러 메시지**: 전체 에러 로그

3. **실행 명령어**: 어떤 명령어를 실행했는지

---

**개발**: FastPitch Korean TTS Team
**최종 업데이트**: 2025-12-18
**버전**: 2.0 (Jetson Orin Nano Optimized)
