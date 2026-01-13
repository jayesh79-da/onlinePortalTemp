package com.onlineexamportal.controller;

import com.onlineexamportal.dao.UserDAO;
import com.onlineexamportal.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (name == null || email == null || password == null ||
                name.isEmpty() || email.isEmpty() || password.isEmpty()) {

            request.setAttribute("errorMessage", "All fields are required");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setName(name.trim());
        user.setEmail(email.trim());
        user.setPassword(password);
        user.setRole("user");

        boolean success = userDAO.registerUser(user);

        if (success) {
            // response.sendRedirect("login.jsp?success=registered");
            request.setAttribute("success", true);
    request.getRequestDispatcher("register.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Email already exists");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
