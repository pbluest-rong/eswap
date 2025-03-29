package com.eswap.common.constants;

import lombok.*;

import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class PageResponse<T> {
    private List<T> content;
    private int number;
    private int size;
    private int totalElements;
    private int totalPages;
    private boolean first;
    private boolean last;
}
