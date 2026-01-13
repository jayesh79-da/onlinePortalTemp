<%@ page import="com.onlineexamportal.model.User" %>
<%@ page import="com.onlineexamportal.model.Exam" %>
<%@ page import="com.onlineexamportal.model.Question" %>
<%@ page import="com.onlineexamportal.util.ActiveUserStore" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
// PREVENT BACK BUTTON CACHE
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect("login.jsp");
    return;
}

Exam exam = (Exam) request.getAttribute("exam");
List<Question> questions = (List<Question>) request.getAttribute("questions");

if (exam == null || questions == null) {
    response.sendRedirect("dashboard.jsp");
    return;
}


Boolean started = (Boolean) session.getAttribute("examStarted_" + exam.getId());
        if (started == null) {
        response.sendRedirect("instructions.jsp?examId="+exam.getId());
        return;
    }



    Boolean completed = (Boolean) session.getAttribute("examCompleted_" + exam.getId());
    if (completed != null && completed) {
        response.sendRedirect("result.jsp?examId=" +exam.getId());
        return;
    }

    long durationSeconds = exam.getDuration() * 60L;
%>
<%
  
    boolean takeover = false;
    if(user != null) {
        takeover = ActiveUserStore.isTakeoverRequested(user.getId());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Exam: <%= exam.getName() %></title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="online-test.png" type="image/png">
<style>
/* ===== RESET ===== */
* { margin:0; padding:0; box-sizing:border-box; font-family: "Segoe UI", Arial, sans-serif; }
body { background:#f4f6f9; height:100vh; overflow-x:hidden; overflow-y: auto;}

/* ===== FIXED EXAM HEADER ===== */
.exam-header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    background: #0a2a66;
    color: white;
    display: flex;
    align-items: center;
    padding: 10px 20px;
    z-index: 100;
    box-shadow: 0 2px 6px rgba(0,0,0,0.2);
}

.exam-header img {
    width: 50px;
    height: 50px;
    margin-right: 15px;
    border-radius: 4px;
}

.exam-header .exam-info h3,
.exam-header .exam-info p {
    margin: 0;
    line-height: 1.2;
}

/* ===== WRAPPER ===== */
.exam-wrapper { display:flex; height:calc(100vh-80px); margin-top: 80px; }

/* ===== EXAM BODY ===== */
.exam-container { flex:3; overflow-y:auto; padding:20px; margin-top:80px; } /* margin-top to avoid header overlap */
.question-card { display : none; background:#fff; padding:15px; margin-bottom:15px; border-radius:8px; box-shadow:0 2px 6px rgba(0,0,0,0.1); animation:fadeIn 0.3s ease; }
.question-card.active{ display:block; }
.question-card h4 { color:#0a2a66; margin-bottom:10px; }
.question-card label { display:block; padding:8px; border:1px solid #ddd; border-radius:5px; margin-bottom:8px; cursor:pointer; transition:0.2s; }
.question-card label:hover { background:#eef3ff; border-color:#0a2a66; }
@keyframes fadeIn { from {opacity:0; transform:translateY(5px);} to {opacity:1; transform:translateY(0);} }

/* ===== TIMER ===== */
.exam-timer { font-size:22px; font-weight:bold; color:red; text-align:center; margin-bottom:15px; }

/* ===== PALETTE ===== */
.palette { flex:1; padding:20px; background:#eef1f5; border-left:2px solid #ddd; overflow-y:auto; height: 100%; position: sticky; top: 80px; }
.palette h3 { margin-bottom:10px; color:#0a2a66; }
.palette-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(40px, 1fr));
    gap: 8px;
}

.palette-box { padding:10px; text-align:center; border-radius:4px; font-weight:bold; cursor:pointer; user-select:none; }
.attempted { background:#4CAF50; color:white; }
.unattempted { background:#f44336; color:white; }
.marked { background:purple; color:white; }
.answered-marked { background:#2196F3; color:white; }

/* ===== LEGEND ===== */
.legend { margin-top:20px; font-size:14px; }
.legend-box { display:inline-block; width:14px; height:14px; margin-right:6px; vertical-align:middle; }

/* ===== SUBMIT BUTTON ===== */
.submit-btn { margin-top:20px; padding:10px 18px; font-size:14px; background:#ff3b3b; color:white; border:none; border-radius:4px; cursor:pointer; font-weight:bold; }
.submit-btn:hover { background:#e62e2e; }

/* ===== WATERMARK ===== */
.watermark {
    position: fixed;
    bottom: 20px;
    right: 20px;
    font-size: 30px;
    color: rgba(0,0,0,0.1);
    pointer-events: none;
    z-index: 0;
    transform: rotate(-30deg);
    white-space: nowrap;
}
</style>
</head>

<body>
<div class="exam-wrapper">

    <!-- ===== EXAM HEADER ===== -->
    <div class="exam-header">
        <img src="online-test.png" alt="Exam Icon">
        <div class="exam-info">
            <h3>Exam: <%= exam.getName() %></h3>
            <p>User: <%= user.getName() %> | Exam ID: <%= exam.getId() %></p>
        </div>
    </div>

    <!-- ===== WATERMARK ===== -->
    <div class="watermark"><%= user.getName() %> | Exam ID: <%= exam.getId() %></div>

    <!-- ================== QUESTIONS ================== -->
    <div class="exam-container">
        <div class="exam-timer">⏱ <span id="timer"></span></div>

        <form id="examForm" method="post" action="exam">
            <input type="hidden" name="examId" value="<%= exam.getId() %>">

            <% int idx = 1; for(Question q : questions){ %>
            <div id="question-<%= idx %>" class="question-card <%=(idx==1) ? "active" : " " %>">
                <h4>Q<%= idx %>. <%= q.getQuestionText() %></h4>

                <label>
                    <input type="radio" name="q<%= q.getId() %>" value='<%= q.getOption1()!= null?q.getOption1():" " %>' onchange="markAttempted(<%= idx %>)">
                    <%= q.getOption1() %>
                </label>
                <label>
                    <input type="radio" name="q<%= q.getId() %>" value='<%= q.getOption2()!= null?q.getOption2():" " %>' onchange="markAttempted(<%= idx %>)">
                    <%= q.getOption2() %>
                </label>
                <label>
                    <input type="radio" name="q<%= q.getId() %>" value='<%= q.getOption3()!= null?q.getOption3():" " %>' onchange="markAttempted(<%= idx %>)">
                    <%= q.getOption3() %>
                </label>
                <label>
                    <input type="radio" name="q<%= q.getId() %>" value='<%= q.getOption4()!= null?q.getOption4():" " %>' onchange="markAttempted(<%= idx %>)">
                    <%= q.getOption4() %>
                </label>

                <button type="button" onclick="markForReview(<%= idx %>)" style="margin-top:5px;">Mark for Review</button>
                <!-- <button type="button" onclick="answerAndMark(<%= idx %>)" style="margin-top:5px;">Answer + Mark</button> -->
                <button type="button" onclick="unmarkAnswer(<%= idx %>)" style="margin-top:5px;"> Unmark</button>


                <div style="margin-top:8px;">
                    <button type="button" onclick="prevQuestion()">Previous</button>
                    <button type="button" onclick="nextQuestion()">Next</button>
                </div>
            </div>
            <% idx++; } %>

            <button type="submit" class="submit-btn"
                onclick="document.getElementById('finishSound').play();">
                Submit Exam
            </button>

        </form>
    </div>

    <!-- ================== PALETTE ================== -->
    <div class="palette">
        <h3>Question Palette</h3>
        <div style="text-align:right; margin-bottom:10px;">
    <img src="https://cdn-icons-png.flaticon.com/512/149/149071.png"
         style="width:40px;height:40px;border-radius:50%;border:2px solid #0a2a66;"
         title="<%= user.getName() %>">
    </div>

        <div class="palette-grid">
            <% for(int i=1;i<=questions.size();i++){ %>
                <div class="palette-box unattempted" id="palette-<%= i %>" onclick="scrollToQuestion(<%= i %>)">
                    <%= i %>
                </div>
            <% } %>
        </div>
        <div class="legend">
            <div><span class="legend-box attempted"></span> Attempted</div>
            <div><span class="legend-box unattempted"></span> Unattempted</div>
            <div><span class="legend-box marked"></span> Marked for Review</div>
            <!-- <div><span class="legend-box answered-marked"></span> Answered + Marked</div> -->
        </div>
    </div>
</div>

<script>
// ===== Disable Back Button & Refresh =====
history.pushState(null, null, location.href);
window.onpopstate = function(){ history.go(1); };
document.addEventListener("keydown", function(e){ if(e.key==="F5"||(e.ctrlKey && e.key==="r")) e.preventDefault(); });

// ===== Disable Copy/Paste =====
document.addEventListener('contextmenu', e=>e.preventDefault());
document.addEventListener('copy', e=>e.preventDefault());
document.addEventListener('paste', e=>e.preventDefault());
document.addEventListener('cut', e=>e.preventDefault());
document.addEventListener('selectstart', e=>e.preventDefault());


let timeLeft = <%= ((Long)request.getAttribute("remainingSeconds")).longValue() %>; 
let warningPlayed = false;

function startTimer(){
    const timerDisplay = document.getElementById("timer");
    const interval = setInterval(()=>{
        let min = Math.floor(timeLeft / 60);
        let sec = timeLeft % 60;
        timerDisplay.innerText = min + ":" + (sec < 10 ? "0" : "") + sec;

        // warning at last 5 min or 2 min
        if(timeLeft <= 300  && !warningPlayed){
            document.getElementById("warningSound").play();
            alert("⚠ Only few minutes left!");
            warningPlayed = true;
        }

        if(timeLeft <= 0){
            clearInterval(interval);
            document.getElementById("finishSound").play();
            document.getElementById("examForm").submit();
        }

        timeLeft--;
    }, 1000);
}
window.onload = startTimer;



// ===== PALETTE LOGIC =====
function markAttempted(qNo){ 
    const el=document.getElementById("palette-"+qNo);
    el.classList.remove("unattempted","marked","answered-marked");
    el.classList.add("attempted");
}
function markForReview(qNo){ 
    const el=document.getElementById("palette-"+qNo);
    el.classList.remove("unattempted","attempted","answered-marked");
    el.classList.add("marked");
}

let currentQuestion = 1;
const totalQuestions = <%= questions.size() %>;

function showQuestion(qNo){
    if(qNo < 1 || qNo > totalQuestions) return;
    
    document.querySelectorAll(".question-card").forEach(q => q.classList.remove("active"));
    document.getElementById("question-" + qNo).classList.add("active");
    currentQuestion = qNo;
}

function nextQuestion(){
    showQuestion(currentQuestion + 1);
}

function prevQuestion(){
    showQuestion(currentQuestion - 1);
}

function scrollToQuestion(qNo){
    showQuestion(qNo); // palette click support
}

function unmarkAnswer(qNo){
    // Find the question card
    const card = document.getElementById("question-" + qNo);

    // Uncheck all radios inside that card
    const radios = card.querySelectorAll("input[type='radio']");
    radios.forEach(r => r.checked = false);

    // Reset palette color
    const el = document.getElementById("palette-" + qNo);
    el.classList.remove("attempted","marked","answered-marked");
    el.classList.add("unattempted");
}




// ===== AUTO-SUBMIT ON TAB SWITCH =====
document.addEventListener("visibilitychange", function(){
    if(document.hidden){
        alert("Your exam will be submitted....");
        document.getElementById("finishSound").play();
        setTimeout(() => {
                document.getElementById("examForm").submit();
        }, 1500);

    }
});


/* ================= SCREENSHOT & CHEAT PROTECTION ================= */

let winKey = false;
let shiftKey = false;
let examSubmitted = false;

function submitExamSafely(reason) {
    if (examSubmitted) return;
    examSubmitted = true;

    alert(reason);
    document.body.style.filter = "blur(8px)";
    document.body.style.pointerEvents = "none";

    try {
        document.getElementById("finishSound").play();
    } catch(e){}

    setTimeout(() => {
        document.getElementById("examForm").submit();
    }, 1200);
}

/* Disable right click */
document.addEventListener("contextmenu", e => e.preventDefault());

/* Key detection */
document.addEventListener("keydown", function (e) {

    if (e.key === "Meta") winKey = true;   // Windows key
    if (e.key === "Shift") shiftKey = true;

    /* PrintScreen */
    if (e.key === "PrintScreen") {
        e.preventDefault();
        submitExamSafely("Screenshot detected! Exam will be submitted.");
    }

    /* Win + Shift + S */
    if (winKey && shiftKey && e.key.toLowerCase() === "s") {
        e.preventDefault();
        submitExamSafely("Snipping Tool detected! Exam will be submitted.");
    }

    /* Dev tools / inspect */
    if (
        e.key === "F12" ||
        (e.ctrlKey && e.shiftKey && ["i","c","j"].includes(e.key.toLowerCase())) ||
        (e.ctrlKey && ["u","s"].includes(e.key.toLowerCase()))
    ) {
        e.preventDefault();
    }
});

/* Reset keys */
document.addEventListener("keyup", function () {
    winKey = false;
    shiftKey = false;
});



</script>

<audio id="warningSound">
    <source src="warning.mp3" type="audio/mpeg">
</audio>

<audio id="finishSound">
    <source src="finish.mp3" type="audio/mpeg">
</audio>


</body>
</html>


<!-- function answerAndMark(qNo){ 
    const el=document.getElementById("palette-"+qNo);
    el.classList.remove("unattempted","attempted","marked");
    el.classList.add("answered-marked");
} -->