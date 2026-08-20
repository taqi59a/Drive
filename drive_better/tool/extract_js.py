with open('../data/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the start of the script after appData definition
# appData is huge, so let's search for "function" or other JS keywords towards the end of the file
# Or search from the end of the file
script_start = content.find('<script>')
last_script_end = content.rfind('</script>')
js_part = content[script_start:last_script_end]

# Let's print lines that do not contain the huge appData definition
for line in js_part.split('\n'):
    if 'const appData =' not in line and len(line) < 500:
        print(line)
