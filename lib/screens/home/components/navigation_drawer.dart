import 'package:eventos_da_rep/screens/payments_list/payment_list.dart';
import 'package:eventos_da_rep/screens/settings/settings.dart';
import 'package:flutter/material.dart';

class NavigationDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String photo;

  const NavigationDrawer({
    Key? key,
    required this.name,
    required this.email,
    required this.photo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        backgroundColor: const Color(0xff102733),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(context),
              buildMenuItens(context),
            ],
          ),
        ),
      );

  Widget buildHeader(BuildContext context) => Material(
        color: const Color(0xff102733),
        child: Container(
          padding: EdgeInsets.only(
            top: 24 + MediaQuery.of(context).padding.top,
            bottom: 24,
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundImage: NetworkImage(photo),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              Text(
                email,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildMenuItens(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 16,
          children: [
            const Divider(
              color: Colors.white,
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              title: const Text(
                "Configurações",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.monetization_on,
                color: Colors.white,
              ),
              title: const Text(
                "Meus Pagamentos",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentList(),
                ),
              ),
            ),
          ],
        ),
      );
}
