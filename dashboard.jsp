<%@ page import="com.onlineexamportal.util.ActiveUserStore" %>
<%@ page import="com.onlineexamportal.model.User" %>
<%@ page import="com.onlineexamportal.model.User" %>
<%@ page import="com.onlineexamportal.model.Exam" %>
<%@ page import="com.onlineexamportal.model.Result" %>
<%@ page import="com.onlineexamportal.dao.ExamDAO" %>
<%@ page import="com.onlineexamportal.dao.ResultDAO" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    User user = (User) session.getAttribute("user");
    if(user == null){
        response.sendRedirect("login.jsp");
        return;
    }

    ExamDAO examDAO = new ExamDAO();
    ResultDAO resultDAO = new ResultDAO();
    List<Exam> exams = examDAO.getAllExams();
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
    <title>User Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="online-test.png" type="image/png">
</head>
<body>

    
    <div class="page-wrapper">
        <div class="dashboard-container">
            <h2>Welcome, <%= user.getName() %></h2>

    <h3>Available Exams</h3>
    <table border="1" cellpadding="8" style="border-collapse:collapse;">
        <tr>
            <th>Exam ID</th>
            <th>Exam Name</th>
            <th>Duration (min)</th>
            <th>No. of Questions</th>
            <th>Action</th>
        </tr>

        <% for(Exam e : exams) { 
            boolean attempted = examDAO.hasUserAttemptedExam(user.getId(),e.getId());   
            if(!attempted)
            {
                int questionCount = examDAO.getQuestionCount(e.getId()); 
            
        %>
        <tr>
            <td><%= e.getId() %></td>
            <td><%= e.getName() %></td>
            <td><%= e.getDuration() %></td>
            <td><%= questionCount %></td>
            <td>
                <form method="get" action="exam" style="display:inline;">
                    <input type="hidden" name="examId" value="<%= e.getId() %>">
                    <button type="submit">Start Exam</button>
                </form>
                <form method="get" action="leaderboard" style="display:inline;">
                    <input type="hidden" name="examId" value="<%= e.getId() %>">
                    <button type="submit">View Leaderboard</button>
                </form>
            </td>
        </tr>
        <% } }%>
         </table>


        <h3>Attempted Exams</h3>
        <table border="1" cellpadding="8" style="border-collapse:collapse;">
        <tr>
            <th>Exam ID</th>
            <th>Exam Name</th>
            <th>Score</th>
            <th>Time taken</th>
            <th>Action</th>
        </tr>

        <% for(Exam e : exams) {
            boolean attempted = examDAO.hasUserAttemptedExam(user.getId(), e.getId());
                if(attempted){
                    Result r = resultDAO.getResult(user.getId(),e.getId());
        %>
        <tr>
                <td><%= e.getId() %></td>
                <td><%= e.getName() %></td>
                  <td><%= r != null ? r.getScore() : "-" %></td>
               <td>
            <%
                    if (r != null) {
                        int totalSec = r.getTimeTaken();
                        int min = totalSec / 60;
                        int sec = totalSec % 60;
            %>
            <%= min %>:<%= (sec < 10 ? "0" : "") + sec %>
    <%
            } else {
    %>
    -
<%
    }
%>
</td>
          <td>
            <form method="get" action="result.jsp">
                <input type="hidden" name="examId" value="<%= e.getId() %>">
                <button type="submit">View Result</button>
            </form>
                

                <form method="get" action="leaderboard" style="display:inline;">
                    <input type="hidden" name="examId" value="<%= e.getId() %>">
                    <button type="submit">View Leaderboard</button>
                </form>

            </td>
        </tr>
<% } } %>
</table>
 
    <form method ="post" action="logout" id="logoutForm">
        <button type = "submit">Logout</button>
    </form>
    
</div>
</div>
<script>
       if (
        e.key === "F12" ||
        (e.ctrlKey && e.shiftKey && ["i","c","j"].includes(e.key.toLowerCase())) ||
        (e.ctrlKey && ["u","s"].includes(e.key.toLowerCase()))
    ) {
        e.preventDefault();
    }

    document.addEventListener("contextmenu", e => e.preventDefault());
</script>


</body>
</html>








































<!-- <tr><th>Exam Name</th><th>Duration (min)</th><th>Action</th></tr>
<% for(Exam e : exams) { %>
    <tr>
        <td><%= e.getName() %></td>
        <td><%= e.getDuration() %></td>
        
        <td>
<form method="get" action="exam" style="display:inline;">
<input type="hidden" name="examId" value="<%= e.getId() %>">
<button type="submit">Start Exam</button>
</form>

<form method="get" action="leaderboard" style="display:inline;">
<input type="hidden" name="examId" value="<%= e.getId() %>">
<button type="submit">View Leaderboard</button>
</form>
</td>

    </tr>
<% } %> -->
