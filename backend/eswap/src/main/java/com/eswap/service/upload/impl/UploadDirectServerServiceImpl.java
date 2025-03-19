package com.eswap.service.upload.impl;

import com.eswap.service.upload.UploadService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class UploadDirectServerServiceImpl implements UploadService {
    @Value("${spring.application.file.upload.media-output-path}")
    private String fileUploadPath;

    @Override
    public String upload(@NonNull MultipartFile sourceFile) {
        String fileName = System.currentTimeMillis() + "." + getFileExtension(sourceFile.getOriginalFilename());
        String targetFilePath = fileUploadPath + File.separator + fileName;

        Path targetPath = Paths.get(targetFilePath);
        try {
            Files.write(targetPath, sourceFile.getBytes());
            log.info("File saved to " + targetFilePath);
            String url = fileName;
            return url;
        } catch (IOException e) {
            log.error("File was not saved", e);
            return null;
        }
    }

    private String getFileExtension(String originalFilename) {
        if (originalFilename == null || originalFilename.isEmpty())
            return "";
        int lastDotIndex = originalFilename.lastIndexOf(".");
        if (lastDotIndex == -1)
            return "";
        return originalFilename.substring(lastDotIndex + 1).toLowerCase();
    }
    @Override
    public void deleteByUrl(@NonNull String url) {

    }
}
