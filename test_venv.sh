#!/bin/bash
# FastPitch Korean TTS - 가상환경 테스트 스크립트

echo "=========================================="
echo "가상환경 테스트"
echo "=========================================="
echo ""

if [ ! -d ".venv" ]; then
    echo "❌ .venv 폴더가 없습니다."
    echo "먼저 ./setup_venv_jetson.sh를 실행하세요."
    exit 1
fi

echo "✓ .venv 폴더 존재"
echo ""

# 가상환경 활성화
source .venv/bin/activate

echo "Python 환경 확인:"
echo "  Python 버전: $(python --version)"
echo "  Python 경로: $(which python)"
echo ""

echo "필수 패키지 테스트:"

# PyTorch
python -c "import torch; print(f'  ✓ PyTorch {torch.__version__}')" 2>/dev/null || echo "  ❌ PyTorch 설치 필요"

# 오디오
python -c "import librosa; print(f'  ✓ librosa {librosa.__version__}')" 2>/dev/null || echo "  ❌ librosa 설치 실패"
python -c "import soundfile; print(f'  ✓ soundfile {soundfile.__version__}')" 2>/dev/null || echo "  ❌ soundfile 설치 실패"
python -c "import pyworld; print('  ✓ pyworld 설치됨')" 2>/dev/null || echo "  ❌ pyworld 설치 실패"

# 한국어
python -c "from g2pk import G2p; print('  ✓ g2pK 설치됨')" 2>/dev/null || echo "  ❌ g2pK 설치 실패"
python -c "from jamo import h2j; print('  ✓ jamo 설치됨')" 2>/dev/null || echo "  ❌ jamo 설치 실패"
python -c "import konlpy; print('  ✓ konlpy 설치됨')" 2>/dev/null || echo "  ❌ konlpy 설치 실패"

# 딥러닝
python -c "import numpy; print(f'  ✓ numpy {numpy.__version__}')" 2>/dev/null || echo "  ❌ numpy 설치 실패"
python -c "import scipy; print(f'  ✓ scipy {scipy.__version__}')" 2>/dev/null || echo "  ❌ scipy 설치 실패"

# GUI
python -c "import pygame; print(f'  ✓ pygame {pygame.__version__}')" 2>/dev/null || echo "  ❌ pygame 설치 실패"

# 기타
python -c "import tgt; print('  ✓ tgt 설치됨')" 2>/dev/null || echo "  ❌ tgt 설치 실패"
python -c "import matplotlib; print(f'  ✓ matplotlib {matplotlib.__version__}')" 2>/dev/null || echo "  ❌ matplotlib 설치 실패"

echo ""
echo "=========================================="
echo "모듈 import 테스트:"
echo "=========================================="

python << 'EOF'
try:
    import hparams as hp
    print("✓ hparams.py import 성공")
except Exception as e:
    print(f"❌ hparams.py import 실패: {e}")

try:
    from fastspeech2 import FastSpeech2
    print("✓ fastspeech2.py import 성공")
except Exception as e:
    print(f"❌ fastspeech2.py import 실패: {e}")

try:
    from text import text_to_sequence
    print("✓ text 모듈 import 성공")
except Exception as e:
    print(f"❌ text 모듈 import 실패: {e}")

try:
    import utils
    print("✓ utils.py import 성공")
except Exception as e:
    print(f"❌ utils.py import 실패: {e}")
EOF

echo ""
echo "=========================================="
echo "테스트 완료!"
echo "=========================================="
