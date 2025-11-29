import os
import requests
import base64
import json
from typing import Optional
from .base import ImageGenerator

class GeminiGenerator(ImageGenerator):
    def __init__(self, api_key: str, model_name: str = "models/imagen-4.0-fast-generate-001"):
        self.api_key = api_key
        self.model_name = model_name
        self.base_url = "https://generativelanguage.googleapis.com/v1beta"

    def generate(self, prompt: str, output_path: str) -> Optional[str]:
        print(f"Generating image with {self.model_name}...")
        
        url = f"{self.base_url}/{self.model_name}:predict?key={self.api_key}"
        
        payload = {
            "instances": [
                {
                    "prompt": prompt
                }
            ],
            "parameters": {
                "sampleCount": 1,
                # "aspectRatio": "16:9" # Note: Check if supported by specific model version
            }
        }
        
        try:
            response = requests.post(url, json=payload)
            
            if response.status_code != 200:
                print(f"Error calling API: {response.status_code}")
                try:
                    error_data = response.json()
                    print(f"Details: {error_data.get('error', {}).get('message')}")
                    if "billed users" in error_data.get('error', {}).get('message', ''):
                        print("TIP: You may need to enable billing on your Google Cloud project to use Imagen.")
                except:
                    print(response.text)
                return None
                
            data = response.json()
            
            # Parse response - format depends on model version, but usually:
            # { "predictions": [ { "bytesBase64Encoded": "..." } ] }
            # or { "predictions": [ "base64string" ] }
            
            predictions = data.get("predictions")
            if not predictions:
                print("No predictions found in response.")
                return None
                
            # Handle different prediction formats
            image_data = None
            if isinstance(predictions[0], dict):
                if "bytesBase64Encoded" in predictions[0]:
                    image_data = predictions[0]["bytesBase64Encoded"]
                elif "mimeType" in predictions[0] and "bytesBase64Encoded" in predictions[0]: # Some versions
                    image_data = predictions[0]["bytesBase64Encoded"]
            elif isinstance(predictions[0], str):
                image_data = predictions[0]
                
            if not image_data:
                print(f"Could not extract image data from response: {predictions[0].keys() if isinstance(predictions[0], dict) else 'Unknown format'}")
                return None
                
            # Decode and save
            with open(output_path, "wb") as f:
                f.write(base64.b64decode(image_data))
                
            return output_path

        except Exception as e:
            print(f"Failed to generate image: {e}")
            return None
