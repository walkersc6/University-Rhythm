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

## Create User 1

```bash
curl -X POST http://localhost:8642/users/1
```

## Get User 1 Progress

```bash
curl http://localhost:8642/users/1/progress
```

## Update User 1 Questions Right

```bash
curl -X PUT http://localhost:8642/users/1/questions \
  -H "Content-Type: application/json" \
  -d '{"question_ids": [1, 2, 3]}'
```
