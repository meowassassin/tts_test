import torch
import torch.nn as nn
import numpy as np
import hparams as hp
import os
import tkinter as tk
from tkinter import messagebox, scrolledtext
import re
from string import punctuation
import threading
import pygame

from fastspeech2 import FastSpeech2
from vocoder import vocgan_generator
from text import text_to_sequence
import utils
import audio as Audio

from g2pk import G2p
from jamo import h2j

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

class TTS_GUI:
    def __init__(self, root):
        self.root = root
        self.root.title("한국어 음성 합성 (FastPitch Korean TTS)")
        self.root.geometry("600x400")

        # 모델 로딩 상태
        self.model = None
        self.vocoder = None
        self.g2p = G2p()

        # pygame mixer 초기화 (음성 재생용)
        pygame.mixer.init(frequency=hp.sampling_rate)

        # UI 구성
        self.create_widgets()

        # 모델 로드 (백그라운드)
        self.load_models()

    def create_widgets(self):
        # 제목
        title_label = tk.Label(self.root, text="한국어 음성 합성", font=("Arial", 16, "bold"))
        title_label.pack(pady=10)

        # 상태 표시
        self.status_label = tk.Label(self.root, text="모델 로딩 중...", fg="blue")
        self.status_label.pack(pady=5)

        # 텍스트 입력 영역
        input_frame = tk.Frame(self.root)
        input_frame.pack(pady=10, padx=20, fill=tk.BOTH, expand=True)

        tk.Label(input_frame, text="합성할 문장을 입력하세요:").pack(anchor=tk.W)

        self.text_input = scrolledtext.ScrolledText(input_frame, height=8, width=60, font=("Arial", 11))
        self.text_input.pack(pady=5, fill=tk.BOTH, expand=True)
        self.text_input.insert(tk.END, "안녕하세요, 한국어 음성 합성 프로그램입니다.")

        # 버튼 영역
        button_frame = tk.Frame(self.root)
        button_frame.pack(pady=10)

        self.play_button = tk.Button(button_frame, text="음성 합성 및 재생",
                                      command=self.synthesize_and_play,
                                      bg="#4CAF50", fg="white",
                                      font=("Arial", 12, "bold"),
                                      padx=20, pady=10,
                                      state=tk.DISABLED)
        self.play_button.pack(side=tk.LEFT, padx=5)

        self.stop_button = tk.Button(button_frame, text="정지",
                                     command=self.stop_audio,
                                     bg="#f44336", fg="white",
                                     font=("Arial", 12, "bold"),
                                     padx=20, pady=10)
        self.stop_button.pack(side=tk.LEFT, padx=5)

        # 진행 상황 표시
        self.progress_label = tk.Label(self.root, text="", fg="green")
        self.progress_label.pack(pady=5)

    def load_models(self):
        """백그라운드에서 모델 로드"""
        def load():
            try:
                # FastSpeech2 모델 로드
                checkpoint_path = os.path.join(hp.checkpoint_path, "checkpoint_350000.pth.tar")
                self.model = nn.DataParallel(FastSpeech2())
                self.model.load_state_dict(torch.load(checkpoint_path, map_location='cpu', weights_only=False)['model'])
                self.model.requires_grad = False
                self.model.eval()
                self.model.to(device)

                # VocGAN vocoder 로드
                if hp.vocoder == 'vocgan':
                    self.vocoder = utils.get_vocgan(ckpt_path=hp.vocoder_pretrained_model_path)

                # UI 업데이트
                self.root.after(0, self.on_model_loaded)

            except Exception as e:
                error_msg = str(e)
                self.root.after(0, lambda: self.on_model_error(error_msg))

        thread = threading.Thread(target=load, daemon=True)
        thread.start()

    def on_model_loaded(self):
        """모델 로드 완료 시"""
        self.status_label.config(text="✓ 모델 로드 완료! 문장을 입력하고 '음성 합성 및 재생'을 클릭하세요.", fg="green")
        self.play_button.config(state=tk.NORMAL)

    def on_model_error(self, error_msg):
        """모델 로드 실패 시"""
        self.status_label.config(text=f"✗ 모델 로드 실패", fg="red")
        messagebox.showerror("오류", f"모델 로드 중 오류가 발생했습니다:\n{error_msg}")

    def kor_preprocess(self, text):
        """한국어 텍스트 전처리"""
        text = text.rstrip(punctuation)

        phone = self.g2p(text)
        phone = h2j(phone)
        phone = list(filter(lambda p: p != ' ', phone))
        phone = '{' + '}{'.join(phone) + '}'
        phone = re.sub(r'\{[^\w\s]?\}', '{sp}', phone)
        phone = phone.replace('}{', ' ')

        sequence = np.array(text_to_sequence(phone, hp.text_cleaners))
        sequence = np.stack([sequence])
        return torch.from_numpy(sequence).long().to(device)

    def synthesize_and_play(self):
        """음성 합성 및 재생"""
        if self.model is None:
            messagebox.showwarning("경고", "모델이 아직 로드되지 않았습니다.")
            return

        text = self.text_input.get("1.0", tk.END).strip()
        if not text:
            messagebox.showwarning("경고", "합성할 문장을 입력하세요.")
            return

        # 버튼 비활성화
        self.play_button.config(state=tk.DISABLED)
        self.progress_label.config(text="음성 합성 중...")

        # 백그라운드에서 합성
        def synthesize():
            try:
                # 전처리
                text_tensor = self.kor_preprocess(text)

                # 통계 로드
                mean_mel, std_mel = torch.tensor(np.load(os.path.join(hp.preprocessed_path, "mel_stat.npy")), dtype=torch.float).to(device)
                mean_f0, std_f0 = torch.tensor(np.load(os.path.join(hp.preprocessed_path, "f0_stat.npy")), dtype=torch.float).to(device)
                mean_energy, std_energy = torch.tensor(np.load(os.path.join(hp.preprocessed_path, "energy_stat.npy")), dtype=torch.float).to(device)

                mean_mel, std_mel = mean_mel.reshape(1, -1), std_mel.reshape(1, -1)
                mean_f0, std_f0 = mean_f0.reshape(1, -1), std_f0.reshape(1, -1)
                mean_energy, std_energy = mean_energy.reshape(1, -1), std_energy.reshape(1, -1)

                src_len = torch.from_numpy(np.array([text_tensor.shape[1]])).to(device)

                # 모델 추론
                mel, mel_postnet, log_duration_output, f0_output, energy_output, _, _, mel_len = self.model(text_tensor, src_len)

                mel_postnet_torch = mel_postnet.transpose(1, 2).detach()
                mel_postnet_torch = utils.de_norm(mel_postnet_torch.transpose(1, 2), mean_mel, std_mel).transpose(1, 2)

                # 임시 파일로 저장 (고유한 파일명 생성)
                import tempfile
                import time
                timestamp = int(time.time() * 1000)
                output_path = os.path.join(tempfile.gettempdir(), f'tts_output_{timestamp}.wav')

                # pygame이 이전 파일을 사용 중이면 먼저 정리
                try:
                    pygame.mixer.music.stop()
                    pygame.mixer.music.unload()
                except:
                    pass

                if self.vocoder is not None and hp.vocoder.lower() == "vocgan":
                    utils.vocgan_infer(mel_postnet_torch, self.vocoder, path=output_path)
                else:
                    Audio.tools.inv_mel_spec(mel_postnet_torch[0], output_path)

                # 파일 쓰기 완료 대기
                time.sleep(0.1)

                # 재생
                self.root.after(0, lambda p=output_path: self.play_audio(p))

            except Exception as e:
                error_msg = str(e)
                self.root.after(0, lambda: self.on_synthesis_error(error_msg))

        thread = threading.Thread(target=synthesize, daemon=True)
        thread.start()

    def play_audio(self, audio_path):
        """오디오 파일 재생"""
        try:
            pygame.mixer.music.load(audio_path)
            pygame.mixer.music.play()

            self.progress_label.config(text="✓ 재생 중...")
            self.play_button.config(state=tk.NORMAL)

            # 재생 완료 체크
            self.check_playback_finished()

        except Exception as e:
            self.on_synthesis_error(f"재생 오류: {str(e)}")

    def check_playback_finished(self):
        """재생 완료 체크"""
        if pygame.mixer.music.get_busy():
            self.root.after(100, self.check_playback_finished)
        else:
            self.progress_label.config(text="✓ 재생 완료")

    def stop_audio(self):
        """오디오 정지"""
        pygame.mixer.music.stop()
        self.progress_label.config(text="재생 정지")

    def on_synthesis_error(self, error_msg):
        """합성 오류 시"""
        self.progress_label.config(text="✗ 합성 실패", fg="red")
        self.play_button.config(state=tk.NORMAL)
        messagebox.showerror("오류", f"음성 합성 중 오류가 발생했습니다:\n{error_msg}")

def main():
    root = tk.Tk()
    app = TTS_GUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()
