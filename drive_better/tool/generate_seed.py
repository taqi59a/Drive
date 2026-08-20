import json
import re
import os
import shutil
import html

def slugify(text):
    text = text.lower().strip()
    text = re.sub(r'[^a-z0-9\s-]', '', text)
    text = re.sub(r'[\s-]+', '_', text)
    return text

def parse_options(raw_text, correct_opt):
    text_clean = html.unescape(raw_text)
    # Split by br tags
    segments = re.split(r'<br\s*/?>', text_clean, flags=re.IGNORECASE)
    
    question_parts = []
    options = []
    
    for seg in segments:
        seg_strip = seg.strip()
        if not seg_strip:
            continue
        # Check if it starts with A., B., C., D. (case-insensitive)
        match = re.match(r'^([A-D])\.\s*(.*)', seg_strip, re.IGNORECASE)
        if match:
            opt_text = match.group(2).strip()
            # Clean HTML tags in option text
            opt_text = re.sub(r'<[^>]*>', ' ', opt_text)
            opt_text = re.sub(r'\s+', ' ', opt_text).strip()
            options.append({"text": opt_text})
        else:
            # Clean HTML tags
            seg_clean = re.sub(r'<[^>]*>', ' ', seg_strip)
            seg_clean = re.sub(r'\s+', ' ', seg_clean).strip()
            if seg_clean:
                question_parts.append(seg_clean)
                
    q_text = " ".join(question_parts)
    
    # Determine correct index
    correct_str = correct_opt.strip().lower()
    correct_idx = -1
    
    if options:
        if correct_str == 'a':
            correct_idx = 0
        elif correct_str == 'b':
            correct_idx = 1
        elif correct_str == 'c':
            correct_idx = 2
        elif correct_str == 'd':
            correct_idx = 3
        return q_text, options, correct_idx
        
    # If no options, check for Yes/No
    if correct_str in ['yes', 'no']:
        options = [{"text": "Yes"}, {"text": "No"}]
        correct_idx = 0 if correct_str == 'yes' else 1
        return q_text, options, correct_idx
        
    # Check for speed limit numbers
    if correct_str in ['70', '90']:
        options = [{"text": "50 km/h"}, {"text": "70 km/h"}, {"text": "90 km/h"}]
        correct_idx = 1 if correct_str == '70' else 2
        return q_text, options, correct_idx
        
    return q_text, [], -1

def format_html_content(html_content):
    import html
    # Unescape HTML
    text = html.unescape(html_content)
    
    # Convert headers to clean title format with spacing
    text = re.sub(r'<h[1-6][^>]*>(.*?)</h[1-6]>', r'\n\n=== \1 ===\n\n', text, flags=re.IGNORECASE)
    
    # Convert lists
    text = re.sub(r'<li[^>]*>(.*?)</li>', r'\n• \1', text, flags=re.IGNORECASE)
    text = re.sub(r'<ul[^>]*>|</ul>|<ol[^>]*>|</ol>', '', text, flags=re.IGNORECASE)
    
    # Convert paragraphs and divs to newlines
    text = re.sub(r'<p[^>]*>(.*?)</p>', r'\n\n\1\n', text, flags=re.IGNORECASE)
    text = re.sub(r'<div[^>]*>(.*?)</div>', r'\n\n\1\n', text, flags=re.IGNORECASE)
    
    # Convert line breaks
    text = re.sub(r'<br\s*/?>', r'\n', text, flags=re.IGNORECASE)
    
    # Remove remaining HTML tags
    text = re.sub(r'<[^>]*>', ' ', text)
    
    # Clean up excessive newlines
    text = re.sub(r'\n{3,}', '\n\n', text)
    
    return text.strip()

def main():
    # Load index.html
    html_path = '../data/index.html'
    if not os.path.exists(html_path):
        print("Error: index.html not found.")
        return
        
    with open(html_path, 'r', encoding='utf-8') as f:
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
    raw_theory = data.get('theory', [])
    raw_questions = data.get('questions', [])
    
    print(f"Loaded {len(raw_theory)} theory items and {len(raw_questions)} questions.")
    
    # 1. Map theory to Topics
    topics = []
    topic_map = {} # Maps chapter slug to theory data
    
    # We can assign icons and colors based on index or title
    icons = ['info', 'car_repair', 'directions', 'rule', 'warning', 'construction', 'eco', 'local_hospital']
    colors = ['#3b82f6', '#10b981', '#ef4444', '#f5a623', '#8b5cf6', '#ec4899', '#14b8a6', '#f43f5e']
    
    for idx, chap in enumerate(raw_theory):
        title = chap['title']
        slug = slugify(title)
        
        # Ensure unique slug
        if slug in topic_map:
            slug = f"{slug}_{idx}"
            
        topic_map[slug] = {
            "title": title,
            "content_html": chap.get('content_html', ''),
            "content_text": chap.get('content_text', '')
        }
        
        icon = icons[idx % len(icons)]
        # Map specific titles to specific icons for nicer UX
        title_lower = title.lower()
        if 'sign' in title_lower:
            icon = 'sign_post'
        elif 'speed' in title_lower or 'distance' in title_lower:
            icon = 'warning'
        elif 'vehicle' in title_lower or 'technique' in title_lower:
            icon = 'car_repair'
        elif 'accident' in title_lower:
            icon = 'local_hospital'
        elif 'energy' in title_lower:
            icon = 'eco'
            
        topics.append({
            "id": slug,
            "title": title,
            "description": f"Learn about {title.lower()}.",
            "order": idx + 1,
            "questionCount": 0,
            "iconName": icon,
            "colorHex": colors[idx % len(colors)],
            "content": format_html_content(chap.get('content_html', ''))
        })
        
    # 2. Map questions and associate with topics
    questions = []
    
    # Serious mistake keywords/IDs
    serious_ids = {
        '7572', # Speed consequences
        '7565', # Flanders speed limit
        '7567', # Walloon central lane speed limit
        '7566', # Wallonia speed limit
        '17907', # Stopping on motorway
        '7568', # Mobile phone while driving
        '7578', # Provisional licence Fri night
        '7579', # Provisional licence Jan 2
        '7580', # Provisional licence Sun night
        '20412', # Middle road driving
        '20147', # Rears up horse
    }
    
# Build theory slugs list for indexing
    theory_slugs = []
    for idx, chap in enumerate(raw_theory):
        title = chap['title']
        slug = slugify(title)
        # Ensure unique slug
        unique_slug = slug
        if unique_slug in theory_slugs:
            unique_slug = f"{unique_slug}_{idx}"
        theory_slugs.append(unique_slug)

    for idx, q in enumerate(raw_questions):
        q_id = f"q_{q['id']}_{idx}" # Guarantee uniqueness
        raw_text = q.get('question_raw', '')
        correct_opt = q.get('correct_option', '')
        
        q_text, options, correct_idx = parse_options(raw_text, correct_opt)
        
        # If parsing failed or options empty, print warning
        if not options or correct_idx == -1:
            print(f"Warning: Failed to parse options for question ID {q.get('id')}: {raw_text}")
            
        explanation = html.unescape(q.get('explanation_text', ''))
        explanation = re.sub(r'<[^>]*>', ' ', explanation)
        explanation = re.sub(r'\s+', ' ', explanation).strip()
        
        # Map lesson_name to topic
        lesson_name = q.get('lesson_name', '')
        topic_id = 'the_road_or_carriageway' # Default fallback
        
        if lesson_name.startswith('booklesson'):
            try:
                num = int(lesson_name.replace('booklesson', ''))
                # booklesson1 maps to theory chapter index 2, booklesson2 to index 3, etc.
                if 1 <= num <= len(theory_slugs) - 2:
                    topic_id = theory_slugs[num + 1]
            except ValueError:
                pass
        elif lesson_name == 'bookexam':
            q_text_lower = q_text.lower()
            if any(k in q_text_lower for k in ['speed', 'kph', 'km/h', 'limit']):
                topic_id = 'speed'
            elif any(k in q_text_lower for k in ['alcohol', 'drunk', 'drugs', 'breath', 'drinking']):
                topic_id = 'alcohol_drugs'
            elif any(k in q_text_lower for k in ['motorway', 'highway']):
                topic_id = 'the_motorway'
            elif any(k in q_text_lower for k in ['railway', 'level crossing', 'train', 'tram']):
                topic_id = 'train_tram_bus'
            elif any(k in q_text_lower for k in ['park', 'parking', 'waiting']):
                topic_id = 'waiting_and_parking_part_1'
            elif any(k in q_text_lower for k in ['bicyc', 'cycle', 'cyclist']):
                topic_id = 'the_bicycle_lane'
            elif any(k in q_text_lower for k in ['pedestrian', 'zebra', 'walker']):
                topic_id = 'the_pedestrians'
            elif any(k in q_text_lower for k in ['overtake', 'overtaking']):
                topic_id = 'overtaking_on_the_left'
            elif any(k in q_text_lower for k in ['light', 'headlight', 'horn', 'beam']):
                topic_id = 'the_lights_and_the_horn'
            elif any(k in q_text_lower for k in ['accident', 'first aid', 'injured', 'casualty']):
                topic_id = 'accidents_and_casualties'
            elif any(k in q_text_lower for k in ['eco', 'fuel', 'environment', 'emission', 'greenhouse']):
                topic_id = 'energy_use'
            elif any(k in q_text_lower for k in ['tire', 'brake', 'abs', 'esp', 'oil', 'fluid', 'tread']):
                topic_id = 'technique'
            elif any(k in q_text_lower for k in ['priority', 'yield', 'give way']):
                topic_id = 'priority_from_the_right'
            elif any(k in q_text_lower for k in ['roundabout', 'junction', 'crossroad']):
                topic_id = 'special_places'
            elif any(k in q_text_lower for k in ['sign', 'indicator']):
                topic_id = 'crossing_and_traffic_signs'
        
        # Let's count questions per topic
        for t in topics:
            if t['id'] == topic_id:
                t['questionCount'] += 1
                
        image_path = q.get('image_path')
        # Map image path to assets
        # e.g., "images/questions/7572.jpg" -> "assets/images/questions/7572.jpg"
        image_asset = None
        if image_path:
            image_asset = f"assets/{image_path}"
            
        is_serious = q.get('id') in serious_ids
        
        questions.append({
            "id": q_id,
            "topicId": topic_id,
            "text": q_text,
            "options": options,
            "correctIndex": correct_idx,
            "explanation": explanation,
            "imageAsset": image_asset,
            "isSerious": is_serious,
            "sourcePage": 0
        })
        
    # Write to target files
    os.makedirs('assets/seed', exist_ok=True)
    
    with open('assets/seed/topics.json', 'w', encoding='utf-8') as f:
        json.dump(topics, f, indent=2)
        
    with open('assets/seed/questions.json', 'w', encoding='utf-8') as f:
        json.dump(questions, f, indent=2)
        
    print("Seed files successfully generated in assets/seed/")
    
    # 3. Copy images to assets folder
    # data/images/questions -> assets/images/questions
    # data/images/theory -> assets/images/theory
    src_images_q = '../data/images/questions'
    dest_images_q = 'assets/images/questions'
    
    src_images_t = '../data/images/theory'
    dest_images_t = 'assets/images/theory'
    
    if os.path.exists(src_images_q):
        os.makedirs(dest_images_q, exist_ok=True)
        for item in os.listdir(src_images_q):
            shutil.copy2(os.path.join(src_images_q, item), os.path.join(dest_images_q, item))
        print(f"Copied question images to {dest_images_q}")
        
    if os.path.exists(src_images_t):
        os.makedirs(dest_images_t, exist_ok=True)
        for item in os.listdir(src_images_t):
            shutil.copy2(os.path.join(src_images_t, item), os.path.join(dest_images_t, item))
        print(f"Copied theory images to {dest_images_t}")

if __name__ == '__main__':
    main()
