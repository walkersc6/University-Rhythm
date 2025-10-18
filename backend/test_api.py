import requests
import json

BASE_URL = "http://localhost:8642"


def print_request(method, endpoint, data=None):
    """Print formatted request information"""
    print("\n" + "=" * 80)
    print(f"REQUEST: {method} {endpoint}")
    if data:
        print(f"BODY: {json.dumps(data, indent=2)}")
    print("=" * 80)


def print_response(response):
    """Print formatted response information"""
    print(f"STATUS: {response.status_code}")
    try:
        print(f"RESPONSE:\n{json.dumps(response.json(), indent=2)}")
    except:
        print(f"RESPONSE: {response.text}")
    print("=" * 80 + "\n")


def test_hello():
    endpoint = "/"
    print_request("GET", endpoint)
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response)


def test_get_modules():
    endpoint = "/modules"
    print_request("GET", endpoint)
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response)


def test_get_lessons():
    endpoint = "/modules/1/lessons"
    print_request("GET", endpoint)
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response)


def test_get_questions():
    endpoint = "/lessons/1/questions"
    print_request("GET", endpoint)
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response)


def test_create_user():
    endpoint = "/users/1"
    print_request("POST", endpoint)
    response = requests.post(f"{BASE_URL}{endpoint}")
    print_response(response)


def test_get_user_progress():
    endpoint = "/users/1/progress"
    print_request("GET", endpoint)
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response)


def test_update_questions():
    endpoint = "/users/1/questions"
    data = {"question_ids": [1, 2, 3]}
    print_request("PUT", endpoint, data)
    response = requests.put(f"{BASE_URL}{endpoint}", json=data)
    print_response(response)


def test_get_events():
    endpoint = "/events"
    print_request("GET", endpoint)
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response)


def test_get_event_conversation():
    endpoint = "/events/event-123/conversation"
    print_request("GET", endpoint)
    response = requests.get(f"{BASE_URL}{endpoint}")
    print_response(response)


if __name__ == "__main__":
    print("\n🚀 Starting API Tests (READ-ONLY)...\n")

    try:
        test_hello()
        test_get_modules()
        test_get_lessons()
        test_get_questions()
        # test_create_user()  # Commented out - modifies database
        test_get_user_progress()
        # test_update_questions()  # Commented out - modifies database
        test_get_events()
        test_get_event_conversation()

        print("\n✅ All tests completed!\n")
    except requests.exceptions.ConnectionError:
        print("\n❌ Error: Could not connect to the API. Make sure the server is running on port 8642.\n")
    except Exception as e:
        print(f"\n❌ Error: {str(e)}\n")
