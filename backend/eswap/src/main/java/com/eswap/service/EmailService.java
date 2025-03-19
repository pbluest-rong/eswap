package com.eswap.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;

@Service
@RequiredArgsConstructor
public class EmailService {
    private final JavaMailSender mailSender;
    @Value("${spring.mail.username}")
    private String senderEmail;

    @Async
    public void sendMail(String to, String subject, String body, long minutes) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, MimeMessageHelper.MULTIPART_MODE_MIXED, StandardCharsets.UTF_8.name());

        helper.setFrom(senderEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(body, true);

        mailSender.send(mimeMessage);
    }

    public String buildVerificationEmail(String code, long minutes) {
        return """
            <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f4f4;">
                <div style="max-width: 600px; margin: auto; background: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
                    <h2 style="color: #333333;">🔒 Xác thực Email</h2>
                    <p>Xin chào,</p>
                    <p>Chúng tôi đã nhận được yêu cầu xác thực email từ bạn. Vui lòng sử dụng mã bên dưới để hoàn tất quá trình đăng ký:</p>
                    <div style="font-size: 24px; font-weight: bold; color: #4CAF50; padding: 10px 0;">%s</div>
                    <p><b>Lưu ý:</b> Mã xác thực chỉ có hiệu lực trong vòng <span style="color: red;">%d phút</span> và chỉ sử dụng được <span style="color: red;">1 lần</span>.</p>
                    <p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này.</p>
                    <p>Trân trọng,<br/>Đội ngũ StudentSwap</p>
                </div>
            </div>
            """.formatted(code, minutes);
    }
}