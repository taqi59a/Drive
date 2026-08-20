import os
import json
import re
import urllib.parse
import requests
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright

# Setup directories
DATA_DIR = os.path.join(os.getcwd(), "data")
IMAGES_DIR = os.path.join(DATA_DIR, "images")
QUESTIONS_IMG_DIR = os.path.join(IMAGES_DIR, "questions")
THEORY_IMG_DIR = os.path.join(IMAGES_DIR, "theory")

os.makedirs(QUESTIONS_IMG_DIR, exist_ok=True)
os.makedirs(THEORY_IMG_DIR, exist_ok=True)

# List of all 30 lessons (skip 15 as it does not exist)
LESSONS = [
    {"name": "booklesson1", "id": "493", "q_count": 42},
    {"name": "booklesson2", "id": "494", "q_count": 40},
    {"name": "booklesson3", "id": "495", "q_count": 32},
    {"name": "booklesson4", "id": "496", "q_count": 61},
    {"name": "booklesson5", "id": "497", "q_count": 26},
    {"name": "booklesson6", "id": "498", "q_count": 44},
    {"name": "booklesson7", "id": "499", "q_count": 28},
    {"name": "booklesson8", "id": "500", "q_count": 18},
    {"name": "booklesson9", "id": "501", "q_count": 21},
    {"name": "booklesson10", "id": "502", "q_count": 45},
    {"name": "booklesson11", "id": "503", "q_count": 34},
    {"name": "booklesson12", "id": "504", "q_count": 59},
    {"name": "booklesson13", "id": "505", "q_count": 17},
    {"name": "booklesson14", "id": "506", "q_count": 30},
    {"name": "booklesson16", "id": "507", "q_count": 77},
    {"name": "booklesson17", "id": "508", "q_count": 32},
    {"name": "booklesson18", "id": "509", "q_count": 51},
    {"name": "booklesson19", "id": "510", "q_count": 54},
    {"name": "booklesson20", "id": "511", "q_count": 41},
    {"name": "booklesson21", "id": "512", "q_count": 33},
    {"name": "booklesson22", "id": "513", "q_count": 50},
    {"name": "booklesson23", "id": "514", "q_count": 38},
    {"name": "booklesson24", "id": "515", "q_count": 28},
    {"name": "booklesson25", "id": "516", "q_count": 44},
    {"name": "booklesson26", "id": "517", "q_count": 38},
    {"name": "booklesson27", "id": "518", "q_count": 31},
    {"name": "booklesson28", "id": "519", "q_count": 41},
    {"name": "booklesson29", "id": "520", "q_count": 51},
    {"name": "booklesson30", "id": "521", "q_count": 26},
    {"name": "booklesson31", "id": "522", "q_count": 63}
]

# List of English Theory Chapters
THEORY_CHAPTERS = [
    {"title": "HOW DO YOU LEARN THEORY?", "url": "https://www.drivinglicence-belgium.be/theory/our-method"},
    {"title": "TYPES OF VEHICLES", "url": "https://www.drivinglicence-belgium.be/theory/types-of-vehicles"},
    {"title": "THE ROAD OR CARRIAGEWAY", "url": "https://www.drivinglicence-belgium.be/theory/the-public-road-and-the-carriageway"},
    {"title": "THE LANES", "url": "https://www.drivinglicence-belgium.be/theory/the-lanes"},
    {"title": "THE BICYCLE LANE", "url": "https://www.drivinglicence-belgium.be/theory/the-bicycle-lane"},
    {"title": "THE MOTORWAY", "url": "https://www.drivinglicence-belgium.be/theory/the-motorway"},
    {"title": "EXPRESS ROAD AND REGULAR ROADS", "url": "https://www.drivinglicence-belgium.be/theory/express-road-and-regular-roads"},
    {"title": "SPECIAL PLACES", "url": "https://www.drivinglicence-belgium.be/theory/special-places"},
    {"title": "THE PEDESTRIANS", "url": "https://www.drivinglicence-belgium.be/theory/the-pedestrians"},
    {"title": "THE DRIVERS", "url": "https://www.drivinglicence-belgium.be/theory/the-drivers"},
    {"title": "M.A.W. AND M.G.W.", "url": "https://www.drivinglicence-belgium.be/theory/maw-and-mgw"},
    {"title": "LOAD AND PASSENGER SEAT", "url": "https://www.drivinglicence-belgium.be/theory/load-and-passenger-seat"},
    {"title": "THE LIGHTS AND THE HORN", "url": "https://www.drivinglicence-belgium.be/theory/the-lights-and-the-horn"},
    {"title": "SPEED", "url": "https://www.drivinglicence-belgium.be/theory/speed"},
    {"title": "STOPPING DISTANCE", "url": "https://www.drivinglicence-belgium.be/theory/stopping-distance"},
    {"title": "CROSSING", "url": "https://www.drivinglicence-belgium.be/theory/crossing"},
    {"title": "OVERTAKING ON THE LEFT", "url": "https://www.drivinglicence-belgium.be/theory/overtaking-on-the-left"},
    {"title": "OVERTAKING ON THE LEFT PROHIBITED", "url": "https://www.drivinglicence-belgium.be/theory/overtaking-on-the-left-prohibited"},
    {"title": "THE AUTHORIZED PERSON", "url": "https://www.drivinglicence-belgium.be/theory/the-authorized-person"},
    {"title": "TRAFFIC LIGHTS", "url": "https://www.drivinglicence-belgium.be/theory/traffic-lights"},
    {"title": "CROSSING AND TRAFFIC SIGNS", "url": "https://www.drivinglicence-belgium.be/theory/crossing-and-traffic-signs"},
    {"title": "PRIORITY FROM THE RIGHT", "url": "https://www.drivinglicence-belgium.be/theory/priority-from-the-right"},
    {"title": "PRIORITY WHEN TURNING OFF", "url": "https://www.drivinglicence-belgium.be/theory/priority-when-turning-off"},
    {"title": "TRAIN - TRAM - BUS", "url": "https://www.drivinglicence-belgium.be/theory/train-tram-bus"},
    {"title": "PROHIBITED DIRECTION", "url": "https://www.drivinglicence-belgium.be/theory/prohibited-direction"},
    {"title": "OBLIGATORY DIRECTION", "url": "https://www.drivinglicence-belgium.be/theory/obligatory-direction"},
    {"title": "WAITING AND PARKING - PART 1", "url": "https://www.drivinglicence-belgium.be/theory/waiting-and-parking-part-1"},
    {"title": "WAITING AND PARKING - PART 2", "url": "https://www.drivinglicence-belgium.be/theory/waiting-and-parking-part-2"},
    {"title": "WAITING AND PARKING - PART 3", "url": "https://www.drivinglicence-belgium.be/theory/waiting-and-parking-part-3"},
    {"title": "ALCOHOL - DRUGS", "url": "https://www.drivinglicence-belgium.be/theory/alcohol-drugs"},
    {"title": "ACCIDENTS AND CASUALTIES", "url": "https://www.drivinglicence-belgium.be/theory/accidents-and-casualties"},
    {"title": "ENERGY USE", "url": "https://www.drivinglicence-belgium.be/theory/energy-use"},
    {"title": "TECHNIQUE", "url": "https://www.drivinglicence-belgium.be/theory/tires-brakes-abs-esp"}
]

def parse_question_html(html_content):
    """
    Parses the question HTML to extract structured data:
    - Clean Question text
    - Clean Options with their IDs
    """
    soup = BeautifulSoup(html_content, "html.parser")
    
    # Extract options
    options = []
    inputs = soup.find_all("input")
    
    # If inputs exist, we try to extract options
    if inputs:
        # Separate the question text from options
        # Usually options are wrapped in labels, or just text after the inputs
        # Let's find labels first
        labels = soup.find_all("label")
        if labels:
            for lbl in labels:
                inp = lbl.find("input")
                val = inp.get("value") if inp else None
                if not val:
                    # check sibling or if input is just inside label
                    continue
                # Extract clean text of the option
                lbl_text = lbl.get_text().strip()
                # Remove choice letter if it starts with "A. ", "B. ", etc.
                lbl_text = re.sub(r'^[A-Z]\.\s*', '', lbl_text)
                options.append({"id": val, "text": lbl_text})
        else:
            # Fallback when there are no labels, e.g. text adjacent to input
            for inp in inputs:
                val = inp.get("value")
                # find sibling text
                sibling = inp.next_sibling
                text = ""
                while sibling and sibling.name != "input":
                    if isinstance(sibling, str):
                        text += sibling
                    else:
                        text += sibling.get_text()
                    sibling = sibling.next_sibling
                text = text.strip()
                # Clean up radio indicator prefix if present
                text = re.sub(r'^[A-Z]\.\s*', '', text)
                text = re.sub(r'^[:\.\s\-]+', '', text)
                if val:
                    options.append({"id": val, "text": text})
                    
    # Clean question text (remove inputs and labels)
    for inp in soup.find_all("input"):
        inp.decompose()
    for lbl in soup.find_all("label"):
        lbl.decompose()
        
    question_text = soup.get_text().strip()
    # Remove hanging breaks, lines, or A., B. prefixes from the question text itself
    question_text = re.sub(r'\s+', ' ', question_text)
    # Remove option indicators that might be left
    question_text = re.sub(r'\s+[A-Z]\.\s*$', '', question_text)
    
    return question_text, options

def main():
    print("Starting Driving Exam Scraper...")
    all_data = {
        "theory": [],
        "questions": []
    }
    
    # Load existing data.json if it exists to allow resuming / skipping scraped components
    json_path = os.path.join(DATA_DIR, "data.json")
    if os.path.exists(json_path):
        try:
            with open(json_path, "r", encoding="utf-8") as f:
                loaded_data = json.load(f)
                if loaded_data.get("questions"):
                    all_data["questions"] = loaded_data["questions"]
                    print(f"Loaded {len(all_data['questions'])} existing questions from data.json.")
                if loaded_data.get("theory"):
                    all_data["theory"] = loaded_data["theory"]
                    print(f"Loaded {len(all_data['theory'])} existing theory chapters from data.json.")
        except Exception as err:
            print(f"Error loading existing data.json: {err}")
            
    with sync_playwright() as p:
        print("Launching browser...")
        browser = p.chromium.launch(headless=True)
        # Use a mobile-like or standard desktop user agent to avoid bot detection
        context = browser.new_context(
            viewport={"width": 1280, "height": 800},
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )
        page = context.new_page()
        
        # 1. Login
        login_url = "https://examen.gratisrijbewijsonline.be/examen/login/codehandboektheorydrivinglicencebofsmscode/booklesson1/493"
        print(f"Navigating to login page: {login_url}")
        page.goto(login_url)
        page.wait_for_timeout(3000) # Wait for page scripts
        
        print("Submitting login credentials...")
        page.evaluate("""() => {
            const emailField = document.getElementById('bank-login-email');
            const codeField = document.getElementById('bank-login-code');
            if (emailField && codeField) {
                emailField.style.display = 'block';
                emailField.style.visibility = 'visible';
                let parent = emailField.parentElement;
                while (parent) {
                    parent.style.display = 'block';
                    parent.style.visibility = 'visible';
                    parent = parent.parentElement;
                }
                emailField.value = 'numankhizar205@gmail.com';
                codeField.value = '274850';
                
                const submitBtn = document.querySelector('input[type="submit"]') || document.querySelector('button[type="submit"]') || document.querySelector('#bank-login-submit');
                if (submitBtn) {
                    submitBtn.click();
                } else {
                    const form = emailField.closest('form');
                    if (form) form.submit();
                }
            }
        }""")
        
        page.wait_for_timeout(5000) # Wait for login redirect
        print(f"Current URL after login: {page.url}")
        
        # Establish authenticated session for requests downloads
        cookies = context.cookies()
        session = requests.Session()
        session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        })
        for c in cookies:
            session.cookies.set(c['name'], c['value'], domain=c['domain'])
            
        # 2. Scrape Questions
        questions_already_loaded = len(all_data["questions"]) > 0
        print("\n--- Scraping Questions ---")
        for index, lesson in enumerate(LESSONS, 1):
            if questions_already_loaded:
                print("Skipping questions scraping (already loaded).")
                break
            lesson_url = f"https://examen.gratisrijbewijsonline.be/examen/vraag/1/{lesson['name']}/{lesson['id']}"
            print(f"Scraping Lesson {index}/{len(LESSONS)}: {lesson['name']} ({lesson['q_count']} questions) -> {lesson_url}")
            try:
                page.goto(lesson_url)
                # Wait for examen to be defined
                page.wait_for_function("typeof examen !== 'undefined'", timeout=15000)
                
                examen_data = page.evaluate("examen")
                serie_id = page.evaluate("serie_id")
                
                print(f"  Successfully extracted {len(examen_data)} questions (Serie ID: {serie_id})")
                
                for q in examen_data:
                    q_id = q.get("id")
                    qid = q.get("qid")
                    raw_q_html = q.get("q", "")
                    raw_e_html = q.get("e", "")
                    solution = q.get("s", "").strip().lower()
                    
                    # Parse clean question & options
                    clean_question, options = parse_question_html(raw_q_html)
                    
                    # Clean explanation text
                    e_soup = BeautifulSoup(raw_e_html, "html.parser")
                    clean_explanation = e_soup.get_text().strip()
                    
                    local_img_path = None
                    if qid:
                        img_url = f"https://examen.gratisrijbewijsonline.be/afbeeldingen/{serie_id}/{qid}.jpg"
                        local_filename = f"{q_id}.jpg"
                        dest_path = os.path.join(QUESTIONS_IMG_DIR, local_filename)
                        
                        # Download question image
                        try:
                            img_resp = session.get(img_url, timeout=10)
                            if img_resp.status_code == 200:
                                with open(dest_path, "wb") as f:
                                    f.write(img_resp.content)
                                local_img_path = f"images/questions/{local_filename}"
                            else:
                                print(f"    Failed to download image {img_url} (HTTP {img_resp.status_code})")
                        except Exception as img_err:
                            print(f"    Error downloading image {img_url}: {img_err}")
                            
                    all_data["questions"].append({
                        "id": q_id,
                        "lesson_name": lesson["name"],
                        "lesson_id": lesson["id"],
                        "serie_id": serie_id,
                        "question_raw": raw_q_html,
                        "question_text": clean_question,
                        "options": options,
                        "correct_option": solution,
                        "explanation_raw": raw_e_html,
                        "explanation_text": clean_explanation,
                        "image_path": local_img_path,
                        "weight": q.get("qw", 1)
                    })
            except Exception as e:
                print(f"  Error scraping lesson {lesson['name']}: {e}")
                
        # 3. Scrape Theory Chapters
        # Clear existing theory chapters to ensure fresh scraping of updated content and images
        all_data["theory"] = []
        print("\n--- Scraping Theory Chapters ---")
        
        # Log in on the theory domain first to bypass paywall
        theory_login_url = "https://www.drivinglicence-belgium.be/login/pagina/theory/the-lanes"
        print(f"Logging in on theory domain: {theory_login_url}")
        try:
            page.goto(theory_login_url)
            page.wait_for_timeout(3000)
            
            # Accept cookies if banner is present
            try:
                accept_btn = page.query_selector("button:has-text('Accept all cookies'), button:has-text('Alle cookies accepteren')")
                if accept_btn:
                    accept_btn.click()
                    page.wait_for_timeout(1000)
            except:
                pass
                
            page.evaluate("""() => {
                const emailField = document.getElementById('bank-login-email');
                const codeField = document.getElementById('bank-login-code');
                if (emailField && codeField) {
                    emailField.style.display = 'block';
                    emailField.style.visibility = 'visible';
                    let parent = emailField.parentElement;
                    while (parent) {
                        parent.style.display = 'block';
                        parent.style.visibility = 'visible';
                        parent = parent.parentElement;
                    }
                    emailField.value = 'numankhizar205@gmail.com';
                    codeField.value = '274850';
                    
                    const submitBtn = document.querySelector('input[type="submit"]') || document.querySelector('button[type="submit"]') || document.querySelector('#bank-login-submit');
                    if (submitBtn) {
                        submitBtn.click();
                    } else {
                        const form = emailField.closest('form');
                        if (form) form.submit();
                    }
                }
            }""")
            page.wait_for_timeout(5000) # Wait for redirection
            print(f"Logged in on theory domain. Current URL: {page.url}")
            
            # Update requests session cookies with the new cookies from the theory domain
            cookies = context.cookies()
            for c in cookies:
                session.cookies.set(c['name'], c['value'], domain=c['domain'])
        except Exception as e:
            print(f"Failed to log in on theory domain: {e}")
            
        for index, chap in enumerate(THEORY_CHAPTERS, 1):
            print(f"Scraping Theory Chapter {index}/{len(THEORY_CHAPTERS)}: {chap['title']} -> {chap['url']}")
            try:
                page.goto(chap['url'])
                page.wait_for_timeout(2000)
                
                # Check for cookies banner and accept if present
                try:
                    accept_btn = page.query_selector("button:has-text('Accept all cookies'), button:has-text('Alle cookies accepteren')")
                    if accept_btn:
                        accept_btn.click()
                        page.wait_for_timeout(1000)
                except:
                    pass
                
                # Extract main content and image mapping
                page_data = page.evaluate("""() => {
                    const elem = document.querySelector('main');
                    if (!elem) return null;
                    
                    // Find all images inside main
                    const imgs = Array.from(elem.querySelectorAll('img'));
                    const imgMapping = imgs.map(img => {
                        return {
                            raw_src: img.getAttribute('src'),
                            abs_src: img.src
                        };
                    });
                    
                    return {
                        html: elem.innerHTML,
                        images: imgMapping
                    };
                }""")
                
                if not page_data or not page_data['html']:
                    print("  Warning: No content found, skipping.")
                    continue
                    
                # Clean content HTML and download embedded images
                soup = BeautifulSoup(page_data['html'], "html.parser")
                
                # Remove headers, scripts, sidebars, block views, comments if BeautifulSoup grabbed too much
                for tag in soup.find_all(["script", "style", "nav", "iframe"]):
                    tag.decompose()
                    
                # Extract and download images
                img_index = 0
                for img_info in page_data['images']:
                    raw_src = img_info['raw_src']
                    abs_src = img_info['abs_src']
                    if not raw_src or not abs_src:
                        continue
                    
                    # Ignore small tracking pixels or icons
                    if "analytics" in abs_src or "doubleclick" in abs_src or "google" in abs_src:
                        # Decompose tags containing these
                        for t in soup.find_all("img", src=raw_src):
                            t.decompose()
                        continue
                        
                    # Create clean local filename
                    chap_slug = re.sub(r'[^a-z0-9]', '_', chap['title'].lower())
                    local_filename = f"{chap_slug}_{img_index}.jpg"
                    dest_path = os.path.join(THEORY_IMG_DIR, local_filename)
                    
                    try:
                        img_resp = requests.get(abs_src, timeout=10)
                        if img_resp.status_code == 200:
                            with open(dest_path, "wb") as f:
                                f.write(img_resp.content)
                            # Update source in HTML for all matching img tags
                            for img_tag in soup.find_all("img", src=raw_src):
                                img_tag["src"] = f"images/theory/{local_filename}"
                            img_index += 1
                        else:
                            # Keep original url as fallback
                            for img_tag in soup.find_all("img", src=raw_src):
                                img_tag["src"] = abs_src
                    except Exception as img_err:
                        print(f"    Failed to download theory image {abs_src}: {img_err}")
                        for img_tag in soup.find_all("img", src=raw_src):
                            img_tag["src"] = abs_src
                
                # Store the cleaned HTML and plain text
                all_data["theory"].append({
                    "title": chap["title"],
                    "url": chap["url"],
                    "content_html": str(soup),
                    "content_text": soup.get_text().strip()
                })
                print(f"  Successfully saved theory with {img_index} images")
            except Exception as e:
                print(f"  Error scraping theory chapter {chap['title']}: {e}")
                
        browser.close()
        
    # 4. Save JSON dataset
    json_path = os.path.join(DATA_DIR, "data.json")
    print(f"\nWriting final dataset to {json_path}...")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)
        
    # 5. Generate index.html viewer
    generate_html_viewer(all_data)
    
    print("\nScraping process complete!")

def generate_html_viewer(data):
    html_path = os.path.join(DATA_DIR, "index.html")
    print(f"Generating offline HTML viewer: {html_path}")
    
    # We will build a premium responsive HTML interface
    html_content = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driving License Belgium - Offline Content</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #0f172a;
            --card-bg: #1e293b;
            --text-primary: #f8fafc;
            --text-secondary: #94a3b8;
            --accent: #3b82f6;
            --accent-hover: #2563eb;
            --border-color: #334155;
            --success: #10b981;
            --danger: #ef4444;
        }
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Inter', sans-serif;
        }
        body {
            background-color: var(--bg-color);
            color: var(--text-primary);
            display: flex;
            height: 100vh;
            overflow: hidden;
        }
        /* Sidebar layout */
        aside {
            width: 320px;
            background-color: #0b0f19;
            border-right: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }
        .sidebar-header {
            padding: 20px;
            border-bottom: 1px solid var(--border-color);
        }
        .sidebar-header h1 {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-primary);
        }
        .tab-menu {
            display: flex;
            border-bottom: 1px solid var(--border-color);
        }
        .tab-btn {
            flex: 1;
            padding: 12px;
            background: none;
            border: none;
            color: var(--text-secondary);
            font-weight: 600;
            cursor: pointer;
            text-align: center;
            transition: all 0.2s ease;
        }
        .tab-btn.active {
            color: var(--accent);
            border-bottom: 2px solid var(--accent);
            background-color: rgba(59, 130, 246, 0.05);
        }
        .sidebar-list {
            flex: 1;
            overflow-y: auto;
            padding: 10px;
        }
        .list-item {
            display: block;
            width: 100%;
            text-align: left;
            padding: 10px 15px;
            background: none;
            border: none;
            border-radius: 6px;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.2s ease;
            margin-bottom: 4px;
            font-size: 0.875rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .list-item:hover {
            background-color: rgba(255, 255, 255, 0.05);
            color: var(--text-primary);
        }
        .list-item.active {
            background-color: var(--accent);
            color: #fff;
            font-weight: 500;
        }
        
        /* Main Panel content */
        main {
            flex: 1;
            overflow-y: auto;
            padding: 40px;
            background: radial-gradient(circle at top left, #131b2e 0%, #0f172a 100%);
        }
        .content-section {
            max-width: 800px;
            margin: 0 auto;
            display: none;
        }
        .content-section.active {
            display: block;
            animation: fadeIn 0.3s ease;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        /* Theory Styles */
        .theory-title {
            font-size: 2.25rem;
            font-weight: 700;
            margin-bottom: 20px;
            color: #fff;
        }
        .theory-body {
            line-height: 1.7;
            font-size: 1.05rem;
            color: #cbd5e1;
        }
        .theory-body p {
            margin-bottom: 20px;
        }
        .theory-body h2 {
            font-size: 1.5rem;
            margin-top: 30px;
            margin-bottom: 15px;
            color: #fff;
        }
        .theory-body img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 20px 0;
            border: 1px solid var(--border-color);
        }
        
        /* Questions Styles */
        .lesson-header {
            margin-bottom: 30px;
        }
        .lesson-title {
            font-size: 2rem;
            font-weight: 700;
        }
        .question-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        .question-image {
            max-width: 100%;
            max-height: 400px;
            object-fit: contain;
            border-radius: 8px;
            margin-bottom: 20px;
            display: block;
            background-color: #0b0f19;
            border: 1px solid var(--border-color);
        }
        .question-num {
            font-size: 0.875rem;
            color: var(--accent);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 10px;
        }
        .question-text {
            font-size: 1.25rem;
            font-weight: 600;
            line-height: 1.4;
            margin-bottom: 20px;
        }
        .options-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 20px;
        }
        .option-item {
            padding: 14px 20px;
            border: 1px solid var(--border-color);
            background-color: rgba(255, 255, 255, 0.02);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
            font-weight: 500;
            display: flex;
            align-items: center;
        }
        .option-item:hover {
            background-color: rgba(255, 255, 255, 0.05);
            border-color: var(--accent);
        }
        .option-item.selected {
            background-color: rgba(59, 130, 246, 0.1);
            border-color: var(--accent);
        }
        .option-letter {
            width: 28px;
            height: 28px;
            background-color: var(--border-color);
            color: var(--text-primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.875rem;
            font-weight: 700;
            margin-right: 15px;
            flex-shrink: 0;
        }
        .option-item.selected .option-letter {
            background-color: var(--accent);
            color: #fff;
        }
        .option-item.correct {
            border-color: var(--success);
            background-color: rgba(16, 185, 129, 0.1);
        }
        .option-item.correct .option-letter {
            background-color: var(--success);
            color: #fff;
        }
        .option-item.wrong {
            border-color: var(--danger);
            background-color: rgba(239, 68, 68, 0.1);
        }
        .option-item.wrong .option-letter {
            background-color: var(--danger);
            color: #fff;
        }
        
        .explanation-box {
            margin-top: 20px;
            padding: 20px;
            background-color: rgba(16, 185, 129, 0.05);
            border-left: 4px solid var(--success);
            border-radius: 0 8px 8px 0;
            display: none;
        }
        .explanation-box.visible {
            display: block;
            animation: fadeIn 0.2s ease;
        }
        .explanation-box h4 {
            color: var(--success);
            font-size: 1rem;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .explanation-box p {
            line-height: 1.5;
            font-size: 0.95rem;
            color: #e2e8f0;
        }
        .verify-btn {
            padding: 12px 24px;
            background-color: var(--accent);
            color: #fff;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        .verify-btn:hover {
            background-color: var(--accent-hover);
        }
    </style>
</head>
<body>
    <aside>
        <div class="sidebar-header">
            <h1>Driving License BE</h1>
        </div>
        <div class="tab-menu">
            <button class="tab-btn active" onclick="switchTab('theory')">Theory</button>
            <button class="tab-btn" onclick="switchTab('questions')">Questions</button>
        </div>
        <div class="sidebar-list" id="sidebar-items">
            <!-- Items loaded dynamically -->
        </div>
    </aside>
    
    <main id="main-content">
        <!-- Content loaded dynamically -->
        <div style="display:flex; justify-content:center; align-items:center; height:100%; text-align:center;">
            <div>
                <h2 style="font-size: 2rem; margin-bottom: 10px;">Welcome</h2>
                <p style="color: var(--text-secondary);">Select a chapter or lesson from the sidebar to begin.</p>
            </div>
        </div>
    </main>

    <script>
        const appData = %DATA_JSON%;
        let currentTab = 'theory';
        
        function switchTab(tab) {
            currentTab = tab;
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.toggle('active', btn.textContent.toLowerCase() === tab);
            });
            renderSidebar();
        }
        
        function renderSidebar() {
            const listContainer = document.getElementById('sidebar-items');
            listContainer.innerHTML = '';
            
            if (currentTab === 'theory') {
                appData.theory.forEach((chap, idx) => {
                    const btn = document.createElement('button');
                    btn.className = 'list-item';
                    btn.textContent = `${idx + 1}. ${chap.title}`;
                    btn.onclick = () => loadTheory(idx, btn);
                    listContainer.appendChild(btn);
                });
            } else {
                // Group questions by lesson
                const lessons = {};
                appData.questions.forEach(q => {
                    if (!lessons[q.lesson_name]) {
                        lessons[q.lesson_name] = [];
                    }
                    lessons[q.lesson_name].push(q);
                });
                
                Object.keys(lessons).forEach((lessonName, idx) => {
                    const btn = document.createElement('button');
                    btn.className = 'list-item';
                    const prettyName = lessonName.replace('booklesson', 'Lesson ');
                    btn.textContent = `${prettyName} (${lessons[lessonName].length} Qs)`;
                    btn.onclick = () => loadLesson(lessonName, btn);
                    listContainer.appendChild(btn);
                });
            }
        }
        
        function selectSidebarItem(btn) {
            document.querySelectorAll('.list-item').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
        }
        
        function loadTheory(idx, btn) {
            selectSidebarItem(btn);
            const chap = appData.theory[idx];
            const main = document.getElementById('main-content');
            main.innerHTML = `
                <div class="content-section active">
                    <h1 class="theory-title">${chap.title}</h1>
                    <div class="theory-body">${chap.content_html}</div>
                </div>
            `;
        }
        
        function loadLesson(lessonName, btn) {
            selectSidebarItem(btn);
            const questions = appData.questions.filter(q => q.lesson_name === lessonName);
            const main = document.getElementById('main-content');
            
            let html = `
                <div class="content-section active">
                    <div class="lesson-header">
                        <h1 class="lesson-title">${lessonName.replace('booklesson', 'Lesson ').toUpperCase()}</h1>
                        <p style="color: var(--text-secondary); margin-top:5px;">Total Questions: ${questions.length}</p>
                    </div>
            `;
            
            questions.forEach((q, qIdx) => {
                const imgTag = q.image_path ? `<img class="question-image" src="${q.image_path}" alt="Question Image">` : '';
                
                let optionsHtml = '';
                if (q.options && q.options.length > 0) {
                    q.options.forEach(opt => {
                        optionsHtml += `
                            <li class="option-item" onclick="selectOption(this, '${opt.id}', '${q.id}')" data-opt-id="${opt.id}">
                                <div class="option-letter">${opt.id.toUpperCase()}</div>
                                <span>${opt.text}</span>
                            </li>
                        `;
                    });
                } else {
                    // Fallback for simple input (yes/no or fill-in)
                    optionsHtml += `
                        <li class="option-item" onclick="selectOption(this, 'yes', '${q.id}')" data-opt-id="yes">
                            <div class="option-letter">Y</div>
                            <span>Yes</span>
                        </li>
                        <li class="option-item" onclick="selectOption(this, 'no', '${q.id}')" data-opt-id="no">
                            <div class="option-letter">N</div>
                            <span>No</span>
                        </li>
                    `;
                }
                
                html += `
                    <div class="question-card" id="q-card-${q.id}">
                        <div class="question-num">Question ${qIdx + 1}</div>
                        ${imgTag}
                        <div class="question-text">${q.question_text || q.question_raw}</div>
                        <ul class="options-list">
                            ${optionsHtml}
                        </ul>
                        <button class="verify-btn" onclick="verifyAnswer('${q.id}', '${q.correct_option}')">Check Answer</button>
                        <div class="explanation-box" id="explain-${q.id}">
                            <h4>Explanation</h4>
                            <p>${q.explanation_text || 'No explanation provided.'}</p>
                        </div>
                    </div>
                `;
            });
            
            html += `</div>`;
            main.innerHTML = html;
        }
        
        function selectOption(elem, optId, qId) {
            const card = document.getElementById(`q-card-${qId}`);
            card.querySelectorAll('.option-item').forEach(item => {
                item.classList.remove('selected');
            });
            elem.classList.add('selected');
            // Store selection in attribute
            card.setAttribute('data-selected-opt', optId);
        }
        
        function verifyAnswer(qId, correctOpt) {
            const card = document.getElementById(`q-card-${qId}`);
            const selectedOpt = card.getAttribute('data-selected-opt');
            
            if (!selectedOpt) {
                alert('Please select an option first!');
                return;
            }
            
            card.querySelectorAll('.option-item').forEach(item => {
                const optId = item.getAttribute('data-opt-id');
                item.classList.remove('correct', 'wrong');
                if (optId === correctOpt) {
                    item.classList.add('correct');
                } else if (optId === selectedOpt) {
                    item.classList.add('wrong');
                }
            });
            
            // Show explanation
            const explain = document.getElementById(`explain-${qId}`);
            explain.classList.add('visible');
        }
        
        // Initial Sidebar load
        renderSidebar();
    </script>
</body>
</html>"""
    
    # Embed json data safely
    data_json_str = json.dumps(data, ensure_ascii=False)
    html_content = html_content.replace("%DATA_JSON%", data_json_str)
    
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)

if __name__ == "__main__":
    main()
