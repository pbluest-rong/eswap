package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.request.MessageRequest;
import com.eswap.response.ChatResponse;
import com.eswap.response.MessageResponse;
import com.eswap.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("chats")
@RequiredArgsConstructor
public class ChatController {
    private final ChatService chatService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public void sendMessage(
            Authentication auth,
            @RequestPart("message") MessageRequest request,
            @RequestPart(value = "mediaFiles", required = false) MultipartFile[] mediaFiles
    ) {
        chatService.sendMessage(auth, request, mediaFiles);
    }


    @GetMapping("/{chatPartnerId}/messages")
    public ResponseEntity<ApiResponse> getMessages(Authentication auth,
                                                   @PathVariable("chatPartnerId") long chatPartnerId,
                                                   @RequestParam(defaultValue = "0") int page,
                                                   @RequestParam(defaultValue = "15") int size) {
        PageResponse<MessageResponse> messages = chatService.getMessages(auth, chatPartnerId, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "messages", messages));
    }

    @GetMapping
    public ResponseEntity<ApiResponse> getChats(Authentication auth,
                                                @RequestParam(required = false) String keyword,
                                                @RequestParam(defaultValue = "0") int page,
                                                @RequestParam(defaultValue = "20") int size
    ) {
        PageResponse<ChatResponse> chats = chatService.getChats(keyword,auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "chats", chats));
    }

    @GetMapping("/{chatPartnerId}")
    public ResponseEntity<ApiResponse> getChatInfo(Authentication auth,
                                                   @PathVariable("chatPartnerId") long chatPartnerId,
                                                   @RequestParam(defaultValue = "0") int page,
                                                   @RequestParam(defaultValue = "20") int size) {
        ChatResponse chat = chatService.getChatInfo(auth, chatPartnerId);
        return ResponseEntity.ok(new ApiResponse(true, "chat info", chat));
    }

    @PutMapping("/{chatPartnerId}")
    public void markAsRead(Authentication auth, @PathVariable(name = "chatPartnerId") Long chatPartnerId) {
        chatService.markAsRead(auth, chatPartnerId);
    }
}
