package com.onlineexamportal.model;

import java.sql.Timestamp;

public class Certificate {

    private int id;
    private int userId;
    private int examId;
    private String certificatePath;
    private Timestamp issuedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }

    public String getCertificatePath() { return certificatePath; }
    public void setCertificatePath(String certificatePath) {
        this.certificatePath = certificatePath;
    }

    public Timestamp getIssuedAt() { return issuedAt; }
    public void setIssuedAt(Timestamp issuedAt) { this.issuedAt = issuedAt; }
}
