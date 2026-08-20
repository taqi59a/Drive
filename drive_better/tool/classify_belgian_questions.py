import json
import re
import os

EXTRACTED_Q = r"d:\Developments\Drive Better\drive_better\tool\extracted_questions.json"
EXTRACTED_T = r"d:\Developments\Drive Better\drive_better\tool\extracted_topics.json"
SEED_Q = r"d:\Developments\Drive Better\drive_better\assets\seed\questions.json"
SEED_T = r"d:\Developments\Drive Better\drive_better\assets\seed\topics.json"

def classify():
    if not os.path.exists(EXTRACTED_Q):
        print(f"Error: {EXTRACTED_Q} does not exist.")
        return

    if not os.path.exists(EXTRACTED_T):
        print(f"Error: {EXTRACTED_T} does not exist.")
        return

    print("Reading extracted questions and topics...")
    with open(EXTRACTED_Q, 'r', encoding='utf-8') as f:
        questions = json.load(f)
        
    with open(EXTRACTED_T, 'r', encoding='utf-8') as f:
        topics = json.load(f)
        
    serious_keywords = [
        r"\bred\s+light\b",                 # Running red light
        r"\bcontinuous\s+(?:white\s+)?line\b", # Crossing continuous line
        r"\bsolid\s+(?:white\s+)?line\b",   # Crossing solid line
        r"\balcohol\b",                     # DUI
        r"\bblood\s+alcohol\b",             # DUI
        r"\bdrunk\b",                       # DUI
        r"\bdrugs\b",                       # DUI
        r"\bsign\s+'?STOP'?\b",             # Ignoring STOP sign
        r"\boctagonal\s+(?:red\s+)?sign\b",  # STOP sign
        r"\bwrong\s+direction\b",           # Motorway wrong way
        r"\bwrong\s+way\b",                 # Motorway wrong way
        r"\bopposite\s+direction\b",        # Motorway wrong way
        r"\bu-turn\b",                      # U-turn on motorway or prohibited area
        r"\bghost\s+driver\b",              # Wrong way
        r"\bmobile\s+phone\b",              # Handheld phone
        r"\bphone\b",                       # Phone
        r"\bhandheld\b",                    # Handheld phone
        r"\bpolice\s+officer\b",            # Police order
        r"\bofficer's\s+order\b",           # Police order
        r"\bofficer's\s+signal\b",          # Police order
        r"\blevel\s+crossing\b",            # Level crossing
        r"\brailway\s+crossing\b",          # Railway crossing
        r"\bhard\s+shoulder\b",             # Motorway hard shoulder
        r"\bpriority\s+to\s+the\s+right\b", # Priority to the right
        r"\bpriorité\s+de\s+droite\b",      # Priority to the right
        r"\bvoorrang\s+van\s+rechts\b",     # Priority to the right
        r"\btram\b",                        # Trams always have priority
        r"\byield\s+to\s+tram\b",           # Yield to tram
        r"\bpedestrian\s+crossing\b",       # Yield to pedestrian
        r"\byield\s+to\s+pedestrian\b",     # Yield to pedestrian
        r"\bovertaking\b",                  # Overtaking rules
        r"\bovertake\b"                     # Overtaking rules
    ]
    
    patterns = [re.compile(p, re.IGNORECASE) for p in serious_keywords]
    
    serious_count = 0
    minor_count = 0
    
    for q in questions:
        text = q.get('text', '')
        explanation = q.get('explanation', '') or ''
        
        is_serious = False
        for pattern in patterns:
            if pattern.search(text) or pattern.search(explanation):
                is_serious = True
                break
        
        q['isSerious'] = is_serious
        if is_serious:
            serious_count += 1
        else:
            minor_count += 1
            
    print(f"Classified {len(questions)} questions:")
    print(f"  Serious: {serious_count}")
    print(f"  Minor: {minor_count}")
    
    # Save topics with updated counts
    topic_counts = {}
    for q in questions:
        tid = q['topicId']
        topic_counts[tid] = topic_counts.get(tid, 0) + 1
        
    for t in topics:
        tid = t['id']
        t['questionCount'] = topic_counts.get(tid, 0)
        t['title'] = t['title'].replace("UK", "Belgian")
        t['description'] = t['description'].replace("UK", "Belgian")
        
    os.makedirs(os.path.dirname(SEED_Q), exist_ok=True)
    with open(SEED_Q, 'w', encoding='utf-8') as f:
        json.dump(questions, f, indent=2, ensure_ascii=False)
        
    with open(SEED_T, 'w', encoding='utf-8') as f:
        json.dump(topics, f, indent=2, ensure_ascii=False)
        
    print(f"Saved {len(questions)} classified questions to {SEED_Q}")
    print(f"Saved {len(topics)} topics to {SEED_T}")

if __name__ == "__main__":
    classify()
