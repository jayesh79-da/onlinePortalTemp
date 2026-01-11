//-------------------------------------------------
package com.onlineexamportal.controller;

import com.onlineexamportal.dao.ExamDAO;
import com.onlineexamportal.dao.QuestionDAO;
import com.onlineexamportal.dao.ResultDAO;
import com.onlineexamportal.model.Exam;
import com.onlineexamportal.model.Question;
import com.onlineexamportal.model.Result;
import com.onlineexamportal.model.User;
import com.onlineexamportal.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;
import java.util.Map;

@WebServlet("/exam")
public class ExamServlet extends HttpServlet 
{

    private ExamDAO examDAO = new ExamDAO();
    private QuestionDAO questionDAO = new QuestionDAO();
    private ResultDAO resultDAO = new ResultDAO();

    // ===================== LOAD EXAM =====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        if (user == null) 
        {
            response.sendRedirect("login.jsp");
            return;
        }

        
        int examId = Integer.parseInt(request.getParameter("examId"));
        Boolean started = (Boolean) session.getAttribute("examStarted_" + examId);

        if (started == null || !started) {
          // First time → show instructions
        //session.setAttribute("examStarted_" + examId, true);

            Exam exam = examDAO.getExamById(examId);
             int questionCount = questionDAO.getQuestionsByExam(examId).size();

            request.setAttribute("exam", exam);
            request.setAttribute("questionCount", questionCount); 

            request.getRequestDispatcher("instructions.jsp").forward(request, response);
            return;
        }
        
        //  BLOCK IF EXAM ALREADY COMPLETED
        Boolean completed = (Boolean) session.getAttribute("examCompleted_" + examId);
        if (completed != null && completed) {
            response.sendRedirect("result.jsp?examId=" +examId);
            return;
        }
        
        //  BLOCK RE-ATTEMPT FROM DATABASE
        Result existing = resultDAO.getResultByUserAndExam(user.getId(), examId);
        if (existing != null) {
            response.sendRedirect("result.jsp?examId=" + examId);
            return;
        }
        
        Exam exam = examDAO.getExamById(examId);
        List<Question> questions = questionDAO.getQuestionsByExam(examId);
        
        if (questions == null || questions.isEmpty()) {
            response.sendRedirect("dashboard.jsp?error=NoQuestions");
            return;
        }

        // Get existing start time from session or set new
        Long startTime = (Long) session.getAttribute("examStartTime_" + examId);
        if (startTime == null) {
                startTime = System.currentTimeMillis();
                session.setAttribute("examStartTime_" + examId, startTime);
                }

        long examDurationMs = exam.getDuration() * 60 * 1000L; // exam duration in ms
        long elapsedMs = System.currentTimeMillis() - startTime;
        long remainingSeconds = (examDurationMs - elapsedMs) / 1000;
        if (remainingSeconds < 0) remainingSeconds = 0;

        request.setAttribute("exam", exam);
        request.setAttribute("questions", questions);
        request.setAttribute("remainingSeconds", remainingSeconds); 

        request.getRequestDispatcher("exam.jsp").forward(request, response);
    }
 

@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession(false);
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int examId = Integer.parseInt(request.getParameter("examId"));

    //  DOUBLE SUBMISSION BLOCK
    Boolean completed = (Boolean) session.getAttribute("examCompleted_" + examId);
    if (completed != null && completed) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    // --- Check if this is just the "start exam" click ---
    Boolean started = (Boolean) session.getAttribute("examStarted_" + examId);
    if (started == null || !started) {
        session.setAttribute("examStarted_" + examId, true);
        session.setAttribute("examStartTime_" + examId, System.currentTimeMillis());

        // Redirect to GET → loads exam.jsp
        response.sendRedirect("exam?examId=" + examId);
        return;  // <--- important, exit after redirect
    }

    // =================== EXAM SUBMISSION ===================
    List<Question> questions = questionDAO.getQuestionsByExam(examId);
    int score = 0;

    for (Question q : questions) {
        String selected = request.getParameter("q" + q.getId());
        boolean correct = selected != null && q.getAnswer() != null && selected.equals(q.getAnswer());
        if (correct) score++;

        String sql = "INSERT INTO result_details (user_id, exam_id, question_id, selected_answer, correct_answer, is_correct) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user.getId());
            ps.setInt(2, examId);
            ps.setInt(3, q.getId());
            ps.setString(4, selected != null ? selected : "Not Answered");
            ps.setString(5, q.getAnswer() != null ? q.getAnswer() : "Not Provided");
            ps.setBoolean(6, correct);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // --- Calculate Time Taken ---
    Long startTime = (Long) session.getAttribute("examStartTime_" + examId);
    int timeTakenSeconds = 0;
    if (startTime != null) {
        timeTakenSeconds = (int) ((System.currentTimeMillis() - startTime) / 1000);
    }

    // --- Save total score and time in results table ---
    Result result = new Result();
    result.setUserId(user.getId());
    result.setExamId(examId);
    result.setScore(score);
    result.setTimeTaken(timeTakenSeconds);
    resultDAO.saveResult(result);

    //  FINAL EXAM TERMINATION
    session.setAttribute("examCompleted_" + examId, true);

    // Redirect to result page
    response.sendRedirect("result.jsp?examId=" + examId);
}



    
}   



















































//     //===========EXAM submission===============
//     @Override
//     protected void doPost(HttpServletRequest request, HttpServletResponse response)
//         throws ServletException, IOException {

//         HttpSession session = request.getSession(false);
//         User user = (User) session.getAttribute("user");

//         if (user == null) {
//             response.sendRedirect("login.jsp");
//             return;
//         }

//         int examId = Integer.parseInt(request.getParameter("examId"));

//         //  DOUBLE SUBMISSION BLOCK
//         Boolean completed = (Boolean) session.getAttribute("examCompleted_" + examId);
//         if (completed != null && completed) {
//             response.sendRedirect("dashboard.jsp");
//             return;
//         }

//         // Start exam only if not started yet
//         Boolean started = (Boolean) session.getAttribute("examStarted_" + examId);
//         if (started == null || !started) {
//             session.setAttribute("examStarted_" + examId, true);
//             session.setAttribute("examStartTime_" + examId, System.currentTimeMillis());
//         }   

//         // Redirect to GET → loads exam.jsp
//         response.sendRedirect("exam?examId=" + examId);

    
//     List<Question> questions = questionDAO.getQuestionsByExam(examId);
//     int score = 0;

//    for (Question q : questions) {
//     String selected = request.getParameter("q" + q.getId());

//     // --- Null-safe correctness check ---
//     boolean correct = selected != null && q.getAnswer() != null && selected.equals(q.getAnswer());
//     if (correct) score++;

//     // --- Insert into result_details ---
//     String sql = "INSERT INTO result_details (user_id, exam_id, question_id, selected_answer, correct_answer, is_correct) "
//             + "VALUES (?, ?, ?, ?, ?, ?)";
//     try (Connection conn = DBConnection.getConnection();
//          PreparedStatement ps = conn.prepareStatement(sql)) {
//         ps.setInt(1, user.getId());
//         ps.setInt(2, examId);
//         ps.setInt(3, q.getId());
//         ps.setString(4, selected != null ? selected : "Not Answered");
//         ps.setString(5, q.getAnswer() != null ? q.getAnswer() : "Not Provided");
//         ps.setBoolean(6, correct);
//         ps.executeUpdate();
//     } catch(Exception e) {
//         e.printStackTrace();
//     }
// }

//     // --- Calculate Time Taken ---
//     Long startTime = (Long) session.getAttribute("examStartTime_" + examId);
//     int timeTakenSeconds = 0;
//     if (startTime != null) {
//         timeTakenSeconds = (int) ((System.currentTimeMillis() - startTime) / 1000);
//     }

//     // --- Save total score and time in results table ---
//     Result result = new Result();
//     result.setUserId(user.getId());
//     result.setExamId(examId);
//     result.setScore(score);
//     result.setTimeTaken(timeTakenSeconds); // <-- fixed time taken
//     resultDAO.saveResult(result);

//     //  FINAL EXAM TERMINATION
//     session.setAttribute("examCompleted_" + examId, true);

//     response.sendRedirect("result.jsp?examId=" + examId);

// }
