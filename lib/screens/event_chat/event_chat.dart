import 'package:eventos_da_rep/exceptions/exceptions.dart';
import 'package:eventos_da_rep/http/message_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../../providers/shared_preferences_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/no_items_found_indicator.dart';
import '../../widgets/screen_loader.dart';

class EventChat extends StatefulWidget {
  final String eventId;
  final String? userId;
  final String eventName;

  const EventChat({
    Key? key,
    required this.eventId,
    required this.eventName,
    required this.userId,
  }) : super(key: key);

  @override
  State<EventChat> createState() => _EventChatState();
}

class _EventChatState extends State<EventChat> {
  final MessageClient client = MessageClient();
  late types.User _user;
  late String _userId;
  bool _isFirstTime = true;

  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      return _getUserIdAndLoadChat();
    } else {
      _setUserId(widget.userId!);
      return _buildChat();
    }
  }

  Widget _getUserIdAndLoadChat() {
    return FutureBuilder(
      future: SharedPreferencesProvider().getStringValue(prefUserId),
      builder: (context, snaphot) {
        if (snaphot.connectionState == ConnectionState.waiting) {
          return const ScreenLoader();
        } else if (snaphot.connectionState == ConnectionState.done) {
          String? id = snaphot.data as String?;

          if (id != null) {
            _setUserId(id);
            return _buildChat();
          } else {
            return const NoItemsFoundIndicator(
              message:
                  "Ocorreu um erro ao carregar o chat, tente novamente mais tarde.",
            );
          }
        } else {
          return const NoItemsFoundIndicator(
            message:
                "Ocorreu um erro ao carregar o chat, tente novamente mais tarde.",
          );
        }
      },
    );
  }

  Widget _buildChat() {
    _user = types.User(id: _userId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat do evento: ${widget.eventName}'),
        backgroundColor: const Color(0xff102733),
      ),
      body: StreamBuilder<List<types.Message>>(
        initialData: const [],
        stream: client.getMessages(widget.eventId),
        builder: (context, snapshot) {
          if (!_isFirstTime) {
            return _getChatWidget(snapshot.data);
          } else {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ScreenLoader();
            } else if (snapshot.connectionState == ConnectionState.active) {
              _isFirstTime = false;
              return _getChatWidget(snapshot.data);
            } else {
              return const NoItemsFoundIndicator(
                message:
                    "Ocorreu um erro ao carregar o chat, tente novamente mais tarde.",
              );
            }
          }
        },
      ),
    );
  }

  Widget _getChatWidget(List<types.Message>? messages) => Chat(
        messages: messages ?? [],
        onSendPressed: _handleSendPressed,
        user: _user,
        emptyState: _buildEmptyMessages(),
        theme: const DefaultChatTheme(
          inputBackgroundColor: Colors.white12,
          backgroundColor: Color(0xff102733),
        ),
        l10n: const ChatL10nEn(
          inputPlaceholder: 'Digite sua mensagem aqui',
        ),
        showUserAvatars: true,
        showUserNames: true,
      );

  Widget _buildEmptyMessages() => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: const Text(
          "Esse evento ainda não possui nenhuma mensagem",
          style: TextStyle(
            color: neutral2,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      );

  _handleSendPressed(types.PartialText message) {
    client
        .sendMessage(
          widget.eventId,
          _userId,
          message.text,
        )
        .catchError(
          (e) => {
            {
              ScaffoldMessenger.of(context).showSnackBar(
                buildErrorSnackBar(
                  "Ocorreu um erro ao enviar a mensagem.",
                ),
              ),
            }
          },
          test: (e) => e is ApiException,
        );
  }

  void _setUserId(String userId) {
    _userId = userId;
  }
}
