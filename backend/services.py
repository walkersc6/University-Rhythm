from db import get_db


class ModuleService:
    @staticmethod
    def get_all_modules():
        db = get_db()
        response = db.table("modules").select("*").execute()
        return response.data

    @staticmethod
    def get_lessons_by_module(module_id: int):
        db = get_db()
        response = (
            db.table("lessons")
            .select("*")
            .eq("module_id", module_id)
            .order("order_num")
            .execute()
        )
        return response.data


class QuestionService:
    @staticmethod
    def get_questions_by_lesson(lesson_id: int):
        db = get_db()

        mc_response = db.table("mc_questions").select("*").eq("lesson_id", lesson_id).execute()
        tf_response = db.table("tf_questions").select("*").eq("lesson_id", lesson_id).execute()

        mc_questions = [{"type": "multiple_choice", **q} for q in mc_response.data]
        tf_questions = [{"type": "true_false", **q} for q in tf_response.data]

        return mc_questions + tf_questions
