from fastapi import FastAPI, HTTPException
from services import ModuleService

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
