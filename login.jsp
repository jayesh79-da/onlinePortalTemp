<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
int a = (int)(Math.random() * 10);
int b = (int)(Math.random() * 10);
session.setAttribute("captchaAnswer", a + b);

// PREVENT BACK BUTTON CACHE
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Online Exam Portal</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="online-test.png" type="image/png">
</head>
<body>

    <% Boolean success = (Boolean) request.getAttribute("success"); %>
    <div id="success-popup">
    <span style="margin-right:8px;">✔</span> Login Successful!
    </div>


    <div class="page-wrapper">
    <div class="login-container">
        <h2>Login</h2>
        <form action="login" method="post">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <br><label>Solve CAPTCHA:</label>
            <p><strong><%= a %> + <%= b %> = ?</strong></p>
                <input type="number" name="captcha" required>
            <input type="submit" value="Login">
        </form>
        <p class="error-message">
            <%= request.getAttribute("errorMessage") != null ? request.getAttribute("errorMessage") : "" %>
        </p>
        <p>New user? <a href="register.jsp">Register here</a></p>
    </div>
    </div>

    <script>
        
    document.addEventListener("contextmenu", function(e){
    e.preventDefault();
    });

    /* Dev tools / inspect */
    if (
        e.key === "F12" ||
        (e.ctrlKey && e.shiftKey && ["i","c","j"].includes(e.key.toLowerCase())) ||
        (e.ctrlKey && ["u","s"].includes(e.key.toLowerCase()))
    ) {
        e.preventDefault();
    }

</script>
</body>
</html>
