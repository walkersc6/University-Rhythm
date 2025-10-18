# API Example Requests

All examples use `localhost:8642` and ID `1` as defaults.

## Hello World

```bash
curl http://localhost:8642/
```

## Get All Modules

```bash
curl http://localhost:8642/modules
```

## Get Lessons for Module 1

```bash
curl http://localhost:8642/modules/1/lessons
```

## Get Questions for Lesson 1

```bash
curl http://localhost:8642/lessons/1/questions
```
