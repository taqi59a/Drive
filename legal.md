# Legal Compliance & GDPR Analysis: Drive Better

This document outlines the legal compliance framework for the **Drive Better** mobile application, specifically addressing European Union copyright rules, fair use exceptions, and the General Data Protection Regulation (GDPR).

---

## 1. Copyright & Intellectual Property Attribution

### Source Material Acknowledgement
- **Source Website:** [drivinglicence-belgium.be](https://www.drivinglicence-belgium.be/)
- **Nature of Use:** The driving theory information, practice questions, and accompanying traffic images are used strictly for **non-commercial, educational, and exam preparation purposes**.
- **Attribution:** The application provides explicit, clear attribution to the source website within the application settings ("Attribution & Copyright"). This ensures users are fully aware of the origin of the materials and prevents any brand confusion or passing-off.

### EU Copyright Exception (Fair Use for Education)
Under European Union copyright law, specifically **Article 5(3)(a) of the InfoSoc Directive (2001/29/EC)** and **Article 3 of the Digital Single Market (DSM) Directive (2019/790)**, Member States provide exceptions or limitations to copyright for:
1. **Illustration for Teaching:** Use of copyrighted works for the sole purpose of illustration for teaching or scientific research, to the extent justified by the non-commercial purpose.
2. **Personal Study & Private Use:** Educational exam preparation by individuals is widely protected under private copying and personal training exemptions.

Since the application functions exclusively as a self-study educational training aid to prepare users for the official Belgian driving exam:
- The use of diagrams, text, and scenario photos is limited to what is strictly necessary to illustrate the traffic rules.
- There is no commercial exploitation of the copyrighted assets.
- Clear attribution is given, respecting the moral rights of the creators.

---

## 2. GDPR Compliance (General Data Protection Regulation)

The application fully complies with the EU General Data Protection Regulation (GDPR) due to its architectural design:

### A. No Data Transmission
- **100% Offline Architecture:** The application does not utilize external database syncing or cloud databases for personal study history. All progress, bookmarks, test history, and study stats are saved in a local, encrypted/sandboxed **Isar Database** on the user's physical device.
- **No Third-Party Analytics or Trackers:** No tracking libraries, telemetry tools, or advertising IDs (IDFAs/GAIDs) are integrated.

### B. Personal Data & PII
- The app does not request, collect, or store any Personally Identifiable Information (PII) such as names, email addresses, phone numbers, or locations.
- Under **GDPR Article 2(2)(c)**, the regulation does not apply to the processing of personal data by a natural person in the course of a **purely personal or household activity**. Since the progress data is generated and stored locally on the user's own device for their personal educational preparation, it is exempt from controller/processor obligations.

### C. Right to Erasure (Article 17) & Control
- Users have full control over their local data.
- The "Clear Progress" button in the Settings screen immediately and permanently deletes all study records, attempts, and bookmarks from the local Isar database.

---

## 3. Summary of Legal Compliance

| Aspect | Status | Rationale |
| :--- | :--- | :--- |
| **GDPR** | **Fully Compliant** | Offline-first architecture, no data collection, no trackers, local sandboxed storage. |
| **Copyright Law** | **Compliant** | Educational use exception under EU Directive 2001/29/EC Art. 5; full attribution provided. |
| **Trademark / Branding** | **Compliant** | No trademark infringement; clear disclaimer stating no official affiliation or endorsement. |
