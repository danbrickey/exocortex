from typing import Optional
from PIL import Image, ImageDraw, ImageFont
from .base import ImageGenerator

class MockGenerator(ImageGenerator):
    def generate(self, prompt: str, output_path: str) -> Optional[str]:
        print(f"[MOCK] Generating image for prompt: {prompt[:30]}...")
        
        # Create a simple placeholder image
        img = Image.new('RGB', (1920, 1080), color = (73, 109, 137))
        d = ImageDraw.Draw(img)
        
        # Draw some text
        d.text((10,10), "MOCK IMAGE", fill=(255,255,0))
        d.text((10,50), f"Prompt: {prompt[:50]}...", fill=(255,255,255))
        
        try:
            img.save(output_path)
            return output_path
        except Exception as e:
            print(f"[MOCK] Error saving image: {e}")
            return None
