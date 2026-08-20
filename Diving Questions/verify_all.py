import os
import json
from playwright.sync_api import sync_playwright
import requests

DATA_DIR = os.path.join(os.getcwd(), "data")
json_path = os.path.join(DATA_DIR, "data.json")

def main():
    if not os.path.exists(json_path):
        print("data.json not found!")
        return

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    existing_ids = {q["id"] for q in data.get("questions", [])}
    print(f"Loaded {len(existing_ids)} unique question IDs from current lessons dataset.")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )
        page = context.new_page()
        
        # Log in
        login_url = "https://examen.gratisrijbewijsonline.be/examen/login/codehandboektheorydrivinglicencebofsmscode/booklesson1/493"
        page.goto(login_url)
        page.wait_for_timeout(3000)
        
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
                if (submitBtn) submitBtn.click();
            }
        }""")
        page.wait_for_timeout(4000)
        
        # Navigate to Exam B Simulation
        exam_url = "https://examen.gratisrijbewijsonline.be/examen/vraag/1/bookexam/523"
        print(f"Checking Exam B Simulation page: {exam_url}")
        page.goto(exam_url)
        page.wait_for_timeout(3000)
        
        print(f"Loaded URL: {page.url}")
        print(f"Page Title: {page.title()}")
        
        # If we got redirected to a login page, perform login again for this path
        if "login" in page.url:
            print("Redirected to login page. Authenticating...")
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
                    if (submitBtn) submitBtn.click();
                }
            }""")
            page.wait_for_timeout(4000)
            print(f"URL after authentication: {page.url}")
            
        page.screenshot(path=os.path.join(DATA_DIR, "exam_b_diagnostic.png"))
        print("Captured diagnostic screenshot at data/exam_b_diagnostic.png")
        
        # Click start button if present to initialize the exam and define the examen variable
        try:
            start_btn = page.query_selector("#btn_start_without_voice")
            if start_btn:
                print("Clicking start button to load exam questions...")
                start_btn.click()
                page.wait_for_timeout(3000)
            else:
                print("Start button #btn_start_without_voice not found via query_selector.")
                # Print all buttons
                btns = page.query_selector_all("button, a.btn")
                for idx, b in enumerate(btns):
                    print(f"  Button {idx}: text={b.inner_text().strip()}, id={b.get_attribute('id')}, class={b.get_attribute('class')}")
        except Exception as e:
            print(f"Start button click check failed: {e}")
            
        page.wait_for_function("typeof examen !== 'undefined'", timeout=5000)
        
        exam_questions = page.evaluate("examen")
        serie_id = page.evaluate("serie_id")
        print(f"Exam B page loaded {len(exam_questions)} questions (Serie ID: {serie_id})")
        
        new_questions = []
        for q in exam_questions:
            q_id = q.get("id")
            if q_id not in existing_ids:
                new_questions.append(q)
                
        print(f"Found {len(new_questions)} new questions that were not in the lesson chapters.")
        
        # If there are new questions, we scrape them
        if new_questions:
            print("Downloading details and images for the new questions...")
            cookies = context.cookies()
            session = requests.Session()
            for c in cookies:
                session.cookies.set(c['name'], c['value'], domain=c['domain'])
                
            QUESTIONS_IMG_DIR = os.path.join(DATA_DIR, "images", "questions")
            
            # Import parsing function from scrape
            from scrape import parse_question_html
            
            for q in new_questions:
                q_id = q.get("id")
                qid = q.get("qid")
                raw_q_html = q.get("q", "")
                raw_e_html = q.get("e", "")
                solution = q.get("s", "").strip().lower()
                
                clean_question, options = parse_question_html(raw_q_html)
                
                # Clean explanation
                from bs4 import BeautifulSoup
                e_soup = BeautifulSoup(raw_e_html, "html.parser")
                clean_explanation = e_soup.get_text().strip()
                
                local_img_path = None
                if qid:
                    img_url = f"https://examen.gratisrijbewijsonline.be/afbeeldingen/{serie_id}/{qid}.jpg"
                    local_filename = f"{q_id}.jpg"
                    dest_path = os.path.join(QUESTIONS_IMG_DIR, local_filename)
                    try:
                        resp = session.get(img_url, timeout=10)
                        if resp.status_code == 200:
                            with open(dest_path, "wb") as f:
                                f.write(resp.content)
                            local_img_path = f"images/questions/{local_filename}"
                    except Exception as err:
                        print(f"  Error downloading image {img_url}: {err}")
                        
                q_data = {
                    "id": q_id,
                    "lesson_name": "bookexam",
                    "lesson_id": "523",
                    "serie_id": serie_id,
                    "question_raw": raw_q_html,
                    "question_text": clean_question,
                    "options": options,
                    "correct_option": solution,
                    "explanation_raw": raw_e_html,
                    "explanation_text": clean_explanation,
                    "image_path": local_img_path,
                    "weight": q.get("qw", 1)
                }
                data["questions"].append(q_data)
                existing_ids.add(q_id)
                
            # Write back to data.json
            with open(json_path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"Updated data.json! New total questions: {len(data['questions'])}")
            
            # Re-generate viewer
            from scrape import generate_html_viewer
            generate_html_viewer(data)
        else:
            print("No missing questions found. The dataset is already fully comprehensive.")
            
        browser.close()

if __name__ == '__main__':
    main()
