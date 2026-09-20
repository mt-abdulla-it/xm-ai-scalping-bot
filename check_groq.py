import os
from groq import Groq

api_key = os.environ.get("GROQ_API_KEY", "YOUR_GROQ_API_KEY")
client = Groq(api_key=api_key)
models = client.models.list()
for m in models.data:
    print(m.id)
