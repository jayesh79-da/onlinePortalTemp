package com.onlineexamportal.util;

import java.util.regex.Pattern;

public class Validator {

    // Validate if string is not null or empty
    public static boolean isNotEmpty(String input) {
        return input != null && !input.trim().isEmpty();
    }

    // Validate email format
    public static boolean isValidEmail(String email) {
        if(email == null) return false;
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        return Pattern.matches(emailRegex, email);
    }

    // Validate password (minimum 6 chars, at least 1 number, 1 letter)
    public static boolean isValidPassword(String password) {
        if(password == null)
            return false;
        String passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$";
        return Pattern.matches(passwordRegex, password);
    }

    // Validate number (positive integer)
    public static boolean isPositiveInteger(String str) {
        if(str == null) return false;
        try {
            int num = Integer.parseInt(str);
            return num > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    // Validate if string length is within range
    public static boolean isLengthValid(String str, int min, int max) {
        if(str == null) return false;
        int length = str.trim().length();
        return length >= min && length <= max;
    }

    // Example: validate exam duration (minutes)
    public static boolean isValidDuration(int duration) {
        return duration > 0 && duration <= 180; // maximum 3 hours
    }
}
