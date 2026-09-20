import os
from google import genai

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "YOUR_GEMINI_API_KEY")

client = genai.Client(api_key=GEMINI_API_KEY)

print("Available models:")
for m in client.models.list():
    if "flash" in m.name.lower() or "pro" in m.name.lower():
        print(f"  {m.name}")
