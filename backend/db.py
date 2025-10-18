from supabase import create_client, Client
import os
from dotenv import load_dotenv

load_dotenv()


class Database:
    _instance: Client = None

    @classmethod
    def get_client(cls) -> Client:
        if cls._instance is None:
            url = os.getenv("SUPABASE_URL")
            key = os.getenv("SUPABASE_KEY")
            cls._instance = create_client(url, key)
        return cls._instance


def get_db() -> Client:
    return Database.get_client()
