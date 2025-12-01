import os
import requests
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    print("ERROR: GEMINI_API_KEY not found in environment.")
    exit(1)

print(f"Using API Key: {api_key[:4]}...{api_key[-4:]}")

# 1. Check Tuned Models
print("\n--- Checking Tuned Models ---")
genai.configure(api_key=api_key)
try:
    tuned_models = list(genai.list_tuned_models())
    if not tuned_models:
        print("No tuned models found.")
    else:
        for m in tuned_models:
            print(f"Tuned Model: {m.name}")
except Exception as e:
    print(f"Error listing tuned models: {e}")

# 2. Direct REST Call to the specific model
target_model = "models/imagen-4.0-fast-generate-001"
print(f"\n--- Testing Direct REST Call to {target_model} ---")

url = f"https://generativelanguage.googleapis.com/v1beta/{target_model}:predict?key={api_key}"
payload = {
    "instances": [{"prompt": "Test image"}],
    "parameters": {"sampleCount": 1}
}

try:
    response = requests.post(url, json=payload)
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        print("SUCCESS: Model is accessible!")
    else:
        print("FAILURE: API Error Response:")
        print(response.text)
except Exception as e:
    print(f"Request failed: {e}")
