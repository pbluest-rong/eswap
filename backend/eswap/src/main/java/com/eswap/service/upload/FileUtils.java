package com.eswap.service.upload;


import io.micrometer.common.util.StringUtils;
import lombok.extern.slf4j.Slf4j;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@Slf4j
public class FileUtils {

    public static byte[] readFileFromLocation(String fileName) {
        String fileUrl = "media/" + fileName;
        if (StringUtils.isBlank(fileUrl))
            return null;
        try {
            Path filePath = new File(fileUrl).toPath();
            System.out.println(filePath.toAbsolutePath());
            return Files.readAllBytes(filePath);
        } catch (IOException e) {
            log.warn("No file found in the path{}", fileUrl);
        }
        return null;
    }
}
