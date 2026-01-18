<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<% 
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

%>
<!DOCTYPE html>
<html>
<head>
    <title>Register - Online Exam Portal</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="online-test.png" type="image/png">
</head>
<body>


    <div class ="page-wrapper">
    <div class="register-container">
        <h2>Register</h2>
        <form action="register" method="post">
            <input type="text" name="name" placeholder="Full Name" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <input type="submit" value="Register">
        </form>
        <p class="error-message">
            <%= request.getAttribute("errorMessage") != null ? request.getAttribute("errorMessage") : "" %>
        </p>
        <p>Already have an account? <a href="login.jsp">Login here</a></p>
        <a href = "index.jsp">Home</a>
    </div>
    </div>

<!-- SUCCESS POPUP -->
<div id="success-popup">
    <span style="margin-right:8px;">✔</span> Registration Successful!
</div>



<script>

document.addEventListener("contextmenu", function(e){
    e.preventDefault();
});

<% Boolean success = (Boolean) request.getAttribute("success"); 
   if(success != null && success) { %>
    const popup = document.getElementById("success-popup");
    popup.style.display = "block";
    // auto hide after 3 seconds
    setTimeout(() => { popup.style.display = "none"; }, 3000);
<% } %>

</script>



    
</body>
</html>
