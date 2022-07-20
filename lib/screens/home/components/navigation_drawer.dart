import 'package:eventos_da_rep/screens/payments_list/payment_list.dart';
import 'package:eventos_da_rep/screens/update_password/update_password.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../models/app_version.dart';
import '../../../providers/auth_provider.dart';

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
            FutureBuilder<bool>(
              future: _isGoogleAuth(context),
              builder: (
                BuildContext context,
                AsyncSnapshot<bool> isGoogleAuth,
              ) {
                if (isGoogleAuth.hasData) {
                  if (isGoogleAuth.data! == false) {
                    return _getUpdatePasswordOption(context);
                  }
                }

                return _getUpdatePasswordOption(context);
              },
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
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: const Text(
                "Sair",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () => _logout(context),
            ),
            FutureBuilder<AppVersion>(
              future: _getAppInfos(),
              builder:
                  (BuildContext context, AsyncSnapshot<AppVersion> snapshot) {
                if (!snapshot.hasData) {
                  // while data is loading:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final info = snapshot.data;
                  return Center(
                    child: Text(
                      'Versão do Aplicativo: ${info?.version}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );

  Widget _getUpdatePasswordOption(BuildContext context) => ListTile(
        leading: const Icon(
          Icons.lock,
          color: Colors.white,
        ),
        title: const Text(
          "Alterar Senha",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onTap: () => {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => const UpdatePassword(),
          ),
        },
      );

  Future<AppVersion> _getAppInfos() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return AppVersion(
      appName: appName,
      packageName: packageName,
      version: version,
      buildVersion: buildNumber,
    );
  }

  Future<bool> _isGoogleAuth(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return await authProvider.isGoogleAuth();
  }

  void _logout(BuildContext context) {
    final authService = Provider.of<AuthProvider>(context, listen: false);
    authService.logout().then((_) => Navigator.pop(context));
  }
}
