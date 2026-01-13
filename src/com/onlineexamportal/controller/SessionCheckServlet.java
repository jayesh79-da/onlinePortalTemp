package com.onlineexamportal.controller;

import com.onlineexamportal.util.ActiveUserStore;
import com.onlineexamportal.model.User;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/session-check")
public class SessionCheckServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.getWriter().write("LOGOUT");
            return;
        }
        
    User user = (User) session.getAttribute("user");
    
        if (user == null) {
            response.getWriter().write("LOGOUT");
            return;
        }

        

        if (ActiveUserStore.isTakeoverRequested(user.getId())) {
            response.getWriter().write("TAKEOVER");
        } else {
            response.getWriter().write("OK");
        }
    }
}
