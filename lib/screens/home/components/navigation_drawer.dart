import 'package:flutter/material.dart';
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

  void _logout(BuildContext context) {
    final authService = Provider.of<AuthProvider>(context, listen: false);
    authService.logout().then((_) => Navigator.pop(context));
  }
}
