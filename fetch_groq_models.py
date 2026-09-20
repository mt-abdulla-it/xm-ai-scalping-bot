import os
from groq import Groq

api_key = os.environ.get("GROQ_API_KEY", "YOUR_GROQ_API_KEY")
client = Groq(api_key=api_key)
models = client.models.list()
with open("groq_models.txt", "w") as f:
    for m in models.data:
        f.write(m.id + "\n")
