import os
import argparse
import sys
from typing import Optional
from dotenv import load_dotenv

from .models import Slide, SlideDeck, Style
from .loader import load_slides, load_style_guide
from .generators.gemini import GeminiGenerator

# Load environment variables
load_dotenv()

def construct_prompt(slide: Slide, style: Style, presentation_title: str) -> str:
    """
    Constructs the prompt for the image generator.
    Combines style guide, slide details, and visual direction.
    """
    
    # Extract text content for context
    text_content = []
    for element in slide.text_elements:
        if isinstance(element.content, list):
            text_content.append(f"{element.type}: {', '.join(element.content)}")
        else:
            text_content.append(f"{element.type}: {element.content}")
    
    text_context = "\n".join(text_content)

    prompt = f"""
You are an expert presentation designer and illustrator. 
Create a high-quality image for a presentation slide based on the following specifications.

PRESENTATION TITLE: {presentation_title}
SLIDE TITLE: {slide.title}

STYLE GUIDE:
{style.content}

SLIDE CONTEXT (Text on the slide):
{text_context}

VISUAL DIRECTION (Specific instructions for this image):
{slide.visual_direction}

INSTRUCTIONS:
- Strictly follow the "STYLE GUIDE" above.
- The image should visually represent the concepts in "VISUAL DIRECTION".
- Do not include any text in the image unless explicitly asked for in the visual direction (e.g. labels, diagrams).
- The aspect ratio should be 16:9.
- Make it look professional and consistent with the style.
"""
    return prompt.strip()

def main():
    parser = argparse.ArgumentParser(description="Generate slide images using AI.")
    parser.add_argument("--slides", required=True, help="Path to the slide descriptions YAML file.")
    parser.add_argument("--style-guide", required=True, help="Path to the style guide Markdown file.")
    parser.add_argument("--style", required=True, help="Name of the style to use (must match a header in the style guide).")
    parser.add_argument("--output", default="generated_images", help="Directory to save generated images.")
    parser.add_argument("--api-key", help="Gemini API Key (optional, can use GEMINI_API_KEY env var).")
    parser.add_argument("--generator", default="gemini", choices=["gemini", "mock"], help="Generator backend to use.")
    
    args = parser.parse_args()

    # Setup API Key (only needed for gemini)
    api_key = args.api_key or os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
    if args.generator == "gemini" and not api_key:
        print("Error: API Key not found. Please provide --api-key or set GEMINI_API_KEY/GOOGLE_API_KEY environment variable.")
        sys.exit(1)

    # Load Data
    print(f"Loading slides from {args.slides}...")
    try:
        slide_deck = load_slides(args.slides)
    except Exception as e:
        print(f"Error loading slides: {e}")
        sys.exit(1)

    print(f"Loading style guide from {args.style_guide}...")
    try:
        styles = load_style_guide(args.style_guide)
    except Exception as e:
        print(f"Error loading style guide: {e}")
        sys.exit(1)

    # Validate Style
    if args.style not in styles:
        print(f"Error: Style '{args.style}' not found in style guide.")
        print("Available styles:")
        for s in styles.keys():
            print(f" - {s}")
        sys.exit(1)
    
    selected_style = styles[args.style]
    print(f"Using style: {selected_style.name}")

    # Setup Generator
    if args.generator == "mock":
        from .generators.mock import MockGenerator
        generator = MockGenerator()
    else:
        generator = GeminiGenerator(api_key=api_key)

    # Create Output Directory
    output_dir = os.path.join(args.output, selected_style.name.replace(" ", "_").lower())
    os.makedirs(output_dir, exist_ok=True)

    # Generate Images
    print(f"Generating images for {len(slide_deck.slides)} slides...")
    
    for slide in slide_deck.slides:
        filename = f"slide_{slide.id:03d}.png"
        output_path = os.path.join(output_dir, filename)
        
        if os.path.exists(output_path):
            print(f"Skipping Slide {slide.id} (already exists at {output_path})")
            continue

        prompt = construct_prompt(slide, selected_style, slide_deck.metadata.presentation_title)
        
        print(f"Generating Slide {slide.id}: {slide.title}...")
        result = generator.generate(prompt, output_path)
        
        if result:
            print(f"Success: {result}")
        else:
            print(f"Failed to generate Slide {slide.id}")

    print("Done!")

if __name__ == "__main__":
    main()
