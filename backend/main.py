from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from services import ModuleService, QuestionService, UserService, EventService
from openai_service import OpenAIService


class UpdateQuestionsRequest(BaseModel):
    question_ids: list[int]


class MessageRequest(BaseModel):
    message: str
    model: str = "gpt-4o-mini"

app = FastAPI()


@app.get("/")
def hello_world():
    """Hello world endpoint."""
    return {"message": "Hello World"}


@app.get("/modules")
def get_modules():
    """
    Get all modules.

    Returns:
        JSON response with array of all modules
    """
    try:
        modules = ModuleService.get_all_modules()
        return {"modules": modules}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/modules/{module_id}/lessons")
def get_lessons(module_id: int):
    """
    Get all lessons for a specific module.

    Args:
        module_id: The ID of the module

    Returns:
        JSON response with array of lessons ordered by order_num
    """
    try:
        lessons = ModuleService.get_lessons_by_module(module_id)
        return {"lessons": lessons}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/lessons/{lesson_id}/questions")
def get_questions(lesson_id: int):
    """
    Get all questions for a specific lesson.

    Args:
        lesson_id: The ID of the lesson

    Returns:
        JSON response with array of questions (both multiple choice and true/false)
    """
    try:
        questions = QuestionService.get_questions_by_lesson(lesson_id)
        return {"questions": questions}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/users/{user_id}")
def create_user(user_id: int):
    """
    Create a new user.

    Args:
        user_id: The ID of the user to create

    Returns:
        JSON response with created user progress
    """
    try:
        user = UserService.create_user(user_id)
        if not user:
            raise HTTPException(status_code=500, detail="Failed to create user")
        return user
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/users/{user_id}/progress")
def get_user_progress(user_id: int):
    """
    Get user progress including questions answered correctly.

    Args:
        user_id: The ID of the user

    Returns:
        JSON response with user progress data
    """
    try:
        progress = UserService.get_user_progress(user_id)
        if not progress:
            raise HTTPException(status_code=404, detail="User not found")
        return progress
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.put("/users/{user_id}/questions")
def update_questions_right(user_id: int, request: UpdateQuestionsRequest):
    """
    Update the list of questions answered correctly by a user.

    Args:
        user_id: The ID of the user
        request: Request body with question_ids array

    Returns:
        JSON response with updated user progress
    """
    try:
        progress = UserService.update_questions_right(user_id, request.question_ids)
        if not progress:
            raise HTTPException(status_code=404, detail="User not found")
        return progress
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/events")
def get_events():
    """
    Get all BYU events.

    Returns:
        JSON response with array of all BYU events
    """
    try:
        events = EventService.get_all_events()
        return {"events": events}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/events/{event_id}/conversation")
def get_event_conversation(event_id: str):
    """
    Get conversation and messages for a specific event.

    Args:
        event_id: The ID of the event

    Returns:
        JSON response with conversation and messages
    """
    try:
        result = EventService.get_conversation_by_event(event_id)
        if not result:
            raise HTTPException(status_code=404, detail="Conversation not found for event")
        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/ai/message")
def send_ai_message(request: MessageRequest):
    """
    Send a message to OpenAI and get a response.

    Args:
        request: Request body with message and optional model

    Returns:
        JSON response with AI response
    """
    try:
        response = OpenAIService.send_message(request.message, request.model)
        return {"response": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
