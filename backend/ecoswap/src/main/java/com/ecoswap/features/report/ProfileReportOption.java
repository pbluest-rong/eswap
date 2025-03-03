package com.ecoswap.features.report;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "profile_report_options")
@Data
public class ProfileReportOption {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    private String title;
    private String level;
    private String description;
}
