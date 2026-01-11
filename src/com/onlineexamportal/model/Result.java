package com.onlineexamportal.model;

public class Result {
    private int id;
    private int userId;
    private int examId;
    private int score;
    private int timeTaken;  
    private String userName; 

    // Default constructor
    public Result() {}

    // Parameterized constructor
    public Result(int id, int userId, int examId, int score, int timeTaken) {
        this.id = id;
        this.userId = userId;
        this.examId = examId;
        this.score = score;
        this.timeTaken = timeTaken;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public int getTimeTaken() {
        return timeTaken;
    }

    public void setTimeTaken(int timeTaken) {
        this.timeTaken = timeTaken;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }
}
