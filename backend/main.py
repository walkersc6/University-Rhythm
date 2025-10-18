from fastapi import FastAPI, HTTPException
from services import ModuleService

app = FastAPI()


@app.get("/")
def hello_world():
    return {"message": "Hello World"}


@app.get("/modules")
def get_modules():
    try:
        modules = ModuleService.get_all_modules()
        return {"modules": modules}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/modules/{module_id}/lessons")
def get_lessons(module_id: str):
    try:
        lessons = ModuleService.get_lessons_by_module(module_id)
        return {"lessons": lessons}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
