<%@ page import="com.onlineexamportal.model.User" %>
<%@ page import="com.onlineexamportal.model.Exam" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Exam exam = (Exam) request.getAttribute("exam");
    if (exam == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    // If exam already completed → result
    Boolean completed = (Boolean) session.getAttribute("examCompleted_" + exam.getId());
    if (completed != null && completed) {
        response.sendRedirect("result.jsp?examId=" + exam.getId());
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Exam Instructions</title>
    <style>
        body
        {font-family:Segoe UI;background:#f4f6f9;padding:30px;}

        .box{max-width:1400px;margin:auto;background:#fff;padding:25px;border-radius:8px;}

        h2{color:#0a2a66;}

        ul li{margin-bottom:10px;}

        .start-btn{
        background:#0a2a66;
        color:#fff;
        padding:12px 25px;
        border:none;
        border-radius:5px;
        font-size:16px;
        cursor:pointer;
        opacity:1;
        transition: all 0.3s ease;
}

.start-btn:disabled{
    background:#0a2a66;
    opacity:0.35;           
    cursor:not-allowed;
}

.start-btn:disabled{cursor:not-allowed;}
.start-btn:not(:disabled):hover{
    background:#08305e;
}

.blink-warning {
    color: red;
    font-weight: bold;
    animation: blink 1s infinite;
}

@keyframes blink {
    0%   { opacity: 1; }
    50%  { opacity: 0; }
    100% { opacity: 1; }
}

</style>
<link rel="icon" href="online-test.png" type="image/png">

</head>

<body>
<div class="box">
    
    <h3 align="center"><span class="blink-warning">⚠ Warning:
Taking screenshots, switching tabs, or using screen capture tools
will automatically submit your exam.</h3></span>
    <h2>Exam Instructions</h2>
    
    <p><b>Exam:</b> <%= exam.getName() %></p>
    <p><b>Duration:</b> <%= exam.getDuration() %> minutes</p>
    <p><b>No of Questions:</b> ${questionCount} Questions</p> 

    <hr>

    <ul>
        <li><strong>Instructions:</li></strong>
        <li>The exam is <b>time-bound</b>.</li>
        <li>Once started, the timer <b>cannot be paused</b>.</li>
        <li>Refreshing the browser will <b>not reset</b> the timer.</li>
        <li>Do <b>not switch tabs</b> – exam will auto-submit.</li>
        <li>Each question has only <b>one correct answer</b>.</li>
        <li>You can mark questions for review.</li>
        <li>The exam will auto-submit when time ends.</li>
    </ul>
    <br>
<hr>
    <ul>
        <li><strong>सूचना:</strong></li>
     <li>परीक्षा <b>वेळेच्या मर्यादेत</b> आहे.</li>
     <li> एकदा सुरू झाल्यावर, टायमर <b>थांबवता येणार नाही</b>.</li>
    <li> ब्राउझर रिफ्रेश केल्याने टायमर <b>रीसेट होणार नाही</b>.</li>
    <li> <b>टॅब बदलू नका</b> – परीक्षा आपोआप सबमिट होईल.</li>
    <li> प्रत्येक प्रश्नाचे फक्त <b>एकच योग्य उत्तर</b> आहे.</li>
    <li> तुम्ही प्रश्न पुनरावलोकनासाठी चिन्हांकित करू शकता.</li>
    <li> वेळ संपल्यावर परीक्षा आपोआप सबमिट होईल.</li>
   </ul>


    <div style="margin-top:20px;">
    <label style="font-size:15px; cursor:pointer;">
        <input type="checkbox" id="agreeCheckbox" onclick="toggleStart()">
        I have read and agree to all the exam rules and instructions.
    </label>
</div>


    <!-- <form method="get" action="exam">
        <input type="hidden" name="examId" value="<%= exam.getId() %>">
        <button type="submit" class="start-btn" id ="start-btn" disabled>Start Exam</button>
    </form> -->

  <div id="proceedSection">
    <button type="button" class="start-btn" id="proceed-btn" disabled>
        Proceed
    </button>
</div>

<div id="fullscreenSection" style="display:none; margin-top:15px;">
    <div class="blink-warning">
        ⚠ Full screen required to start the exam
    </div>

    <form id="startForm" method="post" action="exam">
        <input type="hidden" name="examId" value="<%= exam.getId() %>">
        <button type="button" class="start-btn" id="startExamBtn">
            Start Exam
        </button>
    </form>
</div>


   
</form>

</div>


<script>
function toggleStart(){
    const checkbox = document.getElementById("agreeCheckbox");
    const btn = document.getElementById("proceed-btn");
    btn.disabled = !checkbox.checked;
}

// ===== Disable Right Click =====
document.addEventListener("contextmenu", function(e){
    e.preventDefault();
});


document.addEventListener("copy", e => e.preventDefault());
document.addEventListener("paste", e => e.preventDefault());
document.addEventListener("cut", e => e.preventDefault());
document.addEventListener("selectstart", e => e.preventDefault());


document.addEventListener("keydown", function(e){

    // Disable F5, Ctrl+R (Refresh)
    if (e.key === "F5" || (e.ctrlKey && e.key.toLowerCase() === "r")) {
        e.preventDefault();
    }

    
    if (e.ctrlKey && ["c","v","x","u"].includes(e.key.toLowerCase())) {
        e.preventDefault();
    }

    
    if (e.key === "PrintScreen") {
        e.preventDefault();
        alert("Screenshot is disabled!");
    }
});


history.pushState(null, null, location.href);
window.onpopstate = function () {
    history.go(1);
};

//+++++++++++++++++++++++

const proceedBtn = document.getElementById("proceed-btn");
const fullscreenSection = document.getElementById("fullscreenSection");
const startExamBtn = document.getElementById("startExamBtn");

// Step 1: Proceed button just shows warning
proceedBtn.addEventListener("click", function () {
    fullscreenSection.style.display = "block";
    proceedBtn.style.display = "none";
});

// Step 2: Start Exam button MUST request fullscreen
startExamBtn.addEventListener("click", function () {

    if(!document.fullscreenElement){
    // Request fullscreen INSIDE click event
    if (document.documentElement.requestFullscreen) {
        document.documentElement.requestFullscreen()
            
            .then(() => {
                document.getElementById("startForm").submit();
                })

            .catch(() => {
                alert("FullScreen is required to start the exam.");
            });
    } else {
        alert("Fullscreen not supported in this browser.");
    }
}
    else{  
        // Already fullscreen, just submit
        document.getElementById("startForm").submit();
    }
});

document.addEventListener("fullscreenchange", () => {
    if (!document.fullscreenElement) {
        alert("⚠ You exited fullscreen. Exam will be submitted.");
        document.getElementById("startForm").submit();
    }
});




// document.addEventListener("DOMContentLoaded", function () {

//     if (!document.fullscreenElement) {
//         document.documentElement.requestFullscreen().catch(() => {
//             console.log("Fullscreen request blocked");
//         });
//     }

// });


</script>


</body>
</html>
