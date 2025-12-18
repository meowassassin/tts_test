# 모델 파일 다운로드 가이드

이 프로젝트는 대용량 모델 파일을 GitHub에서 제외하였습니다.
아래 방법으로 모델 파일을 다운로드하세요.

## 필수 모델 파일

### 1. FastSpeech2 체크포인트 (330MB)
**경로**: `ckpt/archive/data/kss/checkpoint_350000.pth.tar`

다운로드 방법:
- Google Drive / Dropbox 등에 업로드 후 공유
- 또는 직접 학습 (`python train_fastpitch.py`)
[extra_data](https://drive.google.com/file/d/1FMxOzDG-JYN89ROYc5almIs3RdMeVHfz/view?usp=drive_link)
[data](https://drive.google.com/file/d/1uctxn8QUGNccSncWUEL0iBPxXeBrMhWm/view?usp=drive_link)
### 2. VocGAN Vocoder (104MB)
**경로**: `vocoder/pretrained_models/vocgan_kss_pretrained_model_epoch_4500.pt`

다운로드 방법:
- Google Drive / Dropbox 등에 업로드 후 공유
- 또는 VocGAN 공식 저장소에서 다운로드

### 3. 전처리 데이터
**경로**: `preprocessed/kss/`
- `mel_stat.npy`
- `f0_stat.npy`
- `energy_stat.npy`

다운로드 방법:
- Google Drive / Dropbox 등에 업로드 후 공유
- 또는 직접 전처리 (`python preprocess.py`)

## 다운로드 후 설치

```bash
# 1. 모델 파일 다운로드 (위 링크에서)

# 2. 폴더 생성
mkdir -p ckpt/archive/data/kss
mkdir -p vocoder/pretrained_models
mkdir -p preprocessed/kss

# 3. 파일 배치
# 다운로드한 파일을 해당 경로에 복사

# 4. 확인
ls -lh ckpt/archive/data/kss/
ls -lh vocoder/pretrained_models/
ls -lh preprocessed/kss/
```

## 데이터셋 (선택사항)

**KSS Dataset** (2.0GB) - 학습/전처리에만 필요
- 추론에는 불필요
- 다운로드: https://www.kaggle.com/datasets/bryanpark/korean-single-speaker-speech-dataset

```bash
# dataset/kss/ 에 압축 해제
dataset/kss/
├── transcript.v.1.4.txt
└── wavs/
    ├── 1_0000.wav
    ├── 1_0001.wav
    └── ...
```

## 자동 다운로드 스크립트 (예정)

향후 자동 다운로드 스크립트를 제공할 예정입니다.

---

**참고**:
- 모델 파일 없이는 음성 합성이 불가능합니다
- Jetson에서 실행하려면 위 3개 파일만 있으면 됩니다
- 학습/전처리는 PC에서 수행하고, 결과 파일만 Jetson으로 전송하세요
