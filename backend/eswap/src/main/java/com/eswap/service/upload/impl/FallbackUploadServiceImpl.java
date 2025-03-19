package com.eswap.service.upload.impl;

import com.eswap.service.upload.UploadService;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Service
@Primary
@Slf4j
public class FallbackUploadServiceImpl implements UploadService {
    private final UploadService cloudinaryService;
    private final UploadService storageService;

    public FallbackUploadServiceImpl(
            @Qualifier("uploadCloudinaryServiceImpl") UploadService cloudinaryService,
            @Qualifier("uploadDirectServerServiceImpl") UploadService storageService) {
        this.cloudinaryService = cloudinaryService;
        this.storageService = storageService;
    }

    @Override
    public String upload(@NonNull MultipartFile sourceFile) {
        try {
            return cloudinaryService.upload(sourceFile);
        } catch (Exception ex) {
            log.error("Cloudinary upload failed, fallback to local storage", ex);
            return storageService.upload(sourceFile);
        }
    }

    @Override
    public void deleteByUrl(@NonNull String url) {

    }
}
