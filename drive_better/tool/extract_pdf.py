#!/usr/bin/env python3
"""
Drive Better — PDF Question Extractor (Claude-powered)
Extracts Q&A from the UK Driving Theory Book PDF using Claude claude-sonnet-4-6.

Requirements:
  pip install pdfplumber anthropic

Usage (from the drive_better/ directory):
  export ANTHROPIC_API_KEY=sk-ant-...
  python3 tool/extract_pdf.py

Outputs:
  assets/seed/questions.json  — appends/merges with existing
  assets/seed/topics.json     — updated question counts
"""

import json
import os
import re
import sys
import time

try:
    import pdfplumber
except ImportError:
    print("Install pdfplumber: pip install pdfplumber")
    sys.exit(1)

try:
    import anthropic
except ImportError:
    print("Install anthropic: pip install anthropic")
    sys.exit(1)

PDF_PATH = "../Driving Theory Book 2022.pdf"
OUT_QUESTIONS = "assets/seed/questions.json"
OUT_TOPICS = "assets/seed/topics.json"

TOPICS = [
    {"id": "road_signs",       "title": "Road Signs",         "order": 1, "colorHex": "#1B3A6B", "iconName": "sign_post"},
    {"id": "hazard_awareness", "title": "Hazard Awareness",   "order": 2, "colorHex": "#E5484D", "iconName": "warning"},
    {"id": "motorway_rules",   "title": "Motorway Rules",     "order": 3, "colorHex": "#2A5298", "iconName": "directions"},
    {"id": "vehicle_safety",   "title": "Vehicle Safety",     "order": 4, "colorHex": "#2EBD85", "iconName": "car_repair"},
    {"id": "rules_of_road",    "title": "Rules of the Road",  "order": 5, "colorHex": "#7C3AED", "iconName": "rule"},
    {"id": "road_works",       "title": "Road Works",         "order": 6, "colorHex": "#F59E0B", "iconName": "construction"},
    {"id": "accidents",        "title": "Accidents",          "order": 7, "colorHex": "#EF4444", "iconName": "local_hospital"},
    {"id": "environment",      "title": "Environment",        "order": 8, "colorHex": "#10B981", "iconName": "eco"},
]

TOPIC_IDS = [t["id"] for t in TOPICS]

SYSTEM_PROMPT = """You are extracting UK driving theory test questions from a textbook page.
Return ONLY a JSON array of question objects — no markdown, no explanation.
Each object must have exactly these fields:
{
  "text": "<the question>",
  "options": ["<A>", "<B>", "<C>", "<D>"],
  "correctIndex": 0,
  "explanation": "<why this is correct, 1-2 sentences>",
  "topicId": "<one of: road_signs, hazard_awareness, motorway_rules, vehicle_safety, rules_of_road, road_works, accidents, environment>",
  "difficulty": "<Easy|Medium|Hard>"
}
If the page has no questions, return [].
correctIndex is 0-based (0=A, 1=B, 2=C, 3=D).
Only extract complete questions with 4 options and a clear correct answer.
"""

def extract_text_from_page(page) -> str:
    text = page.extract_text()
    if not text:
        return ""
    # Normalise whitespace
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    return "\n".join(lines)

def classify_topic(text: str) -> str:
    text_lower = text.lower()
    if any(w in text_lower for w in ["sign", "signal", "marking", "give way", "stop line"]):
        return "road_signs"
    if any(w in text_lower for w in ["motorway", "hard shoulder", "contraflow", "smart motorway"]):
        return "motorway_rules"
    if any(w in text_lower for w in ["hazard", "perception", "anticipat"]):
        return "hazard_awareness"
    if any(w in text_lower for w in ["tyre", "brake", "engine", "vehicle", "fuel", "exhaust", "windscreen"]):
        return "vehicle_safety"
    if any(w in text_lower for w in ["emission", "environment", "pollution", "catalytic", "eco"]):
        return "environment"
    if any(w in text_lower for w in ["accident", "crash", "first aid", "casualty", "emergency"]):
        return "accidents"
    if any(w in text_lower for w in ["road work", "roadwork", "contra", "cones"]):
        return "road_works"
    return "rules_of_road"

def ask_claude(client, page_text: str, page_num: int):
    try:
        msg = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=2000,
            system=SYSTEM_PROMPT,
            messages=[{
                "role": "user",
                "content": f"Page {page_num}:\n\n{page_text[:3000]}"
            }]
        )
        raw = msg.content[0].text.strip()
        # Strip markdown code fences if present
        raw = re.sub(r'^```json?\s*', '', raw)
        raw = re.sub(r'\s*```$', '', raw)
        return json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"  JSON error on page {page_num}: {e}")
        return []
    except Exception as e:
        print(f"  Claude error on page {page_num}: {e}")
        return None

def load_existing_questions() -> list:
    if os.path.exists(OUT_QUESTIONS):
        with open(OUT_QUESTIONS, "r") as f:
            return json.load(f)
    return []

def save_questions(questions: list):
    with open(OUT_QUESTIONS, "w") as f:
        json.dump(questions, f, indent=2, ensure_ascii=False)

def update_topics(questions: list):
    counts = {t["id"]: 0 for t in TOPICS}
    for q in questions:
        tid = q.get("topicId", "rules_of_road")
        if tid in counts:
            counts[tid] += 1

    topics_out = []
    for t in TOPICS:
        topics_out.append({
            "id": t["id"],
            "title": t["title"],
            "description": f"UK Highway Code — {t['title']}",
            "order": t["order"],
            "questionCount": counts[t["id"]],
            "iconName": t["iconName"],
            "colorHex": t["colorHex"],
        })
    with open(OUT_TOPICS, "w") as f:
        json.dump(topics_out, f, indent=2, ensure_ascii=False)
    return counts

def main():
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("Set ANTHROPIC_API_KEY environment variable")
        sys.exit(1)

    client = anthropic.Anthropic(api_key=api_key)

    if not os.path.exists(PDF_PATH):
        print(f"PDF not found at {PDF_PATH}")
        sys.exit(1)

    existing = load_existing_questions()
    existing_ids = {q["id"] for q in existing}
    new_questions = []

    # Ensure cache directory exists
    script_dir = os.path.dirname(os.path.abspath(__file__))
    cache_dir = os.path.join(script_dir, "extracted_pages")
    os.makedirs(cache_dir, exist_ok=True)

    print(f"PDF: {PDF_PATH}")
    print(f"Existing questions: {len(existing)}")

    with pdfplumber.open(PDF_PATH) as pdf:
        total_pages = len(pdf.pages)
        print(f"Total pages: {total_pages}")

        for page_num, page in enumerate(pdf.pages, start=1):
            text = extract_text_from_page(page)
            if len(text) < 100:
                continue

            # Only process pages likely to have Q&A content
            has_qa_markers = any(c in text for c in ["?", "A.", "B.", "a)", "b)"])
            if not has_qa_markers:
                continue

            cache_file = os.path.join(cache_dir, f"page_{page_num}.json")
            if os.path.exists(cache_file):
                print(f"  Processing page {page_num}/{total_pages} (cached)...", end="", flush=True)
                try:
                    with open(cache_file, "r", encoding="utf-8") as f:
                        extracted = json.load(f)
                except Exception as e:
                    print(f" Cache read error: {e}. Re-asking Claude...", end="", flush=True)
                    extracted = ask_claude(client, text, page_num)
                    if extracted is not None:
                        with open(cache_file, "w", encoding="utf-8") as f:
                            json.dump(extracted, f, indent=2, ensure_ascii=False)
            else:
                print(f"  Processing page {page_num}/{total_pages}...", end="", flush=True)
                extracted = ask_claude(client, text, page_num)
                if extracted is not None:
                    try:
                        with open(cache_file, "w", encoding="utf-8") as f:
                            json.dump(extracted, f, indent=2, ensure_ascii=False)
                    except Exception as e:
                        print(f" Cache write error: {e}")

            if extracted is None:
                # Do not proceed with processing this page if Claude API failed
                continue

            page_new = 0
            for i, q in enumerate(extracted):
                if not isinstance(q, dict):
                    continue
                if not q.get("text") or not q.get("options"):
                    continue

                # Validate
                options = q.get("options", [])
                if len(options) != 4:
                    continue
                correct = q.get("correctIndex", 0)
                if not isinstance(correct, int) or correct < 0 or correct > 3:
                    continue

                # Assign topicId if missing or invalid
                topic_id = q.get("topicId", "")
                if topic_id not in TOPIC_IDS:
                    topic_id = classify_topic(q["text"])

                q_id = f"pdf_{page_num}_{i}"
                if q_id in existing_ids:
                    continue

                new_questions.append({
                    "id": q_id,
                    "topicId": topic_id,
                    "text": q["text"],
                    "options": [{"text": o} for o in options],
                    "correctIndex": correct,
                    "explanation": q.get("explanation", ""),
                    "imageAsset": None,
                    "sourcePage": page_num,
                })
                page_new += 1

            print(f" {page_new} questions")
            # Avoid rate limits
            time.sleep(0.5)

    all_questions = existing + new_questions
    save_questions(all_questions)
    counts = update_topics(all_questions)

    print(f"\nDone! Total questions: {len(all_questions)} (+{len(new_questions)} new)")
    print("Topic breakdown:")
    for tid, count in counts.items():
        print(f"  {tid}: {count}")

if __name__ == "__main__":
    main()
