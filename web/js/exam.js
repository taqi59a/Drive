/* ==========================================
   Drive Better BE - Exam & Practice Logic
   Implements official Belgium exam rules and relaxed practice mode
   ========================================== */

// Global state for Practice and Exam
let practiceQuestions = [];
let practiceCurrentIndex = 0;
let practiceSelectedAnswer = null;

let examQuestions = [];
let examCurrentIndex = 0;
let examAnswers = []; // stores user choices: { questionId, selectedAnswer, timeSpent, correct }
let examTimer = null;
let examTimeLeft = 15;
let examTimerDuration = 15;
let examTimerFill = null;

// Initialize when App Data is ready
window.onAppDataLoaded = function() {
    setupEventListeners();
};

function setupEventListeners() {
    // Practice Mode Events
    document.getElementById('btn-start-practice').addEventListener('click', startPracticeSession);
    document.getElementById('btn-exit-practice').addEventListener('click', exitPracticeSession);
    document.getElementById('btn-practice-next').addEventListener('click', nextPracticeQuestion);
    document.getElementById('btn-feedback-study').addEventListener('click', redirectToTheory);

    // Exam Mode Events
    document.getElementById('btn-start-exam').addEventListener('click', startExamSession);

    // Exam Results Filters
    document.getElementById('btn-filter-all').addEventListener('click', () => filterResults('all'));
    document.getElementById('btn-filter-wrong').addEventListener('click', () => filterResults('wrong'));
    document.getElementById('btn-filter-major').addEventListener('click', () => filterResults('major'));
}

// Helper to shuffle arrays
function shuffle(array) {
    let currentIndex = array.length, randomIndex;
    while (currentIndex !== 0) {
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex--;
        [array[currentIndex], array[randomIndex]] = [array[randomIndex], array[currentIndex]];
    }
    return array;
}

/// Helper to decode HTML entities
function decodeHtml(htmlStr) {
    if (!htmlStr) return '';
    const txt = document.createElement("textarea");
    txt.innerHTML = htmlStr;
    return txt.value;
}

// Helper to parse options from question_raw
function parseQuestionOptions(question) {
    const co = question.correct_option ? question.correct_option.trim() : '';
    
    // Check if it is a numeric fill-in-the-blank question
    if (/^\d+$/.test(co)) {
        return [
            { key: '__numeric__', text: 'Numeric Answer' }
        ];
    }
    
    // Check if it is a Yes/No type question
    if (co.toLowerCase() === 'yes' || co.toLowerCase() === 'no') {
        return [
            { key: 'yes', text: 'Yes' },
            { key: 'no', text: 'No' }
        ];
    }

    const raw = question.question_raw || question.question_text || '';
    const cleaned = raw.replace(/<p[^>]*>\s*\*\*\*\s*5\s*points?\s*question\s*\*\*\*\s*<\/p>/gi, '')
                       .replace(/\*\*\*\s*5\s*points?\s*question\s*\*\*\*/gi, '').trim();

    const parts = cleaned.split(/<br\s*\/?>|<\/?p[^>]*>|\n/gi).map(p => p.trim()).filter(Boolean);
    const options = [];

    for (const p of parts) {
        const m = p.match(/^\s*([A-D])(?:\s*[\./,:)]|\s+\.\.\.)\s*(.*)/i);
        if (m) {
            const letter = m[1].toLowerCase();
            let text = m[2].trim().replace(/^\.{2,}\s*/, '');
            text = decodeHtml(text.replace(/<[^>]+>/g, '').trim());
            options.push({ key: letter, text: text });
        } else {
            if (options.length > 0) {
                const extra = decodeHtml(p.replace(/<[^>]+>/g, '').trim());
                if (extra) {
                    options[options.length - 1].text += ' ' + extra;
                }
            }
        }
    }

    const keys = options.map(o => o.key);
    if (keys.includes('a') && keys.includes('b')) {
        return options;
    }

    // Inline fallback search
    const mInline = cleaned.match(/\bA(?:\s*[\./,:)]|\s+\.\.\.)\s*/i);
    if (mInline) {
        const rest = cleaned.substring(mInline.index);
        const inlineOpts = [];
        const regex = /\b([A-D])(?:\s*[\./,:)]|\s+\.\.\.)\s*(.*?)(?=\b[A-D](?:\s*[\./,:)]|\s+\.\.\.)|$)/gi;
        let match;
        while ((match = regex.exec(rest)) !== null) {
            const l = match[1].toLowerCase();
            let t = match[2].replace(/<br\s*\/?>/gi, ' ').replace(/<[^>]+>/g, '').trim();
            t = decodeHtml(t.replace(/^\.{2,}\s*/, '').replace(/\s+/g, ' '));
            inlineOpts.push({ key: l, text: t });
        }
        if (inlineOpts.length > 0) return inlineOpts;
    }

    return [
        { key: 'a', text: 'Option A' },
        { key: 'b', text: 'Option B' },
        { key: 'c', text: 'Option C' }
    ];
}

// Helper to clean HTML question text for clean display
function cleanQuestionText(question) {
    const raw = question.question_raw || question.question_text || '';
    let cleaned = raw.replace(/<p[^>]*>\s*\*\*\*\s*5\s*points?\s*question\s*\*\*\*\s*<\/p>/gi, '')
                       .replace(/<span[^>]*>\s*\*\*\*\s*5\s*points?\s*question\s*\*\*\*\s*<\/span>/gi, '')
                       .replace(/\*\*\*\s*5\s*points?\s*question\s*\*\*\*/gi, '')
                       .replace(/^\s*5\s*points?\s*question\s*/gi, '').trim();

    const parts = cleaned.split(/<br\s*\/?>|<\/?p[^>]*>|\n/gi).map(p => p.trim()).filter(Boolean);
    const qTextParts = [];

    for (const p of parts) {
        if (/^\s*[A-D](?:\s*[\./,:)]|\s+\.\.\.)\s*/i.test(p)) {
            break;
        }
        qTextParts.push(p);
    }

    let result = '';
    if (qTextParts.length > 0) {
        result = qTextParts.join(' ');
    } else {
        const mInline = cleaned.match(/\bA(?:\s*[\./,:)]|\s+\.\.\.)\s*/i);
        if (mInline) {
            result = cleaned.substring(0, mInline.index);
        } else {
            result = cleaned;
        }
    }

    result = result.replace(/<br\s*\/?>/gi, ' ').replace(/<[^>]+>/g, '');
    result = decodeHtml(result.replace(/\s+/g, ' ').trim());

    // Fix missing space after punctuation
    result = result.replace(/([a-z0-9\?\!])\.([A-Z])/g, '$1. $2')
                   .replace(/([a-z0-9\?\!])\?([A-Z])/g, '$1? $2')
                   .replace(/([a-z0-9\?\!])\!([A-Z])/g, '$1! $2');

    return result;
}

// Helper to extract lesson index from explanation
function extractLessonNum(explanation) {
    const match = explanation.match(/LESSON\s+(\d+)/i);
    return match ? parseInt(match[1]) : null;
}

/* ==========================================
   PRACTICE MODE LOGIC
   ========================================== */
function startPracticeSession() {
    const topic = document.getElementById('practice-topic-select').value;
    
    // Filter questions
    if (topic === 'all') {
        practiceQuestions = [...window.appData.questions];
    } else {
        practiceQuestions = window.appData.questions.filter(q => q.lesson_name === topic);
    }

    if (practiceQuestions.length === 0) {
        alert("No questions found for this topic.");
        return;
    }

    shuffle(practiceQuestions);
    practiceCurrentIndex = 0;
    
    // Immediately preload practice session images into browser cache
    if (window.preloadQuestionImages) {
        window.preloadQuestionImages(practiceQuestions);
    }

    document.getElementById('practice-setup-card').style.display = 'none';
    document.getElementById('practice-session-container').style.display = 'block';
    
    showPracticeQuestion();
}

function exitPracticeSession() {
    document.getElementById('practice-session-container').style.display = 'none';
    document.getElementById('practice-setup-card').style.display = 'block';
}

function showPracticeQuestion() {
    const question = practiceQuestions[practiceCurrentIndex];
    practiceSelectedAnswer = null;
    
    // Meta data
    document.getElementById('practice-badge-index').textContent = `Question ${practiceCurrentIndex + 1} of ${practiceQuestions.length}`;
    document.getElementById('practice-badge-topic').textContent = question.lesson_name.replace('booklesson', 'Lesson ').replace('bookexam', 'General Exam');
    
    // Image handling
    const imgWrapper = document.getElementById('practice-image-wrapper');
    const imgEl = document.getElementById('practice-question-image');
    if (question.image_path) {
        imgEl.loading = 'eager';
        imgEl.src = question.image_path;
        imgWrapper.style.display = 'flex';
    } else {
        imgWrapper.style.display = 'none';
    }

    // Prefetch next 3 practice question images for instant zero-delay transitions
    for (let i = 1; i <= 3; i++) {
        const nextQ = practiceQuestions[practiceCurrentIndex + i];
        if (nextQ && nextQ.image_path && window.globalImageCache && !window.globalImageCache.has(nextQ.image_path)) {
            const img = new Image();
            img.src = nextQ.image_path;
            window.globalImageCache.set(nextQ.image_path, img);
        }
    }

    // Question Text
    document.getElementById('practice-question-text').innerHTML = cleanQuestionText(question);
    
    // Answers Grid
    const answersGrid = document.getElementById('practice-answers-grid');
    answersGrid.innerHTML = '';
    
    const parsedOptions = parseQuestionOptions(question);
    
    if (parsedOptions[0] && parsedOptions[0].key === '__numeric__') {
        // Render text input for numeric questions
        const numericDiv = document.createElement('div');
        numericDiv.style.width = '100%';
        numericDiv.style.display = 'flex';
        numericDiv.style.gap = '12px';
        numericDiv.innerHTML = `
            <input type="number" id="practice-numeric-input" class="form-control" placeholder="Enter numeric answer (e.g. 50, 70, 120)" style="flex: 1;">
            <button class="btn btn-primary" id="btn-submit-practice-numeric">Submit</button>
        `;
        answersGrid.appendChild(numericDiv);
        
        const input = document.getElementById('practice-numeric-input');
        const submitBtn = document.getElementById('btn-submit-practice-numeric');
        
        const submitAction = () => {
            const val = input.value.trim();
            if (!val) {
                alert("Please enter a number.");
                return;
            }
            handlePracticeAnswer(val, null);
        };
        
        submitBtn.addEventListener('click', submitAction);
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                submitAction();
            }
        });
        
        // Auto-focus input
        setTimeout(() => input.focus(), 100);
    } else {
        // Render option buttons
        parsedOptions.forEach(opt => {
            const optBtn = document.createElement('div');
            optBtn.className = 'answer-option';
            optBtn.innerHTML = `
                <div class="answer-option-indicator">${opt.key.toUpperCase()}</div>
                <span>${opt.text}</span>
            `;
            optBtn.addEventListener('click', () => handlePracticeAnswer(opt.key, optBtn));
            answersGrid.appendChild(optBtn);
        });
    }

    // Hide feedback panel
    document.getElementById('practice-feedback-panel').style.display = 'none';
}

function handlePracticeAnswer(selectedKey, element) {
    // Block multiple clicks
    if (practiceSelectedAnswer !== null) return;
    practiceSelectedAnswer = selectedKey;

    const question = practiceQuestions[practiceCurrentIndex];
    const correctKey = question.correct_option.trim().toLowerCase();
    const isCorrect = (selectedKey.toLowerCase() === correctKey);
    
    if (element) {
        // Mark choices for multiple choice
        const allOptions = document.querySelectorAll('#practice-answers-grid .answer-option');
        allOptions.forEach((opt, idx) => {
            const currentKey = parseQuestionOptions(question)[idx].key;
            if (currentKey === correctKey) {
                opt.classList.add('correct');
            } else if (currentKey === selectedKey) {
                opt.classList.add('wrong');
            }
        });
    } else {
        // For numeric input, show user entry status in the input field
        const input = document.getElementById('practice-numeric-input');
        if (input) {
            input.disabled = true;
            if (isCorrect) {
                input.style.borderColor = 'var(--success)';
                input.style.backgroundColor = 'var(--success-light)';
                input.style.color = 'var(--success)';
            } else {
                input.style.borderColor = 'var(--danger)';
                input.style.backgroundColor = 'var(--danger-light)';
                input.style.color = 'var(--danger)';
                
                // Show correct value
                const hint = document.createElement('div');
                hint.style.marginTop = '8px';
                hint.style.fontWeight = '600';
                hint.style.color = 'var(--success)';
                hint.innerHTML = `<i class="fa-solid fa-circle-check"></i> Correct Answer: ${question.correct_option}`;
                input.parentElement.appendChild(hint);
            }
        }
    }

    // Display Feedback Panel
    const feedbackPanel = document.getElementById('practice-feedback-panel');
    const feedbackIcon = document.getElementById('feedback-icon');
    const statusText = document.getElementById('feedback-status-text');
    const explanationText = document.getElementById('practice-explanation-text');
    
    if (isCorrect) {
        feedbackIcon.className = 'fa-solid fa-circle-check status-correct';
        statusText.textContent = 'Correct!';
        statusText.className = 'status-correct';
    } else {
        feedbackIcon.className = 'fa-solid fa-circle-xmark status-wrong';
        statusText.textContent = 'Incorrect';
        statusText.className = 'status-wrong';
    }

    explanationText.innerHTML = question.explanation_raw || question.explanation_text;
    
    // Check if we can extract a lesson link
    const lessonNum = extractLessonNum(question.explanation_text) || getLessonNumberFromChapterIndex(getChapterIndexFromLessonNumber(parseInt(question.lesson_name.replace('booklesson', ''))));
    const studyBtn = document.getElementById('btn-feedback-study');
    if (lessonNum) {
        studyBtn.style.display = 'inline-flex';
        studyBtn.dataset.lessonNum = lessonNum;
    } else {
        studyBtn.style.display = 'none';
    }
    
    feedbackPanel.style.display = 'block';
    
    // Smooth scroll feedback panel into view
    feedbackPanel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function nextPracticeQuestion() {
    practiceCurrentIndex++;
    if (practiceCurrentIndex >= practiceQuestions.length) {
        alert("Topic practice completed! Returning to topics menu.");
        exitPracticeSession();
    } else {
        showPracticeQuestion();
    }
}

function redirectToTheory() {
    const studyBtn = document.getElementById('btn-feedback-study');
    const lessonNum = parseInt(studyBtn.dataset.lessonNum);
    
    if (lessonNum) {
        // Resolve target index
        // Lesson 1 is index 2, Lesson 2 is index 3, etc.
        let targetIndex = null;
        if (lessonNum === 1) targetIndex = 2;
        else if (lessonNum >= 2 && lessonNum <= 14) targetIndex = lessonNum + 1;
        else if (lessonNum === 15 || lessonNum === 16) targetIndex = 16;
        else if (lessonNum >= 17) targetIndex = lessonNum + 1;
        
        if (targetIndex !== null && window.showTheoryChapter) {
            window.showTheoryChapter(targetIndex);
            window.location.hash = '#theory';
        }
    }
}

/* ==========================================
   OFFICIAL MOCK EXAM LOGIC
   ========================================== */
function startExamSession() {
    // Official Exam selection rules:
    // We select 50 questions total.
    // To ensure a realistic Belgium exam experience, we select:
    // - 10 Major Offences (weight = "5")
    // - 40 Standard Questions (weight = "1")
    
    // Read the user-defined timer duration from index.html select
    const durationSelect = document.getElementById('exam-timer-select');
    examTimerDuration = durationSelect ? parseInt(durationSelect.value) : 15;
    
    const allQuestions = window.appData.questions;
    
    const majorPool = allQuestions.filter(q => q.weight === '5');
    const standardPool = allQuestions.filter(q => q.weight === '1');
    
    if (majorPool.length < 10 || standardPool.length < 40) {
        // Fallback if not enough questions in pool
        console.warn('Insufficient balanced questions pools, falling back to random sampling');
        shuffle(allQuestions);
        examQuestions = allQuestions.slice(0, 50);
    } else {
        shuffle(majorPool);
        shuffle(standardPool);
        examQuestions = [
            ...majorPool.slice(0, 10),
            ...standardPool.slice(0, 40)
        ];
        shuffle(examQuestions); // Shuffle again to interleave them
    }

    // Instantly preload images for all 50 exam questions into memory/cache
    if (window.preloadQuestionImages) {
        window.preloadQuestionImages(examQuestions);
    }

    examCurrentIndex = 0;
    examAnswers = [];
    
    document.getElementById('exam-setup-card').style.display = 'none';
    document.getElementById('exam-results-container').style.display = 'none';
    document.getElementById('exam-session-container').style.display = 'block';
    
    showExamQuestion();
}

function showExamQuestion() {
    if (examCurrentIndex >= 50) {
        finishExam();
        return;
    }

    const question = examQuestions[examCurrentIndex];
    
    // UI update
    document.getElementById('exam-badge-index').textContent = `Question ${examCurrentIndex + 1} of 50`;
    
    // Image handling
    const imgWrapper = document.getElementById('exam-image-wrapper');
    const imgEl = document.getElementById('exam-question-image');
    if (question.image_path) {
        imgEl.loading = 'eager';
        imgEl.src = question.image_path;
        imgWrapper.style.display = 'flex';
    } else {
        imgWrapper.style.display = 'none';
    }

    // Prefetch next 3 exam question images for zero latency transitions
    for (let i = 1; i <= 3; i++) {
        const nextQ = examQuestions[examCurrentIndex + i];
        if (nextQ && nextQ.image_path && window.globalImageCache && !window.globalImageCache.has(nextQ.image_path)) {
            const img = new Image();
            img.src = nextQ.image_path;
            window.globalImageCache.set(nextQ.image_path, img);
        }
    }

    // Question Text - use innerHTML to support embedded HTML tags (like 5 points question weight pill)
    document.getElementById('exam-question-text').innerHTML = cleanQuestionText(question);
    
    // Answers Grid
    const answersGrid = document.getElementById('exam-answers-grid');
    answersGrid.innerHTML = '';
    
    const parsedOptions = parseQuestionOptions(question);
    
    if (parsedOptions[0] && parsedOptions[0].key === '__numeric__') {
        // Render text input for numeric questions in exam mode
        const numericDiv = document.createElement('div');
        numericDiv.style.width = '100%';
        numericDiv.style.display = 'flex';
        numericDiv.style.gap = '12px';
        numericDiv.innerHTML = `
            <input type="number" id="exam-numeric-input" class="form-control" placeholder="Enter numeric answer (e.g. 50, 70, 120)" style="flex: 1;" autocomplete="off">
            <button class="btn btn-primary" id="btn-submit-exam-numeric">Submit</button>
        `;
        answersGrid.appendChild(numericDiv);
        
        const input = document.getElementById('exam-numeric-input');
        const submitBtn = document.getElementById('btn-submit-exam-numeric');
        
        const submitAction = () => {
            const val = input.value.trim();
            if (!val) {
                alert("Please enter a number.");
                return;
            }
            submitExamAnswer(val);
        };
        
        submitBtn.addEventListener('click', submitAction);
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                submitAction();
            }
        });
        
        // Auto-focus input
        setTimeout(() => input.focus(), 100);
    } else {
        // Render option buttons
        parsedOptions.forEach(opt => {
            const optBtn = document.createElement('div');
            optBtn.className = 'answer-option';
            optBtn.innerHTML = `
                <div class="answer-option-indicator">${opt.key.toUpperCase()}</div>
                <span>${opt.text}</span>
            `;
            optBtn.addEventListener('click', () => submitExamAnswer(opt.key));
            answersGrid.appendChild(optBtn);
        });
    }

    // Start timer countdown
    startTimer();
}

function startTimer() {
    clearInterval(examTimer);
    
    const timerText = document.getElementById('exam-timer-seconds');
    const timerBar = document.getElementById('exam-timer-bar');
    
    // If untimed (e.g., duration value >= 900000)
    if (examTimerDuration > 90000) {
        if (timerText) timerText.parentElement.style.visibility = 'hidden';
        if (timerBar) timerBar.parentElement.style.display = 'none';
        return; // Exit without setting interval
    } else {
        if (timerText) timerText.parentElement.style.visibility = 'visible';
        if (timerBar) timerBar.parentElement.style.display = 'block';
    }
    
    examTimeLeft = examTimerDuration;
    timerText.textContent = examTimeLeft;
    timerBar.style.transition = 'none';
    timerBar.style.width = '100%';
    
    // Force browser reflow to apply widths
    timerBar.offsetHeight;
    
    // Apply dynamic transition based on set duration
    timerBar.style.transition = `width ${examTimerDuration}s linear`;
    timerBar.style.width = '0%';
    
    examTimer = setInterval(() => {
        examTimeLeft--;
        timerText.textContent = examTimeLeft;
        
        if (examTimeLeft <= 0) {
            clearInterval(examTimer);
            // Automatic timeout -> submits null choice (wrong)
            submitExamAnswer(null);
        }
    }, 1000);
}

function submitExamAnswer(selectedKey) {
    clearInterval(examTimer);
    
    const question = examQuestions[examCurrentIndex];
    const correctKey = question.correct_option.toLowerCase();
    
    const isCorrect = (selectedKey !== null && selectedKey === correctKey);
    
    examAnswers.push({
        question: question,
        selectedKey: selectedKey,
        correctKey: correctKey,
        isCorrect: isCorrect,
        weight: parseInt(question.weight) || 1
    });

    // Animate transition briefly (0.2s)
    setTimeout(() => {
        examCurrentIndex++;
        showExamQuestion();
    }, 200);
}

function finishExam() {
    document.getElementById('exam-session-container').style.display = 'none';
    
    // Calculations:
    // Total score starts at 50.
    // Each standard mistake (weight 1) deducts 1 point.
    // Each major mistake (weight 5) deducts 5 points.
    let score = 50;
    let majorMistakes = 0;
    let minorMistakes = 0;
    let correctCount = 0;

    examAnswers.forEach(ans => {
        if (ans.isCorrect) {
            correctCount++;
        } else {
            if (ans.weight === 5) {
                score -= 5;
                majorMistakes++;
            } else {
                score -= 1;
                minorMistakes++;
            }
        }
    });

    // Score floor is 0
    score = Math.max(0, score);
    const passed = (score >= 41);

    // Sync stats
    window.recordExamResult(score, passed);

    // Update Results UI Banner
    const banner = document.getElementById('results-banner');
    const statusIcon = document.getElementById('results-status-icon');
    const scoreHeading = document.getElementById('results-score-heading');
    const statusSubheading = document.getElementById('results-status-subheading');

    scoreHeading.textContent = `${score} / 50 Points`;
    
    if (passed) {
        banner.className = 'results-header-card pass';
        statusIcon.innerHTML = '<i class="fa-solid fa-circle-check"></i>';
        statusSubheading.textContent = 'Congratulations! You passed the Belgium Mock Exam.';
    } else {
        banner.className = 'results-header-card fail';
        statusIcon.innerHTML = '<i class="fa-solid fa-circle-xmark"></i>';
        if (majorMistakes >= 2) {
            statusSubheading.textContent = `Failed: You committed ${majorMistakes} Major Offences (which deduct 5 points each).`;
        } else {
            statusSubheading.textContent = 'Failed: You scored below the 41/50 passing limit.';
        }
    }

    // Stats breakdown numbers
    document.getElementById('results-total-correct').textContent = correctCount;
    document.getElementById('results-total-major-mistakes').textContent = majorMistakes;
    document.getElementById('results-total-minor-mistakes').textContent = minorMistakes;

    // Filters counts labels
    document.getElementById('count-all').textContent = 50;
    document.getElementById('count-wrong').textContent = 50 - correctCount;
    document.getElementById('count-major').textContent = examAnswers.filter(ans => ans.weight === 5).length;

    // Populate Detailed Review List
    renderResultsReviewList();

    document.getElementById('exam-results-container').style.display = 'block';
    
    // Scroll results into view
    document.getElementById('exam-results-container').scrollIntoView({ behavior: 'smooth' });
}

function renderResultsReviewList() {
    const listContainer = document.getElementById('results-review-list');
    listContainer.innerHTML = '';

    examAnswers.forEach((ans, index) => {
        const q = ans.question;
        const parsedOpts = parseQuestionOptions(q);
        
        let userLabel = 'No Answer (Timeout)';
        if (ans.selectedKey) {
            const sk = ans.selectedKey.toLowerCase();
            if (sk === 'yes' || sk === 'no') {
                userLabel = sk.toUpperCase();
            } else if (parsedOpts[0] && parsedOpts[0].key === '__numeric__') {
                userLabel = ans.selectedKey;
            } else {
                const optObj = parsedOpts.find(o => o.key.toLowerCase() === sk);
                const text = optObj ? optObj.text : ans.selectedKey;
                userLabel = `${ans.selectedKey.toUpperCase()}. ${text}`;
            }
        }

        let correctLabel = '';
        const ck = ans.correctKey.toLowerCase();
        if (ck === 'yes' || ck === 'no') {
            correctLabel = ck.toUpperCase();
        } else if (parsedOpts[0] && parsedOpts[0].key === '__numeric__') {
            correctLabel = ans.correctKey;
        } else {
            const optObj = parsedOpts.find(o => o.key.toLowerCase() === ck);
            const text = optObj ? optObj.text : ans.correctKey;
            correctLabel = `${ans.correctKey.toUpperCase()}. ${text}`;
        }

        const item = document.createElement('div');
        item.className = `review-item ${ans.isCorrect ? 'correct-item' : 'wrong-item'}`;
        item.dataset.isCorrect = ans.isCorrect;
        item.dataset.weight = ans.weight;
        
        let weightBadge = '';
        if (ans.weight === 5) {
            weightBadge = '<span class="badge badge-danger review-verdict-badge"><i class="fa-solid fa-triangle-exclamation"></i> Major Offence (-5pt)</span>';
        } else {
            weightBadge = '<span class="badge badge-secondary review-verdict-badge">Standard Question (-1pt)</span>';
        }

        const verdictBadge = ans.isCorrect 
            ? '<span class="badge badge-info review-verdict-badge"><i class="fa-solid fa-check"></i> Correct</span>'
            : '<span class="badge badge-danger review-verdict-badge"><i class="fa-solid fa-xmark"></i> Incorrect</span>';

        // Image template if any
        let imgHtml = '';
        if (q.image_path) {
            imgHtml = `<img src="${q.image_path}" class="review-image" alt="Question Image">`;
        } else {
            imgHtml = `<div class="review-image" style="display:flex; align-items:center; justify-content:center; color:var(--text-tertiary); font-size:24px;"><i class="fa-solid fa-image-slash"></i></div>`;
        }

        item.innerHTML = `
            ${imgHtml}
            <div class="review-details">
                <div style="display:flex; gap: 8px; flex-wrap: wrap;">
                    ${verdictBadge}
                    ${weightBadge}
                </div>
                <h4 class="review-question-text">Question ${index + 1}: ${cleanQuestionText(q)}</h4>
                
                <div class="review-answers-compare">
                    <div class="compare-row">
                        <span class="compare-label">Your Answer:</span>
                        <span class="${ans.isCorrect ? 'text-green' : 'text-danger'}" style="font-weight:600;">${userLabel}</span>
                    </div>
                    <div class="compare-row">
                        <span class="compare-label">Correct Answer:</span>
                        <span class="text-green" style="font-weight:600;">${correctLabel}</span>
                    </div>
                </div>
                
                <div class="review-explanation-box">
                    <strong>Explanation:</strong><br>
                    ${q.explanation_raw || q.explanation_text}
                </div>
            </div>
        `;

        listContainer.appendChild(item);
    });
}

function filterResults(filterType) {
    // Toggle active filter tabs
    document.querySelectorAll('.results-filter-tabs .filter-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    
    document.getElementById(`btn-filter-${filterType}`).classList.add('active');

    const items = document.querySelectorAll('#results-review-list .review-item');
    items.forEach(item => {
        const isCorrect = item.dataset.isCorrect === 'true';
        const weight = parseInt(item.dataset.weight);

        if (filterType === 'all') {
            item.style.display = 'grid';
        } else if (filterType === 'wrong') {
            item.style.display = !isCorrect ? 'grid' : 'none';
        } else if (filterType === 'major') {
            item.style.display = weight === 5 ? 'grid' : 'none';
        }
    });
}
