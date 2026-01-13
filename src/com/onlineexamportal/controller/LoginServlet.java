package com.onlineexamportal.controller;

import com.onlineexamportal.dao.UserDAO;
import com.onlineexamportal.model.User;
import com.onlineexamportal.util.ActiveUserStore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        String captchaInput = request.getParameter("captcha");
        Object captchaObj = request.getSession().getAttribute("captchaAnswer");

        if (captchaInput == null || captchaObj == null) {
            request.setAttribute("errorMessage", "CAPTCHA expired. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        int userCaptcha = Integer.parseInt(captchaInput);
        int realCaptcha = (int) captchaObj;

    
        if(userCaptcha != realCaptcha)
        {
            request.setAttribute("error","INVALID CAPTCHA!");
            request.getRequestDispatcher("login.jsp").forward(request,response);
            return;
        }

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Email and password required");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.loginUser(email.trim(), password);

        if (user != null) {

            if (ActiveUserStore.isUserLoggedIn(user.getId())) {
            // warn old session
                ActiveUserStore.markUserForLogout(user.getId());
                 request.setAttribute("errorMessage", 
                "This user is already logged in on another device.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }


            // Session Fixation Protection
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }


            //creating a new session as true
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            
            ActiveUserStore.addUser(user.getId(), session.getId());

            session.setAttribute("takeoverMessage", "Your old session was logged out because you logged in from a new device.");
            response.sendRedirect(user.getRole().equals("admin") ? "admin.jsp" : "dashboard.jsp");
            return;
            // if ("admin".equalsIgnoreCase(user.getRole())) {
            //     response.sendRedirect("admin.jsp");
            //     return;
            // } 

            // else 
            // {
            //     response.sendRedirect("dashboard.jsp");
            //     return;
            // }
            

        } 
        
        else {
            request.setAttribute("errorMessage", "Invalid email or password");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }

        // If you want Continue Here button to cancel takeover
        String action = request.getParameter("action");
        if("continue".equals(action) && user != null) {
            ActiveUserStore.cancelTakeover(user.getId());
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }


    
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect("login.jsp");
    }
}
