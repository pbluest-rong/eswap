package com.eswap.service.upload.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.eswap.service.upload.UploadService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UploadCloudinaryServiceImpl implements UploadService {
    private final Cloudinary cloudinary;

    @Override
    public String upload(@NonNull MultipartFile sourceFile) {
        String resourceType = detectResourceType(sourceFile);
        try {
            String publicId = generatePublicValue(sourceFile.getOriginalFilename());
            Map uploadResult = cloudinary.uploader().upload(
                    sourceFile.getBytes(),
                    ObjectUtils.asMap(
                            "resource_type", resourceType,
                            "public_id", publicId
                    )
            );
            String url = uploadResult.get("secure_url").toString();
            return url;
        } catch (IOException e) {
            throw new RuntimeException("Upload " + resourceType + " failed", e);
        }
    }

    private String detectResourceType(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null) return "raw"; // Không xác định -> raw

        if (contentType.startsWith("image/")) return "image";
        if (contentType.startsWith("video/")) return "video";

        return "raw"; // Mặc định raw cho các loại khác
    }

    public String generatePublicValue(String originalName) {
        String filename = extractFileNameWithoutExtension(originalName);
        return UUID.randomUUID() + "_" + filename;
    }

    public String extractFileNameWithoutExtension(String originalName) {
        if (originalName == null || !originalName.contains(".")) {
            return originalName;
        }
        return originalName.substring(0, originalName.lastIndexOf('.'));
    }
    @Override
    public void deleteByUrl(@NonNull String url) {

    }
}
