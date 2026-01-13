package com.onlineexamportal.util;

import java.util.concurrent.ConcurrentHashMap;

public class ActiveUserStore {

    // userId → sessionId
    private static ConcurrentHashMap<Integer, String> activeUsers = new ConcurrentHashMap<>();

    private static ConcurrentHashMap<Integer, Boolean> takeover = new ConcurrentHashMap<>();
    // private static ConcurrentHashMap<String, Boolean> forceLogoutSessions = new ConcurrentHashMap<>();

    public static boolean isUserLoggedIn(int userId) {
        return activeUsers.containsKey(userId);
    }

    public static String getSessionId(int userId) {
        return activeUsers.get(userId);
    }

    public static void addUser(int userId, String sessionId) {
        activeUsers.put(userId, sessionId);
        takeover.remove(userId);
    }

    
    public static void markUserForLogout(int userId) {
        takeover.put(userId, true);
    }

    public static boolean isTakeoverRequested(int userId)
    {
        return takeover.containsKey(userId);
    }

    public static void cancelTakeover(int userId) {
        takeover.remove(userId);
    }

   
    public static void removeUser(int userId) {
        activeUsers.remove(userId);
        takeover.remove(userId);
        
    }

   
    class SessionInfo {
        String sessionId;
        boolean takeoverRequested;
    }

}
