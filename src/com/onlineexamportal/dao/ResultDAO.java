package com.onlineexamportal.dao;

import com.onlineexamportal.model.Result;
import com.onlineexamportal.model.ResultDetail;
import com.onlineexamportal.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ResultDAO {

    private Connection conn;

    public ResultDAO() {
        conn = DBConnection.getConnection();
    }

    // -----------------------
    // Save Result (full object)
    // -----------------------
    public boolean saveResult(Result result) {
        String sql = "INSERT INTO results (user_id, exam_id, score, time_taken) VALUES (?, ?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, result.getUserId());
            ps.setInt(2, result.getExamId());
            ps.setInt(3, result.getScore());
            ps.setInt(4, result.getTimeTaken());
            int i = ps.executeUpdate();
            return i > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // -----------------------
    // Shortcut for ExamServlet
    // -----------------------
    public boolean saveResult(int userId, int examId, int score) {
        Result r = new Result();
        r.setUserId(userId);
        r.setExamId(examId);
        r.setScore(score);
        r.setTimeTaken(0); // default, can be updated if tracking time
        return saveResult(r);
    }

    // -----------------------
    // Get result by userId and examId
    // -----------------------
    public Result getResultByUserAndExam(int userId, int examId) {
        Result result = null;
        String sql = "SELECT r.*, u.name FROM results r JOIN users u ON r.user_id = u.id WHERE r.user_id = ? AND r.exam_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                result = new Result();
                result.setId(rs.getInt("id"));
                result.setUserId(rs.getInt("user_id"));
                result.setExamId(rs.getInt("exam_id"));
                result.setScore(rs.getInt("score"));
                result.setTimeTaken(rs.getInt("time_taken"));
                result.setUserName(rs.getString("name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    // -----------------------
    // Get Top Scores for Leaderboard (custom limit)
    // -----------------------
    public List<Result> getTopResults(int examId, int limit) {
        List<Result> list = new ArrayList<>();
        String sql = "SELECT r.*, u.name FROM results r JOIN users u ON r.user_id = u.id WHERE r.exam_id = ? ORDER BY r.score DESC, r.time_taken ASC LIMIT ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                Result r = new Result();
                r.setId(rs.getInt("id"));
                r.setUserId(rs.getInt("user_id"));
                r.setExamId(rs.getInt("exam_id"));
                r.setScore(rs.getInt("score"));
                r.setTimeTaken(rs.getInt("time_taken"));
                r.setUserName(rs.getString("name"));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // -----------------------
    // Shortcut for LeaderboardServlet
    // -----------------------
    public List<Result> getLeaderboard(int examId) {
        return getTopResults(examId, 10); // Top 10 results
    }
    public List<ResultDetail> getResultDetails(int userId, int examId) {
    List<ResultDetail> list = new ArrayList<>();

    String sql =
        "SELECT q.question, rd.selected_answer, rd.correct_answer, rd.is_correct " +
        "FROM result_details rd " +
        "JOIN questions q ON rd.question_id = q.id " +
        "WHERE rd.user_id = ? AND rd.exam_id = ?";

    try (
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql)
    ) {
        ps.setInt(1, userId);
        ps.setInt(2, examId);

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            ResultDetail rd = new ResultDetail();
            rd.setQuestion(rs.getString("question"));
            rd.setSelectedAnswer(rs.getString("selected_answer"));
            rd.setCorrectAnswer(rs.getString("correct_answer"));
            rd.setIsCorrect(rs.getBoolean("is_correct"));
            list.add(rd);
        }

        System.out.println("DAO DEBUG → rows fetched = " + list.size());

    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}

public Result getResult(int userId, int examId) {
    String sql = "SELECT score, time_taken FROM results WHERE user_id=? AND exam_id=?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ps.setInt(2, examId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            Result r = new Result();
            r.setScore(rs.getInt("score"));
            r.setTimeTaken(rs.getInt("time_taken"));
            return r;
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}

    

    
    
}















































// public List<ResultDetail> getResultDetails(int userId, int examId) {

//     List<ResultDetail> list = new ArrayList<>();

//     String sql =
//         "SELECT q.question, q.correct_answer, rd.selected_answer " +
//         "FROM result_details rd " +
//         "LEFT JOIN questions q ON rd.question_id = q.id " +
//         "WHERE rd.user_id = ? AND rd.exam_id = ?";

//     try (
//         Connection con = DBConnection.getConnection();
//         PreparedStatement ps = con.prepareStatement(sql)
//     ) {
//         ps.setInt(1, userId);
//         ps.setInt(2, examId);

//         ResultSet rs = ps.executeQuery();

//         while (rs.next()) {
//             ResultDetail rd = new ResultDetail();

//             String selected = rs.getString("selected_answer");
//             String correct  = rs.getString("correct_answer");

//             rd.setQuestion(rs.getString("question"));
//             rd.setSelectedAnswer(selected != null ? selected : "Not Answered");
//             rd.setCorrectAnswer(correct);

//             rd.setIsCorrect(
//                 selected != null &&
//                 correct != null &&
//                 selected.equalsIgnoreCase(correct)
//             );

//             list.add(rd);
//         }

//     } catch (Exception e) {
//         e.printStackTrace();
//     }

//     return list;
// }
    //=========Exam answer comparison using ResultDetail
    // public List<ResultDetail> getResultDetails(int userId, int examId) {
//     List<ResultDetail> list = new ArrayList<>();

//     String sql =
//         "SELECT q.question, rd.selected_answer, rd.correct_answer, rd.is_correct " +
//         "FROM result_details rd " +
//         "JOIN questions q ON rd.question_id = q.id " +
//         "WHERE rd.user_id = ? AND rd.exam_id = ?";

    

//     try (
//         Connection con = DBConnection.getConnection();
//         PreparedStatement ps = con.prepareStatement(sql)
//     ) {
//         ps.setInt(1, userId);
//         ps.setInt(2, examId);

//         ResultSet rs = ps.executeQuery();
//         while (rs.next()) {
//             ResultDetail rd = new ResultDetail();
//             rd.setQuestion(rs.getString("question"));
//             rd.setSelectedAnswer(rs.getString("selected_answer"));
//             rd.setCorrectAnswer(rs.getString("correct_answer"));
//             rd.setIsCorrect(rs.getBoolean("is_correct"));
//             list.add(rd);
//         }
//     } catch (Exception e) {
//         e.printStackTrace();
//     }

    
//     return list;
// }


 
    
