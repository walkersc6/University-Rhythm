from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()


class OpenAIService:
    _client = None
    _system_context = None

    @classmethod
    def get_client(cls):
        if cls._client is None:
            api_key = os.getenv("OPEN_AI_API_KEY")
            cls._client = OpenAI(api_key=api_key)
        return cls._client

    @classmethod
    def get_system_context(cls):
        if cls._system_context is None:
            context_path = os.path.join(os.path.dirname(__file__), "context.md")
            with open(context_path, "r") as f:
                cls._system_context = f.read()
        return cls._system_context

    @staticmethod
    def send_message(message: str, model: str = "gpt-4o-mini"):
        client = OpenAIService.get_client()
        system_context = OpenAIService.get_system_context()

        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_context},
                {"role": "user", "content": message}
            ]
        )
        return response.choices[0].message.content
