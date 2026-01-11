<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get rank from request attribute
    Integer rank = (Integer) request.getAttribute("rank");
    Integer score = (Integer) request.getAttribute("score");

    String badgeText = "";
    String badgeColor = "";
    String achievementText = "for successfully completing the examination";

    if (rank != null) {
        switch (rank) {
            case 1:
                badgeText = "🏆 Rank 1 - GOLD ACHIEVER";
                badgeColor = "#d4af37";
                achievementText = "for securing <b>FIRST RANK</b> with outstanding performance in";
                break;
            case 2:
                badgeText = "🥈 Rank 2 - SILVER ACHIEVER";
                badgeColor = "#c0c0c0";
                achievementText = "for securing <b>SECOND RANK</b> with excellent performance in";
                break;
            case 3:
                badgeText = "🥉 Rank 3 - BRONZE ACHIEVER";
                badgeColor = "#cd7f32";
                achievementText = "for securing <b>THIRD RANK</b> with commendable performance in";
                break;
        }
    }
%> 



<!DOCTYPE html>
    <html>
        <head>
            <title>Certificate</title>
            
            <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
            
            <link href="https://fonts.googleapis.com/css2?family=Great+Vibes&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
            <link rel="icon" href="online-test.png" type="image/png">
            
            <style>
                
    body
    {
        background:#fdf8ef;
        display:flex;
        justify-content:center;
        align-items:center;
        min-height:100vh;
        margin:0;
    }




.certificate-wrapper{
    text-align:center;
}

.certificate-container{
    position:relative;
    width:800px;
    padding:40px;
    border:12px solid #b8860b;
    background:white;
    box-shadow:0 0 20px rgba(0,0,0,0.2);
}

/* Watermark */
.certificate-container::before{
    content:"EXAM CERTIFICATE";
    position:absolute;
    top:50%;
    left:50%;
    transform:translate(-50%,-50%) rotate(-30deg);
    font-size:70px;
    color:rgba(184,134,11,0.15);
    font-family:'Playfair Display',serif;
    white-space:nowrap;
    pointer-events:none;
}

.logo-left{
    position:absolute;
    top:30px;
    left:30px;
    height:50px;
    width: 50px;
}

.rank-badge{
    margin-top:20px;
    padding:12px 30px;
    display:inline-block;
    font-size:22px;
    font-weight:bold;
    border-radius:40px;
    color:white;
    box-shadow:0 5px 15px rgba(0,0,0,0.3);
}

/* .rank-watermark{
    position:absolute;
    top:50%;
    left:50%;
    transform:translate(-50%,-50%) rotate(-25deg);
    font-size:90px;
    font-weight:bold;
    color:rgba(0,0,0,0.08);
    z-index:0;
    pointer-events:none;
    white-space:nowrap;
} */


.certificate-title{
    font-family:'Great Vibes',cursive;
    font-size:60px;
    color:#8b0000;
}

.certificate-subtitle{
    font-family:'Playfair Display',serif;
    font-size:22px;
    margin-top:20px;
}

.certificate-name{
    font-family:'Great Vibes',cursive;
    font-size:48px;
    margin:30px 0;
}

.certificate-footer{
    margin-top:70px;
    display:flex;
    justify-content:space-between;
    align-items:center;
}

.footer-left{
    font-size:18px;
}

.footer-center,.footer-right{
    text-align:center;
}

.footer-center img,
.footer-right img{
    width:150px;
}

/* Buttons area */
.certificate-actions{
    margin-top:30px;
}

.download-button{
    padding:12px 30px;
    background:#8b0000;
    color:white;
    border-radius:6px;
    font-size:18px;
    text-decoration:none;
    display:inline-block;
}

.download-button:hover{
    background:#b22222;
}

a{
    color:#8b0000;
    text-decoration:none;
}
</style>
</head>

<body>
    
    <div class="certificate-wrapper">
        <div class="certificate-container" id="certificate">
            
            <% if (rank != null) { %>
                <div class="rank-badge" style="background:<%= badgeColor %>">
                    <%= badgeText %>
                </div>
            <% } %>         
            
        <img src="online-test.png" class = "logo-left">
        
        <div class="certificate-title">Certificate of Achievement</div>
        
        <div class="certificate-subtitle">This is proudly presented to</div>
        
        <div class="certificate-name">
            <%= request.getAttribute("userName") %>
        </div>

        <% if (score != null) { %>
        <div class="certificate-subtitle">
                <b>Score:</b> <%= score %>
        </div>
        <% } %>



        <div class="certificate-subtitle">
                <%= achievementText %><br>
                <b>"<%= request.getAttribute("examName") %>"</b>
        </div>


        <!-- <div class="certificate-subtitle">
            for successfully completing the examination<br>
            <b><%= request.getAttribute("examName") %></b>
        </div> -->

        <div class="certificate-footer">
            <div class="footer-left">
                Date: <%= request.getAttribute("date") %>
            </div>

            <div class="footer-center">
                <img src="images/Sign.jpeg"><br>
                Coordinator
            </div>

            <div class="footer-right">
                <img src="images/Sign1.jpeg"><br>
                Authorized Signatory
            </div>
        </div>
        
    </div>


    <div class="certificate-actions">
        <a href="#" class="download-button" id="downloadBtn">Download Certificate</a>
        <p><a href="dashboard.jsp">Back to Dashboard</a></p>
    </div>

</div>

<script>
    
    document.addEventListener("contextmenu", function(e){
    e.preventDefault();
    });


document.getElementById("downloadBtn").addEventListener("click", function(e){
    e.preventDefault();
    const { jsPDF } = window.jspdf;
    
    html2canvas(document.getElementById("certificate")).then(canvas=>{
        const imgData = canvas.toDataURL("image/png");
        const pdf = new jsPDF("l","pt",[canvas.width,canvas.height]);
        pdf.addImage(imgData,"PNG",0,0,canvas.width,canvas.height);
        pdf.save("Certificate.pdf");
    });
});
</script>

</body>

</html>

















































