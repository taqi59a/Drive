// Global App State
window.appData = null;
window.userStats = {
    examsTaken: 0,
    passedExams: 0,
    bestScore: null,
    lessonsRead: [],
    history: [],
    streak: 0,
    lastActiveDate: null
};

// Access Code Configuration (Keygen Salt matching the Admin Tool)
const SECRET_SALT = "9Xk#2mPq!7vR$nL4wZ@5jBt8Ue6*Gy3F";

document.addEventListener('DOMContentLoaded', () => {
    initAccessLock();
    initTheme();
    loadStats();
    loadAppData();
    setupRouting();
    setupMobileMenu();
});

// Crypto SHA-256 generator matching keygen
async function computeSHA256(text) {
    const encoder = new TextEncoder();
    const data = encoder.encode(text);
    const hashBuffer = await crypto.subtle.digest("SHA-256", data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, "0")).join("");
}

async function initAccessLock() {
    const lockScreen = document.getElementById('access-lock-screen');
    const input = document.getElementById('access-code-input');
    const unlockBtn = document.getElementById('btn-unlock-app');
    const errorMsg = document.getElementById('lock-error-msg');
    const card = document.getElementById('lock-card-box');
    const midDisplay = document.getElementById('display-machine-id');
    
    // Generate or load stable Machine ID (8-char hex)
    let machineId = localStorage.getItem('app_machine_id');
    if (!machineId) {
        machineId = Array.from({ length: 8 }, () => 
            "0123456789ABCDEF"[Math.floor(Math.random() * 16)]
        ).join("");
        localStorage.setItem('app_machine_id', machineId);
    }
    
    // Display Machine ID on lock screen
    if (midDisplay) {
        midDisplay.textContent = machineId;
    }
    
    // Check if already authenticated
    if (localStorage.getItem('app_unlocked') === 'true') {
        lockScreen.classList.add('hidden');
        return;
    }
    
    // Calculate expected key: SHA-256(machineId + SECRET_SALT)[:12].toUpperCase()
    const rawPayload = machineId + SECRET_SALT;
    const hashHex = await computeSHA256(rawPayload);
    const expectedKey = hashHex.substring(0, 12).toUpperCase();
    
    const handleUnlock = () => {
        const val = input.value.trim().toUpperCase();
        if (val === expectedKey) {
            localStorage.setItem('app_unlocked', 'true');
            lockScreen.classList.add('hidden');
        } else {
            // Incorrect passcode -> shake animation + error message
            card.classList.remove('shake');
            void card.offsetWidth; // Reflow to restart CSS keyframe animation
            card.classList.add('shake');
            errorMsg.style.display = 'block';
            input.value = '';
            input.focus();
        }
    };
    
    unlockBtn.addEventListener('click', handleUnlock);
    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            handleUnlock();
        }
    });
    
    // Focus input field on start
    setTimeout(() => input.focus(), 150);
}

// 1. Dark/Light Theme Control
function initTheme() {
    const themeBtn = document.getElementById('theme-toggle-btn');
    const savedTheme = localStorage.getItem('theme') || 'light';
    
    if (savedTheme === 'dark') {
        document.body.classList.add('dark-theme');
        updateThemeUI(true);
    } else {
        updateThemeUI(false);
    }
    
    themeBtn.addEventListener('click', () => {
        const isDark = document.body.classList.toggle('dark-theme');
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
        updateThemeUI(isDark);
    });
}

function updateThemeUI(isDark) {
    const themeBtn = document.getElementById('theme-toggle-btn');
    const icon = themeBtn.querySelector('i');
    const label = themeBtn.querySelector('span');
    
    if (isDark) {
        icon.className = 'fa-solid fa-sun';
        label.textContent = 'Light Mode';
    } else {
        icon.className = 'fa-solid fa-moon';
        label.textContent = 'Dark Mode';
    }
}

// 2. Load User Stats from LocalStorage
function loadStats() {
    const savedStats = localStorage.getItem('userStats');
    if (savedStats) {
        try {
            window.userStats = JSON.parse(savedStats);
        } catch (e) {
            console.error('Failed to parse user stats, resetting', e);
        }
    }
    
    // Day Streak calculation
    updateStreak();
    updateDashboardUI();
}

function saveStats() {
    localStorage.setItem('userStats', JSON.stringify(window.userStats));
    updateDashboardUI();
}

function updateStreak() {
    const todayStr = new Date().toDateString();
    if (!window.userStats.lastActiveDate) {
        window.userStats.streak = 1;
        window.userStats.lastActiveDate = todayStr;
        return;
    }
    
    const lastDate = new Date(window.userStats.lastActiveDate);
    const today = new Date(todayStr);
    const diffTime = Math.abs(today - lastDate);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 1) {
        window.userStats.streak += 1;
        window.userStats.lastActiveDate = todayStr;
    } else if (diffDays > 1) {
        window.userStats.streak = 1;
        window.userStats.lastActiveDate = todayStr;
    }
}

function updateDashboardUI() {
    document.getElementById('stat-exams-taken').textContent = window.userStats.examsTaken;
    
    const passRate = window.userStats.examsTaken > 0 
        ? Math.round((window.userStats.passedExams / window.userStats.examsTaken) * 100) 
        : 0;
    document.getElementById('stat-pass-rate').textContent = `${passRate}%`;
    
    const lessonsCount = window.userStats.lessonsRead ? window.userStats.lessonsRead.length : 0;
    document.getElementById('stat-chapters-read').textContent = `${lessonsCount} / 32`;
    
    document.getElementById('stat-streak').textContent = window.userStats.streak;
    
    const quickScoreSpan = document.getElementById('quick-score');
    if (window.userStats.bestScore !== null) {
        quickScoreSpan.textContent = `Best: ${window.userStats.bestScore}/50`;
    } else {
        quickScoreSpan.textContent = 'Best: --';
    }
    
    // Populate recent activity list
    const recentList = document.getElementById('recent-list');
    recentList.innerHTML = '';
    
    if (!window.userStats.history || window.userStats.history.length === 0) {
        recentList.innerHTML = `
            <div class="empty-state">
                <i class="fa-solid fa-history"></i>
                <p>No exams taken yet. Start practicing to see your history here!</p>
            </div>
        `;
        return;
    }
    
    // Show last 5 activities
    window.userStats.history.slice(-5).reverse().forEach(item => {
        const date = new Date(item.date).toLocaleDateString();
        const passClass = item.passed ? 'score-pass' : 'score-fail';
        const passText = item.passed ? 'Passed' : 'Failed';
        
        const activityItem = document.createElement('div');
        activityItem.className = 'activity-item';
        activityItem.innerHTML = `
            <div class="activity-info">
                <span class="activity-title">${item.type === 'exam' ? 'Belgium Official Mock' : 'Practice Test'}</span>
                <span class="activity-date">${date}</span>
            </div>
            <div class="activity-score ${passClass}">
                ${item.score}/50 (${passText})
            </div>
        `;
        recentList.appendChild(activityItem);
    });
}

// Record an exam completion
window.recordExamResult = function(score, passed) {
    window.userStats.examsTaken += 1;
    if (passed) {
        window.userStats.passedExams += 1;
    }
    if (window.userStats.bestScore === null || score > window.userStats.bestScore) {
        window.userStats.bestScore = score;
    }
    
    window.userStats.history.push({
        type: 'exam',
        score: score,
        passed: passed,
        date: new Date().toISOString()
    });
    
    saveStats();
};

// 3. Image Caching & Load App Data
window.globalImageCache = new Map();

window.preloadQuestionImages = function(questionsList) {
    if (!questionsList || !questionsList.length) return;
    questionsList.forEach(q => {
        if (q.image_path && !window.globalImageCache.has(q.image_path)) {
            const img = new Image();
            img.src = q.image_path;
            window.globalImageCache.set(q.image_path, img);
        }
    });
};

function preloadAllDatabaseImages() {
    if (!window.appData || !window.appData.questions) return;
    const questions = window.appData.questions;
    let idx = 0;
    
    function processChunk() {
        const chunkSize = 30;
        const end = Math.min(idx + chunkSize, questions.length);
        for (let i = idx; i < end; i++) {
            const path = questions[i].image_path;
            if (path && !window.globalImageCache.has(path)) {
                const img = new Image();
                img.src = path;
                window.globalImageCache.set(path, img);
            }
        }
        idx = end;
        if (idx < questions.length) {
            if ('requestIdleCallback' in window) {
                requestIdleCallback(processChunk);
            } else {
                setTimeout(processChunk, 80);
            }
        }
    }
    
    setTimeout(processChunk, 300);
}

async function loadAppData() {
    try {
        const response = await fetch('data/data.json?v=' + new Date().getTime());
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        window.appData = await response.json();
        
        // Data is ready, initialize modules
        initTheoryModule();
        initPracticeSetup();
        
        // Start background preloading of images for instant display
        preloadAllDatabaseImages();
        
        // Notify exam module (if it exists/loads later)
        if (window.onAppDataLoaded) {
            window.onAppDataLoaded();
        }
    } catch (e) {
        console.error('Error loading data.json:', e);
        document.getElementById('theory-chapter-body').innerHTML = `
            <div class="empty-state text-danger">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <p>Failed to load database. Please make sure data/data.json exists on your host server.</p>
            </div>
        `;
    }
}

// 4. Client-side SPA Router
function setupRouting() {
    const menuItems = document.querySelectorAll('.sidebar-menu a, .sidebar-footer a');
    const sections = document.querySelectorAll('.view-section');
    const headerTitle = document.getElementById('page-header-title');
    
    function route() {
        const hash = window.location.hash || '#home';
        
        // Update active menu link
        menuItems.forEach(item => {
            if (item.getAttribute('href') === hash) {
                item.classList.add('active');
            } else {
                item.classList.remove('active');
            }
        });
        
        // Show correct view section
        sections.forEach(section => {
            if (`#${section.id.replace('view-', '')}` === hash) {
                section.classList.add('active-view');
            } else {
                section.classList.remove('active-view');
            }
        });
        
        // Set page header title
        let title = 'Dashboard';
        switch (hash) {
            case '#theory':
                title = 'Theory Lessons';
                break;
            case '#practice':
                title = 'Practice Mode';
                break;
            case '#exam':
                title = 'Belgium Mock Exam';
                break;
            case '#legal':
                title = 'Legal Disclaimer';
                break;
        }
        headerTitle.textContent = title;
        
        // Close mobile menu on navigate
        document.querySelector('.app-sidebar').classList.remove('mobile-open');
    }
    
    window.addEventListener('hashchange', route);
    route(); // Run on initial load
}

function setupMobileMenu() {
    const trigger = document.getElementById('mobile-menu-trigger');
    const sidebar = document.querySelector('.app-sidebar');
    
    trigger.addEventListener('click', (e) => {
        e.stopPropagation();
        sidebar.classList.toggle('mobile-open');
    });
    
    document.addEventListener('click', () => {
        sidebar.classList.remove('mobile-open');
    });
    
    sidebar.addEventListener('click', (e) => {
        e.stopPropagation();
    });
}

// 5. Theory Lessons Module
let currentActiveChapterIndex = null;

function initTheoryModule() {
    const chaptersMenu = document.getElementById('chapters-menu');
    const searchInput = document.getElementById('theory-search-input');
    const practiceBtn = document.getElementById('btn-practice-this-lesson');
    
    renderChaptersList();
    
    // Search filter trigger
    searchInput.addEventListener('input', () => {
        renderChaptersList(searchInput.value);
    });
    
    // Practice lesson trigger
    practiceBtn.addEventListener('click', () => {
        if (currentActiveChapterIndex !== null) {
            // Map index to practice topic select
            const select = document.getElementById('practice-topic-select');
            
            // Map theory chapter index to practice value.
            // Lesson 1 is at index 2. Let's find option with index.
            const lessonNum = getLessonNumberFromChapterIndex(currentActiveChapterIndex);
            if (lessonNum !== null) {
                select.value = `booklesson${lessonNum}`;
                window.location.hash = '#practice';
                document.getElementById('btn-start-practice').click();
            } else {
                // If it's a general introduction chapter, practice all
                select.value = 'all';
                window.location.hash = '#practice';
                document.getElementById('btn-start-practice').click();
            }
        }
    });
}

function getLessonNumberFromChapterIndex(idx) {
    if (idx === 2) return 1; // ROAD OR CARRIAGEWAY -> booklesson1
    if (idx >= 3 && idx <= 15) {
        return idx - 1; // THE LANES at index 3 -> booklesson2, ..., CROSSING at index 15 -> booklesson14
    }
    if (idx === 16 || idx === 17) {
        return 16; // booklesson16 handles both OVERTAKING ON THE LEFT (15) and OVERTAKING ON THE LEFT PROHIBITED (16)
    }
    if (idx >= 18) {
        return idx - 1; // booklesson17 at index 18, etc.
    }
    return null;
}

function getChapterIndexFromLessonNumber(lessonNum) {
    if (lessonNum === 1) return 2;
    if (lessonNum >= 2 && lessonNum <= 14) return lessonNum + 1;
    if (lessonNum === 15 || lessonNum === 16) return 16; // Map both to "Overtaking on the left"
    if (lessonNum >= 17) return lessonNum + 1;
    return null;
}

function renderChaptersList(query = '') {
    const chaptersMenu = document.getElementById('chapters-menu');
    chaptersMenu.innerHTML = '';
    
    window.appData.theory.forEach((chapter, index) => {
        const title = chapter.title.toUpperCase();
        const text = chapter.content_text.toLowerCase();
        const q = query.toLowerCase();
        
        // Filter search query
        if (query && !title.includes(q) && !text.includes(q)) {
            return;
        }
        
        const item = document.createElement('div');
        item.className = 'chapter-item';
        if (index === currentActiveChapterIndex) {
            item.classList.add('active');
        }
        
        // Set label based on lesson order
        let lessonLabel = '';
        if (index === 0) {
            lessonLabel = 'Intro';
        } else if (index === 1) {
            lessonLabel = 'Prelim';
        } else {
            const lessonNum = getLessonNumberFromChapterIndex(index);
            lessonLabel = lessonNum ? `Lesson ${lessonNum}` : 'Info';
        }
        
        item.innerHTML = `
            <span class="chapter-number-badge">${lessonLabel}</span>
            <span>${chapter.title}</span>
        `;
        
        item.addEventListener('click', () => {
            showTheoryChapter(index);
        });
        
        chaptersMenu.appendChild(item);
    });
}

window.showTheoryChapter = function(index) {
    currentActiveChapterIndex = index;
    
    // Highlight in list
    const items = document.querySelectorAll('.chapter-item');
    // Re-render list to ensure query is preserved or just adjust classes
    document.querySelectorAll('.chapter-item').forEach((item, idx) => {
        // Need to resolve index dynamically because search filtering might change DOM index
    });
    
    // Re-render to easily keep active class synced
    const searchVal = document.getElementById('theory-search-input').value;
    renderChaptersList(searchVal);
    
    const chapter = window.appData.theory[index];
    document.getElementById('theory-chapter-title').textContent = chapter.title;
    document.getElementById('theory-chapter-body').innerHTML = chapter.content_html;
    
    // Show practice button for lessons that have questions
    const practiceBtn = document.getElementById('btn-practice-this-lesson');
    const lessonNum = getLessonNumberFromChapterIndex(index);
    if (lessonNum !== null) {
        practiceBtn.style.display = 'inline-flex';
    } else {
        practiceBtn.style.display = 'none';
    }
    
    // Mark as studied
    if (!window.userStats.lessonsRead.includes(index)) {
        window.userStats.lessonsRead.push(index);
        saveStats();
    }
    
    // Scroll theory body to top
    document.getElementById('theory-chapter-body').scrollTop = 0;
};

// 6. Practice Module Setup Options
function initPracticeSetup() {
    const select = document.getElementById('practice-topic-select');
    
    // Add topics dynamically based on lessons
    // We already have booklesson1 through booklesson31 (with booklesson15 missing)
    window.appData.theory.forEach((chapter, index) => {
        const lessonNum = getLessonNumberFromChapterIndex(index);
        if (lessonNum !== null) {
            // Check if option already exists (e.g. for booklesson16 which matches multiple indexes)
            const optionValue = `booklesson${lessonNum}`;
            if (!select.querySelector(`option[value="${optionValue}"]`)) {
                const option = document.createElement('option');
                option.value = optionValue;
                option.textContent = `Lesson ${lessonNum}: ${chapter.title}`;
                select.appendChild(option);
            }
        }
    });
}
