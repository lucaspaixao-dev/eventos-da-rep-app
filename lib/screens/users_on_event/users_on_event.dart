import 'package:flutter/material.dart';

import '../../models/user.dart';

class UsersOnEvent extends StatefulWidget {
  final List<User> users;

  const UsersOnEvent({Key? key, required this.users}) : super(key: key);

  @override
  State<UsersOnEvent> createState() => _UsersOnEventState();
}

class _UsersOnEventState extends State<UsersOnEvent> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xff102733)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: mediaQuery.size.height * 0.64,
              child: ListView.builder(
                itemCount: widget.users.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.users[index].photo),
                      ),
                      title: Text(
                        widget.users[index].name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
