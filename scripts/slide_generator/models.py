from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class TextElement(BaseModel):
    type: str
    content: Any  # Can be string or list of strings

class Slide(BaseModel):
    id: int
    section: str
    title: str
    text_elements: List[TextElement] = Field(default_factory=list)
    visual_direction: str
    notes: Optional[str] = None

class SlideDeckMetadata(BaseModel):
    presentation_title: str
    total_slides: int
    default_aspect_ratio: str

class SlideDeck(BaseModel):
    metadata: SlideDeckMetadata
    slides: List[Slide]

class Style(BaseModel):
    name: str
    description: str
    content: str  # The full markdown content for this style
