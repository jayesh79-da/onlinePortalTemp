<%@ page import="com.onlineexamportal.model.Result" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Result> leaderboard = (List<Result>) request.getAttribute("leaderboard");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Leaderboard</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="online-test.png" type="image/png">
</head>
<body>
<div class="leaderboard-container">
    <h2>Leaderboard</h2>
    <table>
        <tr><th>Rank</th><th>Candidate</th><th>Score</th></tr>
        <% int rank = 1; for(Result r : leaderboard) { %>
            <tr>
                <td>
                    <%= rank == 1 ? "🥇  1st" : rank == 2 ? "🥈 2nd" : rank == 3 ? "🥉 3rd" : rank %>
                </td>

                <td><%= r.getUserName() %></td>
                <td><%= r.getScore() %></td>
            </tr>
        <% rank++; } %>
    </table>
    <p><a href="dashboard.jsp">Back to Dashboard</a></p>
</div>
</body>
</html>
