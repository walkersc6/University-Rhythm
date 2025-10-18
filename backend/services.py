from db import get_db


class ModuleService:
    @staticmethod
    def get_all_modules():
        db = get_db()
        response = db.table("modules").select("*").execute()
        return response.data

    @staticmethod
    def get_lessons_by_module(module_id: str):
        db = get_db()
        response = (
            db.table("lessons")
            .select("*")
            .eq("module_id", module_id)
            .order("order_num")
            .execute()
        )
        return response.data
