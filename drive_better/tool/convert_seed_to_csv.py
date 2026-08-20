import json
import csv
import os

questions_json_path = r"d:\Developments\Drive Better\drive_better\assets\seed\questions.json"
csv_output_path = r"d:\Developments\Drive Better\drive_better_questions_sheet.csv"

topics_names = {
    'road_signs': 'Road Signs',
    'hazard_awareness': 'Hazard Awareness',
    'motorway_rules': 'Motorway Rules',
    'vehicle_safety': 'Vehicle Safety',
    'rules_of_road': 'Rules of the Road',
    'road_works': 'Road Works',
    'accidents': 'Accidents & First Aid',
    'environment': 'Environment & Eco'
}

def run():
    print(f"Reading from {questions_json_path}...")
    if not os.path.exists(questions_json_path):
        print(f"Error: {questions_json_path} does not exist.")
        return
        
    with open(questions_json_path, 'r', encoding='utf-8') as f:
        questions = json.load(f)
        
    print(f"Loaded {len(questions)} questions.")
    
    headers = [
        'question_id',
        'topic_id',
        'topic_name',
        'question_text',
        'option_a',
        'option_b',
        'option_c',
        'option_d',
        'correct_answer',
        'explanation',
        'difficulty',
        'source_page',
        'image_url',
        'is_serious'
    ]
    
    rows = []
    for q in questions:
        qid = q.get('id', '')
        tid = q.get('topicId', '')
        tname = topics_names.get(tid, 'General')
        qtext = q.get('text', '')
        
        opts = q.get('options', [])
        opt_a = opts[0].get('text', '') if len(opts) > 0 else ''
        opt_b = opts[1].get('text', '') if len(opts) > 1 else ''
        opt_c = opts[2].get('text', '') if len(opts) > 2 else ''
        opt_d = opts[3].get('text', '') if len(opts) > 3 else ''
        
        correct_idx = q.get('correctIndex', 0)
        correct_answer = ['A', 'B', 'C', 'D'][correct_idx] if correct_idx < len(opts) else 'A'
        
        explanation = q.get('explanation', '')
        difficulty = 'Medium'
        source_page = q.get('sourcePage', 0)
        image_url = q.get('imageAsset', '') or ''
        is_serious = str(q.get('isSerious', False)).lower()
        
        rows.append({
            'question_id': qid,
            'topic_id': tid,
            'topic_name': tname,
            'question_text': qtext,
            'option_a': opt_a,
            'option_b': opt_b,
            'option_c': opt_c,
            'option_d': opt_d,
            'correct_answer': correct_answer,
            'explanation': explanation,
            'difficulty': difficulty,
            'source_page': source_page,
            'image_url': image_url,
            'is_serious': is_serious
        })
        
    print(f"Writing {len(rows)} rows to {csv_output_path}...")
    with open(csv_output_path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)
        
    print("CSV conversion complete!")

if __name__ == '__main__':
    run()
