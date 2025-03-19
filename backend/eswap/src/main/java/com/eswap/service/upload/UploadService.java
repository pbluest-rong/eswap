package com.eswap.service.upload;

import lombok.NonNull;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface UploadService {
    String upload(@NonNull MultipartFile sourceFile);
    void deleteByUrl(@NonNull String url);
}