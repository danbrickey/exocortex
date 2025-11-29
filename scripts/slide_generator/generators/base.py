from abc import ABC, abstractmethod
from typing import Optional

class ImageGenerator(ABC):
    @abstractmethod
    def generate(self, prompt: str, output_path: str) -> Optional[str]:
        """
        Generates an image from the prompt and saves it to output_path.
        Returns the path to the saved image if successful, None otherwise.
        """
        pass
