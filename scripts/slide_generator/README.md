# Slide Image Generator

This script generates images for presentation slides based on a YAML description file and a Markdown style guide. It uses the Google Gemini API (or a mock generator) to create the images.

## Setup

1.  **Install Dependencies**:
    ```bash
    pip install python-dotenv pydantic pyyaml google-generativeai pillow
    ```

2.  **API Key**:
    Set your Gemini API key in an environment variable `GEMINI_API_KEY` or pass it via `--api-key`.

## Usage

Run the script from the project root:

```bash
python -m scripts.slide_generator.main \
  --slides "path/to/slides.yml" \
  --style-guide "path/to/style-guide.md" \
  --style "Style Name" \
  --output "output_directory"
```

### Arguments

-   `--slides`: Path to the YAML file containing slide descriptions.
-   `--style-guide`: Path to the Markdown file containing style definitions.
-   `--style`: The name of the style to use (must match a generic H2 header in the style guide).
-   `--output`: Directory to save the generated images (default: `generated_images`).
-   `--api-key`: Your Google Gemini API key (optional if env var is set).
-   `--generator`: Backend to use: `gemini` (default) or `mock` (for testing).

## Example

```bash
python -m scripts.slide_generator.main \
  --slides "docs/meetings/presentations/prompt_engineering_patterns/slide-descriptions-2-0.yml" \
  --style-guide "ai-resources/prompts/workflows/slide_deck_workflow/slide-deck-style-guide.md" \
  --style "Whiteboard Sketch Style"
```
