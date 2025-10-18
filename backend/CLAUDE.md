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
| module_id | uuid | Foreign key to modules |
| is_video | bool | Whether this lesson is a video |
| lesson | text | Lesson content/URL |
| order_num | int4 | Order within module |
| created_at | timestamp | Creation timestamp |

### modules
Modules/courses table.

| Column | Type | Description |
|--------|------|-------------|
| module_id | uuid | Primary key |
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

## Environment Variables

- `PORT` - Server port (default: 8642)

## Running Locally

```bash
docker-compose up --build
```

API will be available at `http://localhost:8642/`
