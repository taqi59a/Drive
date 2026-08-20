import json

with open('../data/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

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
questions = data.get('questions', [])

for i, q in enumerate(questions):
    print(f"Index: {i+1}")
    print(f"Raw: {repr(q.get('question_raw'))}")
    print(f"Correct Option: {repr(q.get('correct_option'))}")
    print("-" * 50)
