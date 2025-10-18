# Backend Documentation

## Database Schema (Supabase)

### mc_questions
Multiple choice questions table.

| Column | Type | Description |
|--------|------|-------------|
| question_id | uuid | Primary key |
| lesson_id | uuid | Foreign key to lessons |
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
| question_id | uuid | Primary key |
| lesson_id | uuid | Foreign key to lessons |
| question_text | text | The question text |
| true_option | text | True option text |
| false_option | text | False option text |
| answer | bool | Correct answer (true/false) |
| created_at | timestamp | Creation timestamp |

### lessons
Lessons table.

| Column | Type | Description |
|--------|------|-------------|
| lesson_id | uuid | Primary key |
| module_id | int | Foreign key to modules |
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
| user_id | uuid | Primary key |
| questions_right | _uuid | Array of correctly answered question IDs |
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
Get all modules.

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
    }
  ]
}
```

#### GET /modules/{module_id}/lessons
Get all lessons for a specific module (ordered by order_num).

**Parameters:**
- `module_id` (int) - The module ID

**Response:**
```json
{
  "lessons": [
    {
      "lesson_id": "uuid",
      "module_id": 1,
      "is_video": true,
      "lesson": "https://video-url.com",
      "order_num": 1,
      "created_at": "2025-01-01T00:00:00"
    }
  ]
}
```

## Environment Variables

- `PORT` - Server port (default: 8642)
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_KEY` - Supabase anon/public key

## Running Locally

```bash
docker-compose up --build
```

API will be available at `http://localhost:8642/`
