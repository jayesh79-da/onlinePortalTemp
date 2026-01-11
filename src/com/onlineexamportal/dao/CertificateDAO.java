// package com.onlineexamportal.dao;

// import com.onlineexamportal.model.Certificate;
// import com.onlineexamportal.util.DBConnection;

// import java.sql.*;

// public class CertificateDAO {

//     // Save certificate
//     public void saveCertificate(Certificate cert) {

//         String sql = "INSERT INTO certificates (user_id, exam_id, certificate_path) VALUES (?, ?, ?)";

//         try (Connection con = DBConnection.getConnection();
//              PreparedStatement ps = con.prepareStatement(sql)) {

//             ps.setInt(1, cert.getUserId());
//             ps.setInt(2, cert.getExamId());
//             ps.setString(3, cert.getCertificatePath());

//             ps.executeUpdate();

//         } catch (Exception e) {
//             e.printStackTrace();
//         }
//     }

//     // Check if certificate already exists
//     public Certificate getCertificate(int userId, int examId) {

//         String sql = "SELECT * FROM certificates WHERE user_id=? AND exam_id=?";
//         Certificate cert = null;

//         try (Connection con = DBConnection.getConnection();
//              PreparedStatement ps = con.prepareStatement(sql)) {

//             ps.setInt(1, userId);
//             ps.setInt(2, examId);

//             ResultSet rs = ps.executeQuery();

//             if (rs.next()) {
//                 cert = new Certificate();
//                 cert.setId(rs.getInt("id"));
//                 cert.setUserId(userId);
//                 cert.setExamId(examId);
//                 cert.setCertificatePath(rs.getString("certificate_path"));
//                 cert.setIssuedAt(rs.getTimestamp("issued_at"));
//             }

//         } catch (Exception e) {
//             e.printStackTrace();
//         }

//         return cert;
//     }
// }

package com.onlineexamportal.dao;

import com.onlineexamportal.model.Certificate;
import com.onlineexamportal.model.User;
import com.onlineexamportal.model.Exam;
import com.onlineexamportal.util.DBConnection;
import com.itextpdf.io.image.ImageData;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.sql.*;

public class CertificateDAO {

    // Save certificate (with PDF generation)
    public void saveCertificate(Certificate cert, User user, Exam exam, String realPath) {

        try {
            // ===== PDF file path =====
            String fileName = "certificate_" + user.getId() + "_" + exam.getId() + ".pdf";
            String folder = realPath + File.separator + "certificates";
            File dir = new File(folder);
            if(!dir.exists()) dir.mkdirs();
            String filePath = folder + File.separator + fileName;

            // ===== Create PDF =====
            PdfWriter writer = new PdfWriter(filePath);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            PdfFont font = PdfFontFactory.createFont(com.itextpdf.io.font.constants.StandardFonts.TIMES_ITALIC);

            // ===== Add signature image =====
            String signPath = realPath + File.separator + "images" + File.separator + "sign.jpg";
            File signFile = new File(signPath);
            if(signFile.exists()){
                ImageData imageData = ImageDataFactory.create(signPath);
                Image sign = new Image(imageData);
                sign.setWidth(150);
                sign.setFixedPosition(400, 100); // adjust as needed
                document.add(sign);
            }

            document.close();

            // ===== Save to database =====
            String sql = "INSERT INTO certificates (user_id, exam_id, certificate_path) VALUES (?, ?, ?)";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, cert.getUserId());
                ps.setInt(2, cert.getExamId());
                ps.setString(3, "certificates/" + fileName); // relative path for JSP
                ps.executeUpdate();
            }

            // update Certificate object
            cert.setCertificatePath("certificates/" + fileName);
            cert.setIssuedAt(new java.sql.Timestamp(new Date().getTime()));

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Check if certificate already exists
    public Certificate getCertificate(int userId, int examId) {

        String sql = "SELECT * FROM certificates WHERE user_id=? AND exam_id=?";
        Certificate cert = null;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, examId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                cert = new Certificate();
                cert.setId(rs.getInt("id"));
                cert.setUserId(userId);
                cert.setExamId(examId);
                cert.setCertificatePath(rs.getString("certificate_path"));
                cert.setIssuedAt(rs.getTimestamp("issued_at"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return cert;
    }
}

