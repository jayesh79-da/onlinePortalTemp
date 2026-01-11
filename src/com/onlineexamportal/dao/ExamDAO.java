package com.onlineexamportal.dao;

import com.onlineexamportal.model.Exam;
import com.onlineexamportal.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExamDAO {

    // Add new exam
    public boolean addExam(Exam exam) {
        String sql = "INSERT INTO exams (name, duration) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, exam.getName());
            ps.setInt(2, exam.getDuration());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all exams
    public List<Exam> getAllExams() {
        List<Exam> exams = new ArrayList<>();
        String sql = "SELECT * FROM exams";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Exam exam = new Exam();
                exam.setId(rs.getInt("id"));
                exam.setName(rs.getString("name"));
                exam.setDuration(rs.getInt("duration"));
                exams.add(exam);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return exams;
    }

    // Get exam by ID
    public Exam getExamById(int id) {
        String sql = "SELECT * FROM exams WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Exam exam = new Exam();
                exam.setId(rs.getInt("id"));
                exam.setName(rs.getString("name"));
                exam.setDuration(rs.getInt("duration"));
                return exam;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int getQuestionCount(int examId) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM questions WHERE exam_id = ?";
            try (Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, examId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
             count = rs.getInt(1);
            }
        } 
        catch (Exception e) 
        {
            e.printStackTrace();
        }
    return count;
}

public boolean hasUserAttemptedExam(int userId, int examId) {
    String sql = "SELECT 1 FROM results WHERE user_id=? AND exam_id=? LIMIT 1";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ps.setInt(2, examId);
        ResultSet rs = ps.executeQuery();
        return rs.next();
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}
public int getUserRank(int userId, int examId) {
    int rank = 0;
    String sql = "SELECT user_id, score FROM results WHERE exam_id = ? ORDER BY score DESC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, examId);
        ResultSet rs = ps.executeQuery();

        int position = 1;
        int lastScore = -1;
        int currentRank = 0;

        while (rs.next()) {
            int currentUserId = rs.getInt("user_id");
            int score = rs.getInt("score");

            if (score != lastScore) {
                currentRank = position;
            }
            lastScore = score;

            if (currentUserId == userId) {
                rank = currentRank;
                break;
            }
            position++;
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return rank; // 1,2,3,... or 0
}

//==========DELETE EXAM=============
public void deleteExam(int examId) {
    String deleteQuestions = "DELETE FROM questions WHERE exam_id = ?";
    String deleteExam = "DELETE FROM exams WHERE id = ?";

    try (Connection conn = DBConnection.getConnection()) {

        // Delete questions first
        try (PreparedStatement ps1 = conn.prepareStatement(deleteQuestions)) {
            ps1.setInt(1, examId);
            ps1.executeUpdate();
        }

        // Then delete exam
        try (PreparedStatement ps2 = conn.prepareStatement(deleteExam)) {
            ps2.setInt(1, examId);
            ps2.executeUpdate();
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
}





}
