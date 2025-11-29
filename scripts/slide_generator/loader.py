import yaml
import re
from typing import List, Dict
from .models import SlideDeck, Style

def load_slides(yaml_path: str) -> SlideDeck:
    """Loads and parses the slide deck YAML file."""
    with open(yaml_path, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    return SlideDeck(**data)

def load_style_guide(md_path: str) -> Dict[str, Style]:
    """
    Parses the Markdown style guide and returns a dictionary of styles.
    Assumes styles are defined by H2 headers (## Style Name).
    """
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    styles = {}
    # Split by H2 headers
    # This regex looks for lines starting with ## followed by the style name
    sections = re.split(r'(^|\n)##\s+(.+)', content)
    
    # The first element is usually the file header/intro, skip it or store it as 'default' if needed.
    # sections[0] is intro
    # sections[1] is newline/empty
    # sections[2] is style name
    # sections[3] is style content
    # ... and so on
    
    # We start from index 1 because index 0 is the content before the first H2
    for i in range(1, len(sections), 3):
        if i + 2 >= len(sections):
            break
            
        style_name = sections[i+1].strip()
        style_content = sections[i+2].strip()
        
        # Extract the first paragraph or description if possible, 
        # but for now we'll just store the whole content.
        # We might want to parse out a specific "Style Description" if it exists,
        # but the prompt construction can handle the raw markdown.
        
        styles[style_name] = Style(
            name=style_name,
            description=style_content[:100] + "...", # Brief summary
            content=style_content
        )
        
    return styles
