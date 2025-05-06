package com.eswap.model;

import com.eswap.common.constants.DealAgreementStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.OffsetDateTime;

@Entity
@Table(name = "deal_agreements")
@Getter
@Setter
public class DealAgreement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    @ManyToOne
    private Post post;
    @ManyToOne
    private User buyer;
    private int quantity;
    @Enumerated(EnumType.STRING)
    private DealAgreementStatus status;
    private OffsetDateTime requestAt;
    private OffsetDateTime completedAt;
}