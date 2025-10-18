# Backend Documentation

## Database Schema (Supabase)

### mc_questions
Multiple choice questions table.

| Column | Type | Description |
|--------|------|-------------|
| question_id | int | Primary key |
| lesson_id | int | Foreign key to lessons |
| question_text | text | The question text |
| a | text | Option A |
| b | text | Option B |
| c | text | Option C |
| d | text | Option D |
| answer | text | Correct answer (a, b, c, or d) |
| created_at | timestamp | Creation timestamp |

### tf_questions
True/False questions table.

| Column | Type | Description |
|--------|------|-------------|
| question_id | int | Primary key |
| lesson_id | int | Foreign key to lessons |
| question_text | text | The question text |
| true_option | text | True option text |
| false_option | text | False option text |
| answer | bool | Correct answer (true/false) |
| created_at | timestamp | Creation timestamp |

### lessons
Lessons table.

| Column | Type | Description |
|--------|------|-------------|
| lesson_id | int | Primary key |
| module_id | int | Foreign key to modules |
| lesson_name | text | Name of the lesson |
| is_video | bool | Whether this lesson is a video |
| lesson | text | Lesson content/URL |
| order_num | int4 | Order within module |
| created_at | timestamp | Creation timestamp |

### modules
Modules/courses table.

| Column | Type | Description |
|--------|------|-------------|
| module_id | int | Primary key |
| module_name | text | Name of the module |
| time_start | timestamp | Module start time |
| time_end | timestamp | Module end time |
| created_at | timestamp | Creation timestamp |

### user_progress
User progress tracking table.

| Column | Type | Description |
|--------|------|-------------|
| user_id | int | Primary key |
| questions_right | _int | Array of correctly answered question IDs |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

## API

### Endpoints

#### GET /
Hello world endpoint.

**Response:**
```json
{
  "message": "Hello World"
}
```

#### GET /modules
Get all available modules.

**Example Request:**
```bash
curl http://localhost:8642/modules
```

**Response:**
```json
{
  "modules": [
    {
      "module_id": 1,
      "module_name": "Introduction to Programming",
      "time_start": "2025-01-01T00:00:00",
      "time_end": "2025-01-31T23:59:59",
      "created_at": "2025-01-01T00:00:00"
    },
    {
      "module_id": 2,
      "module_name": "Data Structures",
      "time_start": "2025-02-01T00:00:00",
      "time_end": "2025-02-28T23:59:59",
      "created_at": "2025-01-01T00:00:00"
    }
  ]
}
```

**Response Fields:**
- `module_id` (int) - Unique identifier for the module
- `module_name` (string) - Name of the module
- `time_start` (timestamp) - When the module starts
- `time_end` (timestamp) - When the module ends
- `created_at` (timestamp) - When the module was created

#### GET /modules/{module_id}/lessons
Get all lessons for a specific module (ordered by order_num).

**Parameters:**
- `module_id` (int, path) - The module ID

**Example Request:**
```bash
curl http://localhost:8642/modules/1/lessons
```

**Response:**
```json
{
  "lessons": [
    {
      "lesson_id": 1,
      "module_id": 1,
      "lesson_name": "Introduction to Variables",
      "is_video": true,
      "lesson": "https://video-url.com",
      "order_num": 1,
      "created_at": "2025-01-01T00:00:00"
    },
    {
      "lesson_id": 2,
      "module_id": 1,
      "lesson_name": "Data Types",
      "is_video": false,
      "lesson": "Text content of the lesson...",
      "order_num": 2,
      "created_at": "2025-01-01T00:00:00"
    }
  ]
}
```

**Response Fields:**
- `lesson_id` (int) - Unique identifier for the lesson
- `module_id` (int) - ID of the parent module
- `lesson_name` (string) - Name of the lesson
- `is_video` (bool) - True if lesson is a video, false if text content
- `lesson` (string) - Video URL if is_video=true, otherwise text content
- `order_num` (int) - Sequential order within the module
- `created_at` (timestamp) - When the lesson was created

#### GET /lessons/{lesson_id}/questions
Get all questions (multiple choice and true/false) for a specific lesson.

**Parameters:**
- `lesson_id` (int, path) - The lesson ID

**Example Request:**
```bash
curl http://localhost:8642/lessons/1/questions
```

**Response:**
```json
{
  "questions": [
    {
      "type": "multiple_choice",
      "question_id": 1,
      "lesson_id": 1,
      "question_text": "What is the capital of France?",
      "a": "London",
      "b": "Paris",
      "c": "Berlin",
      "d": "Madrid",
      "answer": "b",
      "created_at": "2025-01-01T00:00:00"
    },
    {
      "type": "true_false",
      "question_id": 2,
      "lesson_id": 1,
      "question_text": "Python is a compiled language.",
      "true_option": "Python is compiled",
      "false_option": "Python is interpreted",
      "answer": false,
      "created_at": "2025-01-01T00:00:00"
    }
  ]
}
```

**Response Fields:**

All questions include:
- `type` (string) - Either "multiple_choice" or "true_false"
- `question_id` (int) - Unique identifier for the question
- `lesson_id` (int) - ID of the parent lesson
- `question_text` (string) - The question text
- `created_at` (timestamp) - When the question was created

Multiple choice questions also include:
- `a`, `b`, `c`, `d` (string) - The four answer options
- `answer` (string) - Correct answer ("a", "b", "c", or "d")

True/false questions also include:
- `true_option` (string) - Text for the true option
- `false_option` (string) - Text for the false option
- `answer` (bool) - Correct answer (true or false)

#### POST /users/{user_id}
Create a new user.

**Parameters:**
- `user_id` (int, path) - The ID of the user to create

**Example Request:**
```bash
curl -X POST http://localhost:8642/users/1
```

**Response:**
```json
{
  "user_id": 1,
  "questions_right": [],
  "created_at": "2025-01-01T00:00:00",
  "updated_at": "2025-01-01T00:00:00"
}
```

**Response Fields:**
- `user_id` (int) - Unique identifier for the user
- `questions_right` (array of int) - IDs of questions answered correctly
- `created_at` (timestamp) - When the user was created
- `updated_at` (timestamp) - Last update timestamp

#### GET /users/{user_id}/progress
Get user progress including questions answered correctly.

**Parameters:**
- `user_id` (int, path) - The ID of the user

**Example Request:**
```bash
curl http://localhost:8642/users/1/progress
```

**Response:**
```json
{
  "user_id": 1,
  "questions_right": [1, 2, 5],
  "created_at": "2025-01-01T00:00:00",
  "updated_at": "2025-01-01T12:30:00"
}
```

**Response Fields:**
- `user_id` (int) - Unique identifier for the user
- `questions_right` (array of int) - IDs of questions answered correctly
- `created_at` (timestamp) - When the user was created
- `updated_at` (timestamp) - Last update timestamp

#### PUT /users/{user_id}/questions
Update the list of questions answered correctly by a user.

**Parameters:**
- `user_id` (int, path) - The ID of the user

**Request Body:**
```json
{
  "question_ids": [1, 2, 3]
}
```

**Example Request:**
```bash
curl -X PUT http://localhost:8642/users/1/questions \
  -H "Content-Type: application/json" \
  -d '{"question_ids": [1, 2, 3]}'
```

**Response:**
```json
{
  "user_id": 1,
  "questions_right": [1, 2, 3],
  "created_at": "2025-01-01T00:00:00",
  "updated_at": "2025-01-01T13:45:00"
}
```

**Response Fields:**
- `user_id` (int) - Unique identifier for the user
- `questions_right` (array of int) - Updated IDs of questions answered correctly
- `created_at` (timestamp) - When the user was created
- `updated_at` (timestamp) - Last update timestamp

## Environment Variables

- `PORT` - Server port (default: 8642)
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_KEY` - Supabase anon/public key

## Running Locally

```bash
docker-compose up --build
```

API will be available at `http://localhost:8642/`
