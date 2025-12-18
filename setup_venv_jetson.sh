#!/bin/bash
# FastPitch Korean TTS - Jetson Orin Nano 가상환경 설치
# JetPack 6.1 기준

set -e

echo "=========================================="
echo "FastPitch Korean TTS"
echo "Jetson Orin Nano 가상환경 설치"
echo "=========================================="
echo ""

# 색상
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. JetPack 확인
echo -e "${YELLOW}[1/7] JetPack 버전 확인...${NC}"
if [ -f /etc/nv_tegra_release ]; then
    L4T_VERSION=$(cat /etc/nv_tegra_release | grep -oP 'R\K[0-9]+')
    if [ "$L4T_VERSION" = "36" ]; then
        echo -e "${GREEN}✓ JetPack 6.x 확인됨${NC}"
    else
        echo -e "${YELLOW}경고: JetPack 6.x 권장 (현재: R${L4T_VERSION})${NC}"
    fi
else
    echo -e "${YELLOW}경고: Jetson 장치가 아닐 수 있습니다${NC}"
fi
echo ""

# 2. 시스템 패키지 설치
echo -e "${YELLOW}[2/7] 시스템 패키지 설치...${NC}"
sudo apt-get update -qq
sudo apt-get install -y -qq \
    build-essential cmake git pkg-config \
    libopenblas-dev libopenmpi-dev libomp-dev \
    ffmpeg libsndfile1 libsndfile1-dev \
    python3-pip python3-dev python3-venv \
    default-jdk \
    python3-tk \
    libjpeg-dev zlib1g-dev libpython3-dev \
    libavcodec-dev libavformat-dev libswscale-dev \
    cython3 \
    libssl-dev libffi-dev \
    portaudio19-dev > /dev/null 2>&1

echo -e "${GREEN}✓ 시스템 패키지 설치 완료${NC}"
echo ""

# 3. 가상환경 생성
echo -e "${YELLOW}[3/7] Python 가상환경 생성...${NC}"
if [ -d ".venv" ]; then
    echo -e "${YELLOW}기존 .venv 폴더가 존재합니다.${NC}"
    read -p "삭제하고 새로 만드시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf .venv
        python3 -m venv .venv
        echo -e "${GREEN}✓ 가상환경 재생성 완료${NC}"
    else
        echo -e "${GREEN}✓ 기존 가상환경 사용${NC}"
    fi
else
    python3 -m venv .venv
    echo -e "${GREEN}✓ 가상환경 생성 완료 (.venv)${NC}"
fi
echo ""

# 가상환경 활성화
source .venv/bin/activate

# 4. pip 업그레이드
echo -e "${YELLOW}[4/7] pip 업그레이드...${NC}"
pip install --upgrade pip -q
echo -e "${GREEN}✓ pip 업그레이드 완료${NC}"
echo ""

# 5. PyTorch 설치
echo -e "${YELLOW}[5/7] PyTorch 2.5.0 설치 (시간 소요)...${NC}"
if python -c "import torch" 2>/dev/null; then
    TORCH_VERSION=$(python -c "import torch; print(torch.__version__)")
    echo -e "${GREEN}✓ PyTorch 이미 설치됨: $TORCH_VERSION${NC}"
else
    echo "PyTorch 다운로드 및 설치 중..."
    pip install --no-cache \
        https://developer.download.nvidia.com/compute/redist/jp/v61/pytorch/torch-2.5.0a0+872d972e41.nv24.08.17622132-cp310-cp310-linux_aarch64.whl
    echo -e "${GREEN}✓ PyTorch 2.5.0 설치 완료${NC}"
fi
echo ""

# 6. torchvision (선택사항)
echo -e "${YELLOW}[6/7] torchvision 설치 (선택)...${NC}"
read -p "torchvision을 소스에서 빌드하시겠습니까? (약 10-15분 소요) (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if python -c "import torchvision" 2>/dev/null; then
        TV_VERSION=$(python -c "import torchvision; print(torchvision.__version__)")
        echo -e "${GREEN}✓ torchvision 이미 설치됨: $TV_VERSION${NC}"
    else
        cd ~
        if [ ! -d "torchvision" ]; then
            git clone --branch v0.20.0 https://github.com/pytorch/vision torchvision
        fi
        cd torchvision
        export BUILD_VERSION=0.20.0
        python setup.py install
        cd ~/$(basename $(dirname $(readlink -f $0)))
        rm -rf ~/torchvision
        echo -e "${GREEN}✓ torchvision 설치 완료${NC}"
    fi
else
    echo -e "${YELLOW}torchvision 설치 건너뜀${NC}"
fi
echo ""

# 7. Python 패키지 설치
echo -e "${YELLOW}[7/7] Python 패키지 설치...${NC}"
echo "필수 패키지 설치 중... (시간 소요 가능)"

# 기본 패키지부터 설치
pip install -q numpy scipy

# requirements_jetson.txt의 패키지 설치
pip install -r requirements_jetson.txt

echo -e "${GREEN}✓ Python 패키지 설치 완료${NC}"
echo ""

# 완료
echo "=========================================="
echo -e "${GREEN}가상환경 설치 완료!${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}가상환경 활성화:${NC}"
echo "  source .venv/bin/activate"
echo ""
echo -e "${YELLOW}실행 방법:${NC}"
echo "  python tts_gui.py"
echo ""
echo -e "${YELLOW}가상환경 비활성화:${NC}"
echo "  deactivate"
echo ""
echo -e "${YELLOW}성능 최적화 (선택):${NC}"
echo "  sudo nvpmodel -m 0 && sudo jetson_clocks"
echo ""

# 설치 확인
echo "=========================================="
echo "설치된 패키지 확인:"
echo "=========================================="
python << EOF
import sys
print(f"Python: {sys.version}")

try:
    import torch
    print(f"✓ PyTorch: {torch.__version__}")
    print(f"✓ CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"✓ CUDA device: {torch.cuda.get_device_name(0)}")
except:
    print("✗ PyTorch 설치 실패")

try:
    import librosa
    print(f"✓ librosa: {librosa.__version__}")
except:
    print("✗ librosa 설치 실패")

try:
    from g2pk import G2p
    from jamo import h2j
    print("✓ 한국어 라이브러리 설치됨")
except:
    print("✗ 한국어 라이브러리 설치 실패")

try:
    import pygame
    print(f"✓ pygame: {pygame.__version__}")
except:
    print("✗ pygame 설치 실패")
EOF

echo ""
echo "=========================================="
