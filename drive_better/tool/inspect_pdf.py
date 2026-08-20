import pdfplumber
import sys

def main():
    pdf_path = "Driving Theory Book 2022.pdf"
    print(f"Opening {pdf_path}...")
    try:
        with pdfplumber.open(pdf_path) as pdf:
            print(f"Total pages: {len(pdf.pages)}")
            for page_num in [1, 5, 10, 50, 100]:
                if page_num <= len(pdf.pages):
                    page = pdf.pages[page_num - 1]
                    text = page.extract_text()
                    print(f"\n--- Page {page_num} (first 300 chars) ---")
                    if text:
                        print(text[:300])
                    else:
                        print("[No text found]")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
