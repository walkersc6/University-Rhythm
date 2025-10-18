from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()


class OpenAIService:
    _client = None

    @classmethod
    def get_client(cls):
        if cls._client is None:
            api_key = os.getenv("OPEN_AI_API_KEY")
            cls._client = OpenAI(api_key=api_key)
        return cls._client

    @staticmethod
    def send_message(message: str, model: str = "gpt-4o-mini"):
        client = OpenAIService.get_client()
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": message}]
        )
        return response.choices[0].message.content
