import csv
import json
import os

csv_path = r"d:\Developments\Drive Better\drive_better_questions_sheet.csv"
questions_json_path = r"d:\Developments\Drive Better\drive_better\assets\seed\questions.json"
topics_json_path = r"d:\Developments\Drive Better\drive_better\assets\seed\topics.json"

topics_config = {
    'road_signs': {
        'title': 'Road Signs',
        'description': 'Warning, regulatory, and informational signs used on UK roads.',
        'order': 1,
        'iconName': 'sign_post',
        'colorHex': '#1B3A6B'
    },
    'hazard_awareness': {
        'title': 'Hazard Awareness',
        'description': 'Identify and respond to hazards including pedestrians, cyclists, and junctions.',
        'order': 2,
        'iconName': 'warning',
        'colorHex': '#F59E0B'
    },
    'motorway_rules': {
        'title': 'Motorway Rules',
        'description': 'Rules for UK motorways: lanes, speed, speed limits, and breakdowns.',
        'order': 3,
        'iconName': 'directions',
        'colorHex': '#2D5BB8'
    },
    'vehicle_safety': {
        'title': 'Vehicle Safety',
        'description': 'Vehicle checks, maintenance, tyres, brakes, and roadworthiness.',
        'order': 4,
        'iconName': 'car_repair',
        'colorHex': '#2EBD85'
    },
    'rules_of_road': {
        'title': 'Rules of the Road',
        'description': 'Right of way, speed limits, lane discipline, overtaking, and road markings.',
        'order': 5,
        'iconName': 'rule',
        'colorHex': '#7C3AED'
    },
    'road_works': {
        'title': 'Road Works',
        'description': 'Driving safely through motorway and street roadworks, temporary signs, and signals.',
        'order': 6,
        'iconName': 'construction',
        'colorHex': '#F5A623'
    },
    'accidents': {
        'title': 'Accidents & First Aid',
        'description': 'Legal obligations at accident scenes, emergency calls, and basic first-aid procedures.',
        'order': 7,
        'iconName': 'local_hospital',
        'colorHex': '#E5484D'
    },
    'environment': {
        'title': 'Environment & Eco',
        'description': 'Eco-driving techniques, fuel efficiency, emissions, and low-emission zones.',
        'order': 8,
        'iconName': 'eco',
        'colorHex': '#10B981'
    }
}

def convert():
    print(f"Reading CSV from {csv_path}...")
    
    questions = []
    topic_counts = {tid: 0 for tid in topics_config}
    
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            qid = row.get('question_id', '').strip()
            tid = row.get('topic_id', '').strip()
            qtext = row.get('question_text', '').strip()
            
            if not qid or not tid or not qtext:
                continue
                
            opt_a = row.get('option_a', '').strip()
            opt_b = row.get('option_b', '').strip()
            opt_c = row.get('option_c', '').strip()
            opt_d = row.get('option_d', '').strip()
            
            options = []
            if opt_a: options.append({"text": opt_a})
            if opt_b: options.append({"text": opt_b})
            if opt_c: options.append({"text": opt_c})
            if opt_d: options.append({"text": opt_d})
            
            correct_letter = row.get('correct_answer', '').strip().upper()
            if correct_letter in ['A', 'B', 'C', 'D']:
                correct_index = ['A', 'B', 'C', 'D'].index(correct_letter)
            else:
                correct_index = 0 # Default fallback
                
            explanation = row.get('explanation', '').strip()
            image_url = row.get('image_url', '').strip()
            image_asset = image_url if image_url else None
            
            try:
                source_page = int(row.get('source_page', '0').strip() or '0')
            except ValueError:
                source_page = 0
                
            questions.append({
                "id": qid,
                "topicId": tid,
                "text": qtext,
                "options": options,
                "correctIndex": correct_index,
                "explanation": explanation if explanation else None,
                "imageAsset": image_asset,
                "sourcePage": source_page
            })
            
            if tid in topic_counts:
                topic_counts[tid] += 1
            else:
                topic_counts[tid] = 1

    print(f"Parsed {len(questions)} questions.")

    # Write questions.json
    with open(questions_json_path, 'w', encoding='utf-8') as f:
        json.dump(questions, f, indent=2, ensure_ascii=False)
    print(f"Saved questions to {questions_json_path}")
    
    # Generate topics.json
    topics = []
    for tid, config in topics_config.items():
        topics.append({
            "id": tid,
            "title": config['title'],
            "description": config['description'],
            "order": config['order'],
            "questionCount": topic_counts.get(tid, 0),
            "iconName": config['iconName'],
            "colorHex": config['colorHex']
        })
        
    # Sort topics by order
    topics.sort(key=lambda t: t['order'])
    
    with open(topics_json_path, 'w', encoding='utf-8') as f:
        json.dump(topics, f, indent=2, ensure_ascii=False)
    print(f"Saved topics to {topics_json_path}")

if __name__ == "__main__":
    convert()
