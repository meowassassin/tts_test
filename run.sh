#!/bin/bash
# FastPitch Korean TTS - 간편 실행 스크립트

if [ -d ".venv" ]; then
    # 가상환경이 있으면 활성화 후 실행
    echo "가상환경 활성화 중..."
    source .venv/bin/activate
    echo "TTS GUI 실행 중..."
    python tts_gui.py
else
    # 가상환경이 없으면 시스템 Python 사용
    echo "TTS GUI 실행 중... (시스템 Python)"
    python3 tts_gui.py
fi
