<%@ page import="java.util.List" %>
<%@ page import="com.onlineexamportal.model.ResultDetail" %>
<%@ page import="com.onlineexamportal.dao.ResultDAO" %>
<%@ page import="com.onlineexamportal.model.User" %>
<%@ page import="com.onlineexamportal.model.Result" %>
<%@ page import="com.onlineexamportal.dao.ExamDAO" %>
<%@ page import="com.onlineexamportal.model.Exam" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int examId = Integer.parseInt(request.getParameter("examId"));

    ResultDAO resultDAO = new ResultDAO();
    ExamDAO examDAO = new ExamDAO();

    Result result = resultDAO.getResultByUserAndExam(user.getId(), examId);
    Exam exam = examDAO.getExamById(examId);

    if (result == null || exam == null) {
        out.println("Result not available.");
        return;
    }

    List<ResultDetail> analysis = resultDAO.getResultDetails(user.getId(), examId);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Result - <%= exam.getName() %></title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="online-test.png" type="image/png">

    <style>
        .analysis-container { display: none; margin-top: 20px; }
        .analysis-table { border-collapse: collapse; width: 100%; }
        .analysis-table th, .analysis-table td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        .toggle-btn { margin-top: 15px; }
    </style>

    <script>
        function toggleAnalysis() {
            var container = document.getElementById('analysisContainer');
            if (container.style.display === 'none') {
                container.style.display = 'block';
            } else {
                container.style.display = 'none';
            }
        }
    </script>
</head>

<body>
<div class="result-container">

    <h2>Exam Result: <%= exam.getName() %></h2>
    <p>Candidate: <%= user.getName() %></p>
    <p>Score: <%= result.getScore() %></p>
    <p></p>
    <p>Time Taken: <%= result.getTimeTaken() %> seconds</p>

    <p>
        <a href="certificate?examId=<%= examId %>">
            <button>Download Certificate</button>
        </a>
    </p>


        <!-- Toggle Analysis Button -->
    <p class="toggle-btn">
        <button onclick="toggleAnalysis()">View Detailed Analysis</button>
    </p>


    

    <!-- Embedded Analysis Table -->
    <div id="analysisContainer" class="analysis-container">
        <h3>Exam Analysis</h3>
        <table class="analysis-table">
            <tr>
                <th>Question</th>
                <th>Your Answer</th>
                <th>Correct Answer</th>
                <th>Status</th>
            </tr>

            <% if (analysis != null && !analysis.isEmpty()) { 
                for (ResultDetail rd : analysis) {
                   
            %>
            <tr>
                <td><%= rd.getQuestion() %></td>
                <td><%= rd.getSelectedAnswer() != null ? rd.getSelectedAnswer() : "Not Answered" %></td>
                <td><%= rd.getCorrectAnswer() %></td>
                <td style="color:<%= rd.getIsCorrect() ? "green" : "red" %>;">
                    <%= rd.getIsCorrect() ? "Correct" : "Wrong" %>
                </td>
            </tr>
            <%  } 
            } else { %>
            <tr>
                <td colspan="4" style="text-align:center;">No data available</td>
            </tr>
            <% } %>
        </table>

        
    </div>

    <br>
    <p><a href="dashboard.jsp">Back to Dashboard</a></p>

</div>
</body>
</html>
