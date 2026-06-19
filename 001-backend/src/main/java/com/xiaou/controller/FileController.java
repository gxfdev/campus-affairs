package com.xiaou.controller;

import com.xiaou.common.Result;
import com.xiaou.entity.User;
import com.xiaou.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/api/file")
public class FileController {

    @Value("${file.upload-path:./uploads}")
    private String uploadPath;

    @Value("${file.access-path:/uploads}")
    private String accessPath;

    @Autowired
    private UserService userService;

    @PostMapping("/upload/avatar")
    public Result<String> uploadAvatar(@RequestParam("file") MultipartFile file, HttpServletRequest request) {
        if (file.isEmpty()) {
            return Result.error(400, "请选择文件");
        }
        // 检查文件类型
        String contentType = file.getContentType();
        if (contentType == null || (!contentType.equals("image/jpeg") && !contentType.equals("image/png") && !contentType.equals("image/jpg"))) {
            return Result.error(400, "仅支持JPG和PNG格式");
        }
        // 检查文件大小（5MB）
        if (file.getSize() > 5 * 1024 * 1024) {
            return Result.error(400, "文件大小不能超过5MB");
        }
        // 生成文件名
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".jpg";
        String fileName = UUID.randomUUID().toString().replace("-", "") + extension;
        // 保存文件 - 使用绝对路径避免 transferTo 相对路径解析问题
        Path uploadDir = Paths.get(uploadPath, "avatar").toAbsolutePath().normalize();
        try {
            Files.createDirectories(uploadDir);
        } catch (IOException e) {
            log.error("创建上传目录失败: {}", uploadDir, e);
            return Result.error(500, "创建上传目录失败");
        }
        File destFile = uploadDir.resolve(fileName).toFile();
        try {
            file.transferTo(destFile);
            log.info("头像上传成功: {} -> {}", originalFilename, destFile.getAbsolutePath());
        } catch (IOException e) {
            log.error("文件上传失败: dest={}", destFile.getAbsolutePath(), e);
            return Result.error(500, "文件上传失败");
        }
        // 返回访问路径
        String avatarUrl = accessPath + "/avatar/" + fileName;
        // 更新用户头像
        Long userId = (Long) request.getAttribute("userId");
        User user = new User();
        user.setId(userId);
        user.setAvatar(avatarUrl);
        userService.updateById(user);
        return Result.success(avatarUrl);
    }
}
