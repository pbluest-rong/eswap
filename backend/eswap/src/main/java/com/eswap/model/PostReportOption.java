package com.eswap.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "post_report_options")
@Data
public class PostReportOption {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    private String title;
    private String level;
    private String description;
}
