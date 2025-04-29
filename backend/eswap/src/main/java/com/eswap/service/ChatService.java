package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.constants.ContentType;
import com.eswap.common.constants.PageResponse;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.kafka.chat.ChatProducer;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.request.MessageRequest;
import com.eswap.response.ChatResponse;
import com.eswap.response.MessageResponse;
import com.eswap.service.upload.UploadService;
import com.google.gson.Gson;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatRepository chatRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final ChatProducer chatProducer;
    private final PostRepository postRepository;
    private final UploadService uploadService;

    // sendMessage
    public void sendMessage(Authentication connectedUser, MessageRequest request, MultipartFile[] mediaFiles) {
        User user = (User) connectedUser.getPrincipal();

        User chatPartner = userRepository
                .findById(request.getChatPartnerId())
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", request.getChatPartnerId()));

        // B1: Đảm bảo Chat tồn tại
        Chat chat = ensureChat(user, chatPartner, request.getPostId());

        // B2: Gửi Message
        Message message;
        if (request.getContentType() == ContentType.MEDIA) {
            message = sendMediaMessage(user, chatPartner, chat, mediaFiles);
        } else {
            message = sendTextMessage(user, chatPartner, chat, request);
        }
        // B3: Publish message
        chatProducer.sendPostCreatedEvent(MessageResponse.mapperToResponse(message));
    }

    private Chat ensureChat(User user, User chatPartner, Long postId) {
        Chat chat = chatRepository.findChatBetweenUsers(user.getId(), chatPartner.getId());

        if (chat == null) {
            chat = new Chat();
            chat.setUser1(user);
            chat.setUser2(chatPartner);
            chat = chatRepository.save(chat);
        }

        handlePostMessageIfNeeded(chat, user, chatPartner, postId);

        return chat;
    }

    private Message sendMediaMessage(User user, User chatPartner, Chat chat, MultipartFile[] mediaFiles) {
        List<String> urlList = new ArrayList<>();
        for (MultipartFile file : mediaFiles) {
            String url = uploadService.upload(file);
            if (url != null) {
                urlList.add(url);
            }
        }

        Gson gson = new Gson();
        String json = gson.toJson(urlList);
        System.out.println(json);

        Message message = new Message();
        message.setFromUser(user);
        message.setToUser(chatPartner);
        message.setChat(chat);
        message.setContentType(ContentType.MEDIA);
        message.setContent(json);

        chat.setLastMessageAt(message.getCreatedAt());
        chatRepository.save(chat);

        return messageRepository.save(message);
    }

    private Message sendTextMessage(User user, User chatPartner, Chat chat, MessageRequest request) {
        Message message = new Message();
        message.setFromUser(user);
        message.setToUser(chatPartner);
        message.setChat(chat);
        message.setContentType(request.getContentType());
        message.setContent(request.getContent());

        chat.setLastMessageAt(message.getCreatedAt());
        chatRepository.save(chat);
        return messageRepository.save(message);
    }

    private void handlePostMessageIfNeeded(Chat chat, User user, User chatPartner, long postId) {
        if (chat.getCurrentPost() == null || chat.getCurrentPost().getId() != postId) {
            Post post = postRepository.findByIdAndConnectedUser(postId, user)
                    .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.POST_NOT_FOUND, postId));

            chat.setCurrentPost(post);
            chatRepository.save(chat);

            Message postMessage = new Message();
            postMessage.setFromUser(user);
            postMessage.setToUser(chatPartner);
            postMessage.setChat(chat);
            postMessage.setContentType(ContentType.POST);
            postMessage.setContent(convertPostMessage(post));
            messageRepository.save(postMessage);

            chatProducer.sendPostCreatedEvent(MessageResponse.mapperToResponse(postMessage));
        }
    }


    private String convertPostMessage(Post post) {
        String safeName = post.getName().replace("\"", "\\\"");
        String safeFirstMediaUrl = post.getMedia().get(0).getOriginalUrl().replace("\"", "\\\"");
        return "{" +
                "\"id\":" + post.getId() + "," +
                "\"firstMediaUrl\":\"" + safeFirstMediaUrl + "\"," +
                "\"postName\":\"" + safeName + "\"," +
                "\"salePrice\":" + post.getSalePrice() +
                "}";
    }


    public PageResponse<MessageResponse> getMessages(Authentication connectedUser, long chatPartnerId, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        User chatPartner = userRepository
                .findById(chatPartnerId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND,
                        "id", chatPartnerId));
        Pageable pageable = PageRequest.of(page, size);
        Page<Message> messages = messageRepository.getMessage(user.getId(), chatPartner.getId(), pageable);
        List<MessageResponse> messageResponses = messages.stream().map(
                message -> {
                    return MessageResponse.mapperToResponse(message);
                }
        ).collect(Collectors.toList());
        return new PageResponse<>(
                messageResponses,
                messages.getNumber(),
                messages.getSize(),
                (int) messages.getTotalElements(),
                messages.getTotalPages(),
                messages.isFirst(),
                messages.isLast()
        );
    }

    public ChatResponse getChatInfo(Authentication connectedUser, long chatPartnerId) {
        User user = (User) connectedUser.getPrincipal();
        User chatPartner = userRepository
                .findById(chatPartnerId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND,
                        "id", chatPartnerId));

        Chat chat = chatRepository.findChatBetweenUsers(user.getId(), chatPartner.getId());

        if (chat == null)
            throw new ResourceNotFoundException(AppErrorCode.CHAT_NOT_FOUND, "chat partnerId", chatPartnerId);

        int unReadMessageNumber = messageRepository.countUnreadMessagesFromSender(user.getId(), chatPartner.getId());
        return ChatResponse.builder()
                .id(chat.getId())
                .chatPartnerId(chatPartner.getId())
                .chatPartnerAvatarUrl(chatPartner.getAvatarUrl())
                .chatPartnerFirstName(chatPartner.getFirstName())
                .chatPartnerLastName(chatPartner.getLastName())
                .educationInstitutionId(chatPartner.getEducationInstitution().getId())
                .educationInstitutionName(chatPartner.getEducationInstitution().getName())
                .currentPostId(chat.getCurrentPost().getId())
                .currentPostName(chat.getCurrentPost().getName())
                .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                .unReadMessageNumber(unReadMessageNumber)
                .build();
    }

    public PageResponse<ChatResponse> getChats(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();


        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "lastMessageAt"));
        Page<Chat> chats = chatRepository.findAll(pageable);
        List<ChatResponse> chatResponses = chats.stream().map(
                chat -> {
                    User chatPartner = chat.getUser1().getId() == user.getId() ? chat.getUser2() : chat.getUser1();
                    Message mostRecentMessage = messageRepository.findTopByChatOrderByCreatedAtDesc(chat);
                    int unReadMessageNumber = messageRepository.countUnreadMessagesFromSender(user.getId(), chatPartner.getId());
                    return ChatResponse.builder()
                            .id(chat.getId())
                            .chatPartnerId(chatPartner.getId())
                            .chatPartnerAvatarUrl(chatPartner.getAvatarUrl())
                            .chatPartnerFirstName(chatPartner.getFirstName())
                            .chatPartnerLastName(chatPartner.getLastName())
                            .educationInstitutionId(chatPartner.getEducationInstitution().getId())
                            .educationInstitutionName(chatPartner.getEducationInstitution().getName())
                            .currentPostId(chat.getCurrentPost().getId())
                            .currentPostName(chat.getCurrentPost().getName())
                            .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                            .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                            .mostRecentMessage(mostRecentMessage == null ? null : MessageResponse.mapperToResponse(mostRecentMessage))
                            .unReadMessageNumber(unReadMessageNumber)
                            .build();
                }
        ).collect(Collectors.toList());
        return new PageResponse<>(
                chatResponses,
                chats.getNumber(),
                chats.getSize(),
                (int) chats.getTotalElements(),
                chats.getTotalPages(),
                chats.isFirst(),
                chats.isLast()
        );
    }
}
