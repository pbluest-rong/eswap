import 'package:eswap/model/chat_model.dart';
import 'package:eswap/model/message_model.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat> chats = [];
  List<Message> messages = [];

  // init load chats
  void updateChats(List<Chat> chats) {
    this.chats = chats;
    notifyListeners();
  }

  // init load messages
  void updateMessages(List<Message> messages) {
    this.messages = messages;
    notifyListeners();
  }

  // load more chats
  void addChats(List<Chat> newChats) {
    for (Chat c in newChats) {
      addChat(c);
    }
  }

  // load more messages
  void addMessages(List<Message> newMessages) {
    messages = [...newMessages, ...messages];
    notifyListeners();
  }

  // add new message
  void addChat(Chat chat) {
    print("CHAT ${chat.unReadMessageNumber} - ${chat.chatPartnerLastName}");
    final index = chats.indexWhere((c) => c.id == chat.id);
    if (index != -1) {
      if (chats[index].mostRecentMessage!.id != chat.mostRecentMessage!.id) {
        messages.add(chat.mostRecentMessage!);
        chat.unReadMessageNumber = chats[index].unReadMessageNumber + 1;
      }
      chats.removeAt(index);
      chats.insert(0, chat);
    } else {
      chats.insert(0, chat);
    }
    notifyListeners();
  }

  void markAsReadUI(int index) {
    chats[index].unReadMessageNumber = 0;
    notifyListeners();
  }
}
