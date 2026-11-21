"""
Configuration and Environment Settings for the AI Engine.
Manages API keys, model endpoints, rate limits, and security policies.
"""
import os
import json
from pathlib import Path
from typing import Dict, Any, Optional

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

# Database path
DB_PATH = DATA_DIR / "ai_platform.db"

# API Keys (Loaded from environment or local config)
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "")
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

# Ollama Local Configuration
OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")

# Model Definitions
MODELS: Dict[str, Dict[str, Any]] = {
    "gemini-2.0-flash": {
        "name": "Google Gemini 2.0 Flash",
        "provider": "google",
        "model_id": "gemini-2.0-flash",
        "context_window": 1048576,
        "category": "multimodal_fast",
        "strengths": ["tamil", "vision", "code", "ultra_fast", "massive_context"],
        "cost_per_m_in": 0.10,
        "cost_per_m_out": 0.40
    },
    "llama-3.3-70b-groq": {
        "name": "Meta Llama 3.3 70B (Groq LPU)",
        "provider": "groq",
        "model_id": "llama-3.3-70b-versatile",
        "context_window": 128000,
        "category": "realtime_speed",
        "strengths": ["sub_100ms_speed", "general_reasoning", "conversation"],
        "cost_per_m_in": 0.59,
        "cost_per_m_out": 0.79
    },
    "deepseek-r1": {
        "name": "DeepSeek-R1 (Reasoning Master)",
        "provider": "deepseek",
        "model_id": "deepseek-reasoner",
        "context_window": 128000,
        "category": "deep_reasoning",
        "strengths": ["complex_math", "quant_logic", "cybersecurity_audit", "code_architecture"],
        "cost_per_m_in": 0.55,
        "cost_per_m_out": 2.19
    },
    "qwen-2.5-coder-local": {
        "name": "Qwen 2.5 Coder 32B (Local Ollama)",
        "provider": "ollama",
        "model_id": "qwen2.5-coder:32b",
        "context_window": 128000,
        "category": "local_coding",
        "strengths": ["offline", "privacy", "secure_code_analysis"],
        "cost_per_m_in": 0.00,
        "cost_per_m_out": 0.00
    }
}

DEFAULT_PRIMARY_MODEL = "gemini-2.0-flash"
DEFAULT_FALLBACK_MODEL = "llama-3.3-70b-groq"
DEFAULT_LOCAL_MODEL = "qwen-2.5-coder-local"

# Security & Sandboxing Policies
MAX_PROMPT_CHARS = 100000
MAX_OUTPUT_TOKENS = 4096
RATE_LIMIT_RPM = 60
ENABLE_AUDIT_LOGGING = True
REQUIRE_APPROVAL_FOR_DESTRUCTIVE_OPS = True
