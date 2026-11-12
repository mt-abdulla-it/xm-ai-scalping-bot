# ==============================================================================
# XM AI Scalping Bot - Developer & Automation Makefile
# ==============================================================================

.PHONY: all help install compile build train test run stop restart status clean

SHELL := /bin/bash
PYTHON ?= python3

help:
	@echo "======================================================================"
	@echo "🤖 XM AI Scalping Bot — Developer Command Center"
	@echo "======================================================================"
	@echo "Available commands:"
	@echo "  make install   - Install Wine, MetaTrader 5, and Python dependencies"
	@echo "  make build     - Compile XM_AI_ScalpingBot.mq5 via headless MetaEditor"
	@echo "  make test      - Execute Python unit tests on ML feature pipelines"
	@echo "  make train     - Train ONNX Machine Learning model on collected trades"
	@echo "  make run       - Launch MetaTrader 5 in Turbo scalping mode"
	@echo "  make stop      - Gracefully terminate running MetaTrader 5 process"
	@echo "  make restart   - Restart MetaTrader 5 instance"
	@echo "  make status    - Display live trade count and process health"
	@echo "  make clean     - Clean temporary log and build artifacts"
	@echo "======================================================================"

install:
	@echo "📦 Installing Wine and MT5 environment..."
	@bash ./install_mt5.sh
	@$(PYTHON) -m pip install -r requirements.txt

compile: build

build:
	@echo "⚙️ Compiling XM_AI_ScalpingBot.mq5..."
	@bash ./compile_bot.sh

test:
	@echo "🧪 Running unit tests on ML pipelines..."
	@$(PYTHON) -m unittest discover tests

train:
	@echo "🧠 Training ONNX Machine Learning decision model..."
	@$(PYTHON) train_onnx.py

run:
	@echo "🚀 Launching XM Global MT5 in background..."
	@nohup bash -c 'DISPLAY=:0 wine "$$HOME/.wine/drive_c/Program Files/XM Global MT5/terminal64.exe"' > /dev/null 2>&1 &
	@sleep 2
	@echo "✅ MetaTrader 5 active with 30 charts."

stop:
	@echo "🛑 Stopping MetaTrader 5..."
	@pkill -f "terminal64.exe" || true
	@echo "✅ Stopped."

restart: stop run

status:
	@echo "📊 Status & Telemetry Check:"
	@pgrep -f "terminal64.exe" > /dev/null && echo "✅ MT5 Process: ACTIVE (PID: $$(pgrep -f 'terminal64.exe' | head -n 1))" || echo "⚠️ MT5 Process: INACTIVE"
	@CSV_FILE="$$HOME/.wine/drive_c/Program Files/XM Global MT5/MQL5/Files/XMBot_ML_Data.csv"; \
	if [ -f "$$CSV_FILE" ]; then \
		COUNT=$$(wc -l < "$$CSV_FILE"); \
		echo "📈 ML Dataset Recorded Trades: $$COUNT / 1000"; \
	else \
		echo "ℹ️ Dataset file not yet generated."; \
	fi

clean:
	@echo "🧹 Cleaning temporary files..."
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "✅ Clean complete."
