import json
import re

with open('../data/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Extract const appData
start_idx = content.find('const appData = ') + len('const appData = ')
bracket_count = 0
json_str = ''
for i in range(start_idx, len(content)):
    char = content[i]
    if char == '{':
        bracket_count += 1
    elif char == '}':
        bracket_count -= 1
        if bracket_count == 0:
            json_str = content[start_idx:i+1]
            break

data = json.loads(json_str)
theory = data.get('theory', [])
questions = data.get('questions', [])

print(f"Theory count: {len(theory)}")
print(f"Questions count: {len(questions)}")

# Print unique lessons in questions
q_lessons = set(q.get('lesson_name') for q in questions)
print("Unique lesson_names in questions:", sorted(list(q_lessons)))

# Print first few theory titles
print("Theory titles:")
for i, t in enumerate(theory[:10]):
    print(f"  {i+1}. {t.get('title')} -> {t.get('url')}")

# Print all questions and check weight and other properties
print("\n--- All Questions ---")
for i, q in enumerate(questions):
    print(f"Index: {i+1}, ID: {q.get('id')}, Weight: {q.get('weight')}, Correct: {q.get('correct_option')}, Image: {q.get('image_path')}")
    print(f"Text: {q.get('question_text')[:100]}...")
    print(f"Explanation: {q.get('explanation_text')[:100]}...")
    print("-" * 40)

