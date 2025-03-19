package com.eswap.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "post_reports")
@Data
public class PostReport {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @ManyToOne
    @JoinColumn(name = "reported_post_id", nullable = false)
    private Post reportedPost;

    @ManyToOne
    @JoinColumn(name = "post_report_option_id", nullable = false)
    private PostReportOption reportOption;

    private String descriptionDetails;
}
