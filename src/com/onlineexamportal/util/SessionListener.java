 package com.onlineexamportal.util;

import javax.servlet.http.*;

public class SessionListener implements HttpSessionListener {

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        Object user = session.getAttribute("user");

        if (user != null) {
            com.onlineexamportal.model.User u =
                (com.onlineexamportal.model.User) user;
            ActiveUserStore.removeUser(u.getId());
        }
    }

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // empty method
    }

}
