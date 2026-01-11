package com.onlineexamportal.controller;

import com.onlineexamportal.dao.CertificateDAO;
import com.onlineexamportal.dao.ExamDAO;
import com.onlineexamportal.dao.ResultDAO;
import com.onlineexamportal.model.Certificate;
import com.onlineexamportal.model.Exam;
import com.onlineexamportal.model.Result;
import com.onlineexamportal.model.User;
// import com.onlineexamportal.util.PDFGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;

@WebServlet("/certificate")
public class CertificateServlet extends HttpServlet {

    private CertificateDAO certificateDAO = new CertificateDAO();
    private ExamDAO examDAO = new ExamDAO();
    private ResultDAO resultDAO = new ResultDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int examId;
        try {
            examId = Integer.parseInt(request.getParameter("examId"));
        } catch (Exception e) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Check if the user completed the exam
        Result result = resultDAO.getResultByUserAndExam(user.getId(), examId);
        if (result == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        


        Exam exam = examDAO.getExamById(examId);
        if (exam == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int rank = examDAO.getUserRank(user.getId(), examId);

        // Only top 3 get rank badge
        if (rank >= 1 && rank <= 3) {
            request.setAttribute("rank", rank);
        } else {
            request.setAttribute("rank", null);
        }

        
        // Check if certificate already exists
        Certificate certificate = certificateDAO.getCertificate(user.getId(), examId);
        if (certificate == null) {
            // Folder creation
            String certDirPath = getServletContext().getRealPath("/") + "certificates";
            File certDir = new File(certDirPath);
            if (!certDir.exists()) {
                certDir.mkdirs();
            }

            String safeUserName = user.getName().replaceAll("[^a-zA-Z0-9]", "_");
            String fileName = safeUserName + "_Exam_" + examId + ".pdf";
            String filePath = certDirPath + File.separator + fileName;

          

            certificate = new Certificate();
            certificate.setUserId(user.getId());
            certificate.setExamId(examId);
            certificate.setCertificatePath("certificates/" + fileName);

            certificateDAO.saveCertificate(certificate,user,exam,certificate.getCertificatePath());
        }

        // Format issued date
        String dateStr;
        if (certificate.getIssuedAt() != null) {
            dateStr = certificate.getIssuedAt().toLocalDateTime()
                    .format(DateTimeFormatter.ofPattern("dd MMMM yyyy"));
        } else {
            dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd MMMM yyyy"));
        }

        request.setAttribute("userName", user.getName());
        request.setAttribute("examName", exam.getName());
        request.setAttribute("date", dateStr);
        request.setAttribute("certificatePath", certificate.getCertificatePath());

        // Forward to JSP
        request.getRequestDispatcher("certificate.jsp").forward(request, response);
    }
}

