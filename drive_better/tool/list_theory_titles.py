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
theory = data.get('theory', [])

for idx, chap in enumerate(theory):
    print(f"{idx+1:02d}. {chap['title']} -> {chap.get('url')}")
