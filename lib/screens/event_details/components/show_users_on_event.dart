import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../models/event.dart';
import '../users_on_event.dart';

class ShowUsersOnEvent extends StatelessWidget {
  const ShowUsersOnEvent({
    Key? key,
    required this.event,
    required this.mediaQuery,
  }) : super(key: key);

  final Event event;
  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: event.users.isNotEmpty,
      child: InkWell(
        onTap: () {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => UsersOnEvent(
              users: event.users,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: mediaQuery.size.width * 0.80,
                height: mediaQuery.size.width * 0.15,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: event.users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          event.users[index].photo,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
