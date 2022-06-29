import 'package:flutter/material.dart';

import '../../event_chat/event_chat.dart';

class ChatEventDetails extends StatelessWidget {
  const ChatEventDetails({
    Key? key,
    required this.isGoing,
    required this.eventId,
    required this.userId,
    required this.title,
  }) : super(key: key);

  final bool isGoing;
  final String eventId;
  final String userId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isGoing,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return EventChat(
                      eventId: eventId,
                      userId: userId,
                      eventName: title,
                    );
                  },
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              icon: const Icon(
                Icons.chat,
                color: Colors.white,
              ),
              label: const Text('Chat do evento'),
            ),
          ],
        ),
      ),
    );
  }
}
