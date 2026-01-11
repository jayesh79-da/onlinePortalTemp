package com.onlineexamportal.model;

public class ResultDetail {

    private String question;
    private String selectedAnswer;
    private String correctAnswer;
    private boolean is_correct;

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getSelectedAnswer() {
        return selectedAnswer;
    }

    public void setSelectedAnswer(String selectedAnswer) {
        this.selectedAnswer = selectedAnswer;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }

    public boolean getIsCorrect(){ return is_correct; }
    public void setIsCorrect(boolean is_correct) { this.is_correct = is_correct;   }
}
