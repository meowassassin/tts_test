#!/bin/bash
# FastPitch Korean TTS - Jetson Orin Nano 간편 설치
# git clone 후 이 스크립트만 실행하면 모든 설정 완료

set -e

echo "=========================================="
echo "FastPitch Korean TTS - Jetson 설치"
echo "=========================================="
echo ""

# 색상
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. JetPack 확인
echo -e "${YELLOW}[1/5] JetPack 버전 확인...${NC}"
if [ -f /etc/nv_tegra_release ]; then
    L4T_VERSION=$(cat /etc/nv_tegra_release | grep -oP 'R\K[0-9]+')
    if [ "$L4T_VERSION" = "36" ]; then
        echo -e "${GREEN}✓ JetPack 6.x 확인됨${NC}"
    else
        echo "경고: JetPack 6.x 권장 (현재: R${L4T_VERSION})"
    fi
else
    echo "경고: Jetson 장치가 아닐 수 있습니다"
fi
echo ""

# 2. 시스템 패키지
echo -e "${YELLOW}[2/5] 시스템 패키지 설치...${NC}"
sudo apt-get update -qq
sudo apt-get install -y -qq \
    build-essential cmake git \
    libopenblas-dev libomp-dev \
    ffmpeg libsndfile1 \
    python3-pip python3-dev \
    default-jdk \
    python3-tk \
    cython3 > /dev/null 2>&1

echo -e "${GREEN}✓ 시스템 패키지 설치 완료${NC}"
echo ""

# 3. pip 업그레이드
echo -e "${YELLOW}[3/5] pip 업그레이드...${NC}"
pip3 install --upgrade pip -q
echo -e "${GREEN}✓ pip 업그레이드 완료${NC}"
echo ""

# 4. PyTorch 확인/설치
echo -e "${YELLOW}[4/5] PyTorch 확인...${NC}"
if python3 -c "import torch" 2>/dev/null; then
    TORCH_VERSION=$(python3 -c "import torch; print(torch.__version__)")
    echo -e "${GREEN}✓ PyTorch 이미 설치됨: $TORCH_VERSION${NC}"
else
    echo "PyTorch 설치 중... (시간 소요)"
    pip3 install --no-cache https://developer.download.nvidia.com/compute/redist/jp/v61/pytorch/torch-2.5.0a0+872d972e41.nv24.08.17622132-cp310-cp310-linux_aarch64.whl -q
    echo -e "${GREEN}✓ PyTorch 2.5.0 설치 완료${NC}"
fi
echo ""

# 5. Python 패키지
echo -e "${YELLOW}[5/5] Python 패키지 설치...${NC}"
pip3 install -q \
    librosa==0.10.2 soundfile==0.12.1 resampy==0.4.3 \
    jamo==0.4.1 g2pK==0.1.2 JPype1==1.5.0 konlpy==0.6.0 \
    numpy scipy scikit-learn matplotlib tqdm pyyaml \
    inflect unidecode tgt pygame==2.6.0 pyworld

echo -e "${GREEN}✓ Python 패키지 설치 완료${NC}"
echo ""

# 완료
echo "=========================================="
echo -e "${GREEN}설치 완료!${NC}"
echo "=========================================="
echo ""
echo "실행 방법:"
echo "  python3 tts_gui.py"
echo ""
echo "성능 최적화 (선택):"
echo "  sudo nvpmodel -m 0 && sudo jetson_clocks"
echo ""
