package com.onlineexamportal.controller;

import com.onlineexamportal.util.ActiveUserStore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            Object obj = session.getAttribute("user");
            if (obj != null) {
                int userId = ((com.onlineexamportal.model.User)obj).getId();
                // Remove user from active store
                ActiveUserStore.removeUser(userId);
            }
            // Invalidate session
            session.invalidate();
        }

        // Prevent browser caching
        response.setHeader("Cache-Control","no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma","no-cache"); // HTTP 1.0
        response.setDateHeader ("Expires", 0); // Proxies

        // Redirect to login page
        response.sendRedirect("login.jsp");
    }
}
