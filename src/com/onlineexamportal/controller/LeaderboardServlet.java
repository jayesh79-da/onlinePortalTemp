// package com.onlineexamportal.controller;

// import com.onlineexamportal.dao.ResultDAO;
// import com.onlineexamportal.model.Result;

// import javax.servlet.ServletException;
// import javax.servlet.annotation.WebServlet;
// import javax.servlet.http.*;
// import java.io.IOException;
// import java.util.List;


// @WebServlet("/leaderboard")
// public class LeaderboardServlet extends HttpServlet {

//     private ResultDAO resultDAO = new ResultDAO();

//     protected void doGet(HttpServletRequest request, HttpServletResponse response)
//             throws ServletException, IOException {

//         int examId = Integer.parseInt(request.getParameter("examId"));
//         List<Result> leaderboard = resultDAO.getTopResults(examId, 10);

//         request.setAttribute("leaderboard", leaderboard);
//         request.getRequestDispatcher("leaderboard.jsp").forward(request, response);
//     }
// }

package com.onlineexamportal.controller;

import com.onlineexamportal.dao.ResultDAO;
import com.onlineexamportal.model.Result;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;


@WebServlet("/leaderboard")
public class LeaderboardServlet extends HttpServlet {
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String examIdParam = request.getParameter("examId");

    if (examIdParam == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    int examId = Integer.parseInt(examIdParam);

    ResultDAO resultDAO = new ResultDAO();
    List<Result> leaderboard = resultDAO.getTopResults(examId, 10);

    request.setAttribute("leaderboard", leaderboard);
    request.getRequestDispatcher("leaderboard.jsp").forward(request, response);
}
}