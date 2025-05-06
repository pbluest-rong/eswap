package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.constants.ContentType;
import com.eswap.common.constants.DealAgreementStatus;
import com.eswap.common.constants.PageResponse;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.kafka.chat.ChatProducer;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.request.MessageRequest;
import com.eswap.response.ChatResponse;
import com.eswap.response.DealAgreementResponse;
import com.eswap.response.MessageResponse;
import com.eswap.service.upload.UploadService;
import com.google.gson.Gson;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.OffsetDateTime;
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
    private final DealAgreementRepository dealAgreementRepository;

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
        // gửi cho chính mình
        ChatResponse chatResponse = ChatResponse.builder()
                .id(chat.getId())
                .chatPartnerId(chatPartner.getId())
                .chatPartnerAvatarUrl(chatPartner.getAvatarUrl())
                .chatPartnerFirstName(chatPartner.getFirstName())
                .chatPartnerLastName(chatPartner.getLastName())
                .educationInstitutionId(chatPartner.getEducationInstitution().getId())
                .educationInstitutionName(chatPartner.getEducationInstitution().getName())
                .currentPostId(chat.getCurrentPost().getId())
                .currentPostUserId(chat.getCurrentPost().getUser().getId())
                .currentPostName(chat.getCurrentPost().getName())
                .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                .quantity(chat.getCurrentPost().getQuantity())
                .sold(chat.getCurrentPost().getSold())
                .mostRecentMessage(MessageResponse.mapperToResponse(message))
                .unReadMessageNumber(0)
                .forMe(true)
                .build();
        chatProducer.sendPostCreatedEvent(chatResponse);

        // gửi message cho chatpartner
        int unReadMessageNumber = messageRepository.countUnreadMessagesFromSender(chatPartner.getId(), user.getId());
        chatResponse = ChatResponse.builder()
                .id(chat.getId())
                .chatPartnerId(user.getId())
                .chatPartnerAvatarUrl(user.getAvatarUrl())
                .chatPartnerFirstName(user.getFirstName())
                .chatPartnerLastName(user.getLastName())
                .educationInstitutionId(user.getEducationInstitution().getId())
                .educationInstitutionName(user.getEducationInstitution().getName())
                .currentPostId(chat.getCurrentPost().getId())
                .currentPostUserId(chat.getCurrentPost().getUser().getId())
                .currentPostName(chat.getCurrentPost().getName())
                .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                .quantity(chat.getCurrentPost().getQuantity())
                .sold(chat.getCurrentPost().getSold())
                .mostRecentMessage(MessageResponse.mapperToResponse(message))
                .unReadMessageNumber(unReadMessageNumber)
                .forMe(false)
                .build();
        chatProducer.sendPostCreatedEvent(chatResponse);
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

        Message savedMessage = messageRepository.save(message);
        chat.setLastMessageAt(savedMessage.getCreatedAt());
        chatRepository.save(chat);

        return savedMessage;
    }

    private Message sendTextMessage(User user, User chatPartner, Chat chat, MessageRequest request) {
        Message message = new Message();
        message.setFromUser(user);
        message.setToUser(chatPartner);
        message.setChat(chat);
        message.setContentType(request.getContentType());
        message.setContent(request.getContent());
        Message savedMessage = messageRepository.save(message);
        chat.setLastMessageAt(savedMessage.getCreatedAt());
        chatRepository.save(chat);
        return savedMessage;
    }

    private void handlePostMessageIfNeeded(Chat chat, User user, User chatPartner, long postId) {
        if (chat.getCurrentPost() == null || chat.getCurrentPost().getId() != postId) {
            Post post = postRepository.findByIdAndConnectedUser(postId, user)
                    .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.POST_NOT_FOUND, postId));

            chat.setCurrentPost(post);
            chatRepository.save
                    (chat);

            Message postMessage = new Message();
            postMessage.setFromUser(user);
            postMessage.setToUser(chatPartner);
            postMessage.setChat(chat);
            postMessage.setContentType(ContentType.POST);
            postMessage.setContent(convertPostMessage(post));
            postMessage = messageRepository.save(postMessage);

            // gửi cho chính mình
            ChatResponse chatResponseForSender = ChatResponse.builder()
                    .id(chat.getId())
                    .chatPartnerId(chatPartner.getId())
                    .chatPartnerAvatarUrl(chatPartner.getAvatarUrl())
                    .chatPartnerFirstName(chatPartner.getFirstName())
                    .chatPartnerLastName(chatPartner.getLastName())
                    .educationInstitutionId(chatPartner.getEducationInstitution().getId())
                    .educationInstitutionName(chatPartner.getEducationInstitution().getName())
                    .currentPostId(chat.getCurrentPost().getId())
                    .currentPostUserId(chat.getCurrentPost().getUser().getId())
                    .currentPostName(chat.getCurrentPost().getName())
                    .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                    .quantity(chat.getCurrentPost().getQuantity())
                    .sold(chat.getCurrentPost().getSold())
                    .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                    .mostRecentMessage(MessageResponse.mapperToResponse(postMessage))
                    .unReadMessageNumber(0)
                    .forMe(true)
                    .build();
            chatProducer.sendPostCreatedEvent(chatResponseForSender);

            // gửi message cho chatpartner
            int unReadMessageNumber = messageRepository.countUnreadMessagesFromSender(chatPartner.getId(), user.getId());
            System.out.println("1 =====================>>>> " + unReadMessageNumber);
            ChatResponse chatResponseForChatPartner = ChatResponse.builder()
                    .id(chat.getId())
                    .chatPartnerId(user.getId())
                    .chatPartnerAvatarUrl(user.getAvatarUrl())
                    .chatPartnerFirstName(user.getFirstName())
                    .chatPartnerLastName(user.getLastName())
                    .educationInstitutionId(user.getEducationInstitution().getId())
                    .educationInstitutionName(user.getEducationInstitution().getName())
                    .currentPostId(chat.getCurrentPost().getId())
                    .currentPostUserId(chat.getCurrentPost().getUser().getId())
                    .currentPostName(chat.getCurrentPost().getName())
                    .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                    .quantity(chat.getCurrentPost().getQuantity())
                    .sold(chat.getCurrentPost().getSold())
                    .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                    .mostRecentMessage(MessageResponse.mapperToResponse(postMessage))
                    .unReadMessageNumber(unReadMessageNumber)
                    .forMe(false)
                    .build();
            chatProducer.sendPostCreatedEvent(chatResponseForChatPartner);
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

        User buyer = chat.getUser1().getId() == chat.getCurrentPost().getUser().getId() ? chat.getUser2() : chat.getUser1();
        DealAgreement dealAgreement = dealAgreementRepository.findWaitingDealAgreement(
                chat.getCurrentPost().getId(),
                buyer.getId()
        ).orElse(null);

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
                .currentPostUserId(chat.getCurrentPost().getUser().getId())
                .currentPostName(chat.getCurrentPost().getName())
                .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                .quantity(chat.getCurrentPost().getQuantity())
                .sold(chat.getCurrentPost().getSold())
                .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                .unReadMessageNumber(unReadMessageNumber)
                .status(dealAgreement != null ? dealAgreement.getStatus() : null)
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

                    User buyer = chat.getUser1().getId() == chat.getCurrentPost().getUser().getId() ? chat.getUser2() : chat.getUser1();
                    DealAgreement dealAgreement = dealAgreementRepository.findWaitingDealAgreement(
                            chat.getCurrentPost().getId(),
                            buyer.getId()
                    ).orElse(null);
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
                            .currentPostUserId(chat.getCurrentPost().getUser().getId())
                            .currentPostName(chat.getCurrentPost().getName())
                            .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                            .quantity(chat.getCurrentPost().getQuantity())
                            .sold(chat.getCurrentPost().getSold())
                            .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                            .mostRecentMessage(mostRecentMessage == null ? null : MessageResponse.mapperToResponse(mostRecentMessage))
                            .unReadMessageNumber(unReadMessageNumber)
                            .status(dealAgreement != null ? dealAgreement.getStatus() : null)
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

    @Transactional
    public void markAsRead(Authentication connectedUser, Long chatPartnerId) {
        User user = (User) connectedUser.getPrincipal();
        chatRepository.markAsRead(user.getId(), chatPartnerId);
    }

    public DealAgreementResponse getWaitingDealAgreement(Authentication connectedUser, long postId, long buyerId) {
        DealAgreement dealAgreement = dealAgreementRepository.findWaitingDealAgreement(postId, buyerId).orElse(null);
        if (dealAgreement == null)
            return null;
        DealAgreementResponse dealAgreementResponse = DealAgreementResponse.builder()
                .id(dealAgreement.getId())
                .postId(dealAgreement.getPost().getId())
                .firstMediaUrl(dealAgreement.getPost().getMedia().get(0).getOriginalUrl())
                .postName(dealAgreement.getPost().getName())
                .originalPrice(dealAgreement.getPost().getOriginalPrice())
                .salePrice(dealAgreement.getPost().getSalePrice())
                .quantity(dealAgreement.getQuantity())
                .sellerFirstName(dealAgreement.getPost().getUser().getFirstName())
                .sellerLastName(dealAgreement.getPost().getUser().getLastName())
                .buyerFirstName(dealAgreement.getBuyer().getFirstName())
                .buyerLastName(dealAgreement.getBuyer().getLastName())
                .requestAt(dealAgreement.getRequestAt())
                .completedAt(dealAgreement.getCompletedAt())
                .status(dealAgreement.getStatus())
                .build();
        return dealAgreementResponse;
    }


    public DealAgreementResponse requestDealAgreement(Authentication connectedUser, long postId, long buyerId, int quantity) {
        User user = (User) connectedUser.getPrincipal();

        User buyer = userRepository.findById(buyerId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, buyerId));

        Post post = postRepository.findByIdAndConnectedUser(postId, user).orElseThrow(() -> new ResourceNotFoundException(
                AppErrorCode.POST_NOT_FOUND, postId));


        if (user.getId() == post.getUser().getId()) {
            DealAgreement dealAgreement = new DealAgreement();
            dealAgreement.setPost(post);
            dealAgreement.setBuyer(buyer);
            dealAgreement.setQuantity(quantity);
            dealAgreement.setStatus(DealAgreementStatus.WAITING);
            dealAgreement.setRequestAt(OffsetDateTime.now());

            dealAgreement = dealAgreementRepository.save(dealAgreement);

            DealAgreementResponse response = DealAgreementResponse.builder()
                    .id(dealAgreement.getId())
                    .postId(post.getId())
                    .firstMediaUrl(post.getMedia().get(0).getOriginalUrl())
                    .postName(post.getName())
                    .originalPrice(post.getOriginalPrice())
                    .salePrice(post.getSalePrice())
                    .quantity(quantity)
                    .sellerFirstName(user.getFirstName())
                    .sellerLastName(user.getLastName())
                    .buyerFirstName(buyer.getFirstName())
                    .buyerLastName(buyer.getLastName())
                    .requestAt(dealAgreement.getRequestAt())
                    .status(dealAgreement.getStatus())
                    .build();

            handleDealMessage(user, buyer, response);
            return response;
        }
        return null;
    }

    public DealAgreementResponse confirmDealAgreement(Authentication connectedUser, long dealAgreementId) {
        User user = (User) connectedUser.getPrincipal();
        DealAgreement dealAgreement = dealAgreementRepository.findDealAgreementByIdAndBuyer(
                dealAgreementId,
                user.getId()
        ).orElseThrow();

        if (dealAgreement.getStatus() == DealAgreementStatus.WAITING) {
            dealAgreement.setStatus(DealAgreementStatus.COMPLETED);
            dealAgreement.setCompletedAt(OffsetDateTime.now());
            dealAgreementRepository.save(dealAgreement);
        }
        Post post = dealAgreement.getPost();
        post.setSold(post.getSold() + dealAgreement.getQuantity());
        postRepository.save(post);
        DealAgreementResponse dealAgreementResponse = DealAgreementResponse.builder()
                .id(dealAgreement.getId())
                .postId(dealAgreement.getPost().getId())
                .firstMediaUrl(dealAgreement.getPost().getMedia().get(0).getOriginalUrl())
                .postName(dealAgreement.getPost().getName())
                .originalPrice(dealAgreement.getPost().getOriginalPrice())
                .salePrice(dealAgreement.getPost().getSalePrice())
                .quantity(dealAgreement.getQuantity())
                .sellerFirstName(dealAgreement.getPost().getUser().getFirstName())
                .sellerLastName(dealAgreement.getPost().getUser().getLastName())
                .buyerFirstName(dealAgreement.getBuyer().getFirstName())
                .buyerLastName(dealAgreement.getBuyer().getLastName())
                .requestAt(dealAgreement.getRequestAt())
                .completedAt(dealAgreement.getCompletedAt())
                .status(dealAgreement.getStatus())
                .build();

        handleDealMessage(user, dealAgreement.getPost().getUser(), dealAgreementResponse);
        return dealAgreementResponse;
    }

    public DealAgreementResponse cancelDealAgreement(Authentication connectedUser, long dealAgreementId) {
        User user = (User) connectedUser.getPrincipal();
        DealAgreement dealAgreement = dealAgreementRepository.findDealAgreementByIdAndBuyer(
                dealAgreementId,
                user.getId()
        ).orElseThrow();

        if (dealAgreement.getStatus() == DealAgreementStatus.WAITING) {
            dealAgreement.setStatus(DealAgreementStatus.CANCELLED);
            dealAgreement.setCompletedAt(OffsetDateTime.now());
            dealAgreement = dealAgreementRepository.save(dealAgreement);
        }
        DealAgreementResponse dealAgreementResponse = DealAgreementResponse.builder()
                .id(dealAgreement.getId())
                .postId(dealAgreement.getPost().getId())
                .firstMediaUrl(dealAgreement.getPost().getMedia().get(0).getOriginalUrl())
                .postName(dealAgreement.getPost().getName())
                .originalPrice(dealAgreement.getPost().getOriginalPrice())
                .salePrice(dealAgreement.getPost().getSalePrice())
                .quantity(dealAgreement.getQuantity())
                .sellerFirstName(dealAgreement.getPost().getUser().getFirstName())
                .sellerLastName(dealAgreement.getPost().getUser().getLastName())
                .buyerFirstName(dealAgreement.getBuyer().getFirstName())
                .buyerLastName(dealAgreement.getBuyer().getLastName())
                .requestAt(dealAgreement.getRequestAt())
                .completedAt(dealAgreement.getCompletedAt())
                .status(dealAgreement.getStatus())
                .build();
        handleDealMessage(user, dealAgreement.getPost().getUser(), dealAgreementResponse);
        return dealAgreementResponse;
    }


    @Async
    protected void handleDealMessage(User seller, User buyer, DealAgreementResponse dealAgreementResponse) {
        Chat chat = chatRepository.findChatBetweenUsers(seller.getId(), buyer.getId());
        if (chat == null) return;

        Message dealMessage = new Message();
        dealMessage.setFromUser(seller);
        dealMessage.setToUser(buyer);
        dealMessage.setChat(chat);
        dealMessage.setContentType(ContentType.DEAL);
        dealMessage.setContent(dealAgreementResponse.convertJson());
        dealMessage = messageRepository.save(dealMessage);

        // gửi cho chính mình
        ChatResponse chatResponseForSender = ChatResponse.builder()
                .id(chat.getId())
                .chatPartnerId(buyer.getId())
                .chatPartnerAvatarUrl(buyer.getAvatarUrl())
                .chatPartnerFirstName(buyer.getFirstName())
                .chatPartnerLastName(buyer.getLastName())
                .educationInstitutionId(buyer.getEducationInstitution().getId())
                .educationInstitutionName(buyer.getEducationInstitution().getName())
                .currentPostId(chat.getCurrentPost().getId())
                .currentPostUserId(chat.getCurrentPost().getUser().getId())
                .currentPostName(chat.getCurrentPost().getName())
                .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                .quantity(chat.getCurrentPost().getQuantity())
                .sold(chat.getCurrentPost().getSold())
                .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                .mostRecentMessage(MessageResponse.mapperToResponse(dealMessage))
                .unReadMessageNumber(0)
                .forMe(true)
                .build();
        chatProducer.sendPostCreatedEvent(chatResponseForSender);

        // gửi message cho chatpartner
        int unReadMessageNumber = messageRepository.countUnreadMessagesFromSender(buyer.getId(), seller.getId());
        ChatResponse chatResponseForChatPartner = ChatResponse.builder()
                .id(chat.getId())
                .chatPartnerId(seller.getId())
                .chatPartnerAvatarUrl(seller.getAvatarUrl())
                .chatPartnerFirstName(seller.getFirstName())
                .chatPartnerLastName(seller.getLastName())
                .educationInstitutionId(seller.getEducationInstitution().getId())
                .educationInstitutionName(seller.getEducationInstitution().getName())
                .currentPostId(chat.getCurrentPost().getId())
                .currentPostUserId(chat.getCurrentPost().getUser().getId())
                .currentPostName(chat.getCurrentPost().getName())
                .currentPostSalePrice(chat.getCurrentPost().getSalePrice())
                .quantity(chat.getCurrentPost().getQuantity())
                .sold(chat.getCurrentPost().getSold())
                .currentPostFirstMediaUrl((chat.getCurrentPost() != null && !chat.getCurrentPost().getMedia().isEmpty()) ? chat.getCurrentPost().getMedia().get(0).getOriginalUrl() : null)
                .mostRecentMessage(MessageResponse.mapperToResponse(dealMessage))
                .unReadMessageNumber(unReadMessageNumber)
                .forMe(false)
                .build();
        chatProducer.sendPostCreatedEvent(chatResponseForChatPartner);
    }
}
