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


class UserService:
    @staticmethod
    def create_user(user_id: int):
        db = get_db()
        response = db.table("user_progress").insert({"user_id": user_id, "questions_right": []}).execute()
        return response.data[0] if response.data else None

    @staticmethod
    def get_user_progress(user_id: int):
        db = get_db()
        response = db.table("user_progress").select("*").eq("user_id", user_id).execute()
        return response.data[0] if response.data else None

    @staticmethod
    def update_questions_right(user_id: int, question_ids: list[int]):
        db = get_db()
        response = db.table("user_progress").update({"questions_right": question_ids}).eq("user_id", user_id).execute()
        return response.data[0] if response.data else None


class EventService:
    @staticmethod
    def get_all_events():
        db = get_db()
        response = db.table("byu_events").select("*").execute()
        return response.data

    @staticmethod
    def get_conversation_by_event(event_id: str):
        db = get_db()

        # Get conversation for the event
        conversation_response = db.table("conversations").select("*").eq("event_id", event_id).execute()

        if not conversation_response.data:
            return None

        conversation = conversation_response.data[0]

        # Get messages for the conversation
        messages_response = (
            db.table("messages")
            .select("*")
            .eq("conversation_id", conversation["conversation_id"])
            .order("created_at")
            .execute()
        )

        return {
            "conversation": conversation,
            "messages": messages_response.data
        }
