<%@ page import="com.onlineexamportal.dao.ExamDAO"%>
<%@ page import="com.onlineexamportal.model.Exam"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.onlineexamportal.model.User user = (com.onlineexamportal.model.User) session.getAttribute("user");
    if(user == null || !user.getRole().equals("admin")) { response.sendRedirect("login.jsp"); }

    ExamDAO examDAO = new ExamDAO();
    List<Exam> exams = examDAO.getAllExams();
%>
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>

<%@ page import="com.onlineexamportal.util.ActiveUserStore" %>
<%@ page import="com.onlineexamportal.model.User" %>

<%
    
    boolean takeover = false;
    if(user != null) {
        takeover = ActiveUserStore.isTakeoverRequested(user.getId());
    }
%>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="online-test.png" type="image/png">

</head>
<body>
    <div class="page-wrapper">
    <div class="container">

        <h2>Admin Dashboard</h2>
        <h3>Select an option from below:</h3>

        <select id="adminMenu" class="admin-select" onchange="handleMenuChange()">
            <option value="">--select--</option>
            <option value="addExam"> Add Exam </option>
            <option value="addQuestion"> Add Question </option>
            <option value="addMultipleQ"> Add Multiple questions </option>
            <option value="users"> Users</option>
            <option value="exams"> Exams</option>    
           
        </select>
        
        <!-- Add Exam -->
         <div id="addExam" class="menu-section">
             <h3>Add Exam</h3>
             <form action="admin" method="post">
                 <input type="hidden" name="action" value="addExam">
                 <input type="text" name="examName" placeholder="Exam Name" required>
                 <input type="number" name="duration" placeholder="Duration (minutes)" required>
                 <input type="submit" value="Add Exam">
                </form>
            </div>
            
            <!-- Add Question -->
        <div id="addQuestion" class="menu-section">
            <h3>Add Question</h3>
            <form action="admin" method="post">
            <input type="hidden" name="action" value="addQuestion">

            <label for="examId">Select Exam:</label>
            <select name="examId" id="examId" required>
                <% for(Exam e : exams) { %>
                    <option value="<%= e.getId() %>"><%= e.getName() %></option>
                <% } %>
            </select>

            <input type="text" name="questionText" placeholder="Question Text" required>
            <input type="text" name="option1" placeholder="Option 1" required>
            <input type="text" name="option2" placeholder="Option 2" required>
            <input type="text" name="option3" placeholder="Option 3">
            <input type="text" name="option4" placeholder="Option 4">
            <input type="text" name="answer" placeholder="Correct Answer" required>
            
            <input type="submit" value="Add Question">
        </form>
        </div>

    <div id="addMultipleQ" class="menu-section">
        
        <h3>Add Multiple Questions</h3>
        <form action="admin" method="post" id="multiQuestionForm">
    <input type="hidden" name="action" value="addMultipleQuestions">

    <label for="examIdMulti">Select Exam:</label>
    <select name="examId" id="examIdMulti" required>
        <% for(Exam e : exams) { %>
            <option value="<%= e.getId() %>"><%= e.getName() %></option>
            <% } %>
        </select>
        
        <p>Paste questions in this format (numbered, options A-D, last line Answer: ...):</p>
        <pre>
            1. Question text
            A) Option 1
            B) Option 2
            C) Option 3
            D) Option 4
            Answer: C) Correct Option

            2. Question 2...
</pre>

<textarea name="bulkQuestions" id="bulkQuestions" rows="20" style="width:100%;" 
placeholder="Paste your questions here..." required></textarea>

<input type="submit" value="Add All Questions" style="margin-top:10px;">
</form>

</div>


<div id="users" class="menu-section">
    <h3>Users</h3>
    
    <table>
    <tr>
        <th>ID</th>
        <th>User Name</th>
            <th>Email</th>
            
        </tr>
        
        <%
        String sql =
        "SELECT id,name,email from users";
        
        
        try (
            Connection conn = com.onlineexamportal.util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            ) {
                while (rs.next()) {
                    %>
                    <tr>
                        <td><%=rs.getInt("id") %></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("email") %></td>

    
                    </tr>
                    <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='5'>Error loading data</td></tr>");
            }
            %>
            
        </table>
    </div>
    
<div id="exams" class="menu-section">

<h3>Exams</h3>

<table>
    <tr>
        <th>EXAM ID</th>
        <th>Exam Name</th>
        <th>Duration (min)</th>
        <th>No. of Questions</th> 
        <th>Action</th>
        
    </tr>
      
<%
String sql1 =
    "SELECT e.id, e.name AS exam_name, e.duration, COUNT(q.id) AS question_count " +
    "FROM exams e " +
    "LEFT JOIN questions q ON e.id = q.exam_id " +
    "GROUP BY e.id, e.name, e.duration " +
    "ORDER BY e.id";

try (
    Connection conn = com.onlineexamportal.util.DBConnection.getConnection();
    PreparedStatement ps = conn.prepareStatement(sql1);
    ResultSet rs = ps.executeQuery();
) {
    while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("exam_name") %></td>
    <td><%= rs.getInt("duration") %></td>
    <td><%= rs.getInt("question_count") %></td>
    <td>  
        <form action="admin" method="post"
              onsubmit="return confirm('Are you sure you want to delete this exam? All questions will also be deleted!');">
            <input type="hidden" name="action" value="deleteExam">
            <input type="hidden" name="examId" value="<%= rs.getInt("id") %>">
            <input type="submit" value="Delete" style="background:red;color:white;border:none;padding:6px 10px;cursor:pointer;">
        </form></td>
</tr>
<%
    }
} catch (Exception e) {
    out.println("<tr><td colspan='3'>Error loading exams</td></tr>");
}
%>
</table> 
</div>


<!-- protection script -->
<script>
window.onpageshow = function(event) {
    if (event.persisted) {
        alert('You pressed back button or refresh! ');
        window.location.href = "index.jsp";
    }
};

   if (
        e.key === "F12" ||
        (e.ctrlKey && e.shiftKey && ["i","c","j"].includes(e.key.toLowerCase())) ||
        (e.ctrlKey && ["u","s"].includes(e.key.toLowerCase()))
    ) {
        e.preventDefault();
    }

    document.addEventListener("contextmenu", e => e.preventDefault());


function handleMenuChange() {
    const sections = document.querySelectorAll('.menu-section');
    sections.forEach(section => section.style.display = 'none');

    const selected = document.getElementById('adminMenu').value;
    if (selected) {
        document.getElementById(selected).style.display = 'block';
    }
}



</script>

  <form method ="post" action="logout" id="logoutForm">
        <button type = "submit">Logout</button>
    </form>
</div>
</div>



</body>
</html>


      