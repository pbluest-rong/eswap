package com.studentswap.features.report;

import com.studentswap.features.user.User;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "profile_reports")
@Data
public class ProfileReport {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @ManyToOne
    @JoinColumn(name = "reported_user_id", nullable = false)
    private User reportedUser;

    @ManyToOne
    @JoinColumn(name = "user_report_option_id", nullable = false)
    private ProfileReportOption reportOption;

    private String descriptionDetails;
}
