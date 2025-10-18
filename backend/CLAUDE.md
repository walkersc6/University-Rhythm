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

### byu_events
BYU events table.

| Column | Type | Description |
|--------|------|-------------|
| id | text | Primary key |
| category | text | Event category |
| title | text | Event title |
| description | text | Event description (optional) |
| date | date | Event date |
| start_time | time | Event start time |
| end_time | time | Event end time |
| location | text | Event location (optional) |
| all_day | bool | Whether event is all day (optional) |
| created_at | timestamptz | Creation timestamp (optional) |
| updated_at | timestamptz | Last update timestamp (optional) |

### conversations
Conversations table (one-to-one with byu_events).

| Column | Type | Description |
|--------|------|-------------|
| id | serial | Primary key |
| conversation_id | int | Unique conversation identifier (auto-generated) |
| event_id | text | Foreign key to byu_events (unique, on delete cascade) |
| created_at | timestamptz | Creation timestamp (default: NOW()) |
| updated_at | timestamptz | Last update timestamp (default: NOW()) |

**Notes:**
- Automatically created via trigger when a new event is inserted
- One conversation per event
- `conversation_id` is auto-generated using sequence

### messages
Messages table (one-to-many with conversations).

| Column | Type | Description |
|--------|------|-------------|
| message_id | serial | Primary key |
| conversation_id | int | Foreign key to conversations (on delete cascade) |
| sender_id | text | ID of message sender |
| message | text | Message content |
| created_at | timestamptz | Creation timestamp (default: NOW()) |
| updated_at | timestamptz | Last update timestamp (default: NOW()) |

**Notes:**
- Multiple messages per conversation
- Includes indexes on conversation_id, sender_id, and created_at for performance
- RLS policies allow public read, authenticated insert, users can update/delete own messages

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

#### GET /events
Get all BYU events.

**Example Request:**
```bash
curl http://localhost:8642/events
```

**Response:**
```json
{
  "events": [
    {
      "id": "event-123",
      "category": "Academic",
      "title": "Physics Seminar",
      "description": "Guest speaker on quantum mechanics",
      "date": "2025-01-15",
      "start_time": "14:00:00",
      "end_time": "15:30:00",
      "location": "ESC 100",
      "all_day": false,
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    },
    {
      "id": "event-124",
      "category": "Sports",
      "title": "Basketball Game",
      "description": null,
      "date": "2025-01-20",
      "start_time": "19:00:00",
      "end_time": "21:00:00",
      "location": "Marriott Center",
      "all_day": false,
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

**Response Fields:**
- `id` (string) - Unique identifier for the event
- `category` (string) - Event category
- `title` (string) - Event title
- `description` (string, nullable) - Event description
- `date` (date) - Event date
- `start_time` (time) - Event start time
- `end_time` (time) - Event end time
- `location` (string, nullable) - Event location
- `all_day` (bool, nullable) - Whether event is all day
- `created_at` (timestamptz, nullable) - Creation timestamp
- `updated_at` (timestamptz, nullable) - Last update timestamp

#### GET /events/{event_id}/conversation
Get conversation and messages for a specific event.

**Parameters:**
- `event_id` (string, path) - The ID of the event

**Example Request:**
```bash
curl http://localhost:8642/events/event-123/conversation
```

**Response:**
```json
{
  "conversation": {
    "id": 1,
    "conversation_id": 1,
    "event_id": "event-123",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z"
  },
  "messages": [
    {
      "message_id": 1,
      "conversation_id": 1,
      "sender_id": "user123",
      "message": "Looking forward to this event!",
      "created_at": "2025-01-01T10:00:00Z",
      "updated_at": "2025-01-01T10:00:00Z"
    },
    {
      "message_id": 2,
      "conversation_id": 1,
      "sender_id": "user456",
      "message": "Me too!",
      "created_at": "2025-01-01T10:05:00Z",
      "updated_at": "2025-01-01T10:05:00Z"
    }
  ]
}
```

**Response Fields:**

Conversation object:
- `id` (int) - Primary key
- `conversation_id` (int) - Unique conversation identifier
- `event_id` (string) - Event ID this conversation belongs to
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update timestamp

Messages array (ordered by created_at):
- `message_id` (int) - Primary key
- `conversation_id` (int) - Conversation this message belongs to
- `sender_id` (string) - ID of the message sender
- `message` (string) - Message content
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update timestamp

#### POST /ai/message
Send a message to OpenAI and get a response.

**Request Body:**
```json
{
  "message": "What is the capital of France?",
  "model": "gpt-4o-mini"
}
```

**Example Request:**
```bash
curl -X POST http://localhost:8642/ai/message \
  -H "Content-Type: application/json" \
  -d '{"message": "What is the capital of France?"}'
```

**Response:**
```json
{
  "response": "The capital of France is Paris."
}
```

**Request Fields:**
- `message` (string, required) - The message to send to OpenAI
- `model` (string, optional) - OpenAI model to use (default: "gpt-4o-mini")

**Response Fields:**
- `response` (string) - The AI-generated response

## Environment Variables

- `PORT` - Server port (default: 8642)
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_KEY` - Supabase anon/public key
- `OPENAI_API_KEY` - OpenAI API key

## Running Locally

```bash
docker-compose up --build
```

API will be available at `http://localhost:8642/`
