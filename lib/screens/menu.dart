import 'package:eventos_da_rep/models/app_version.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color(0xff102733),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff102733),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(8),
            children: [
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.event,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Eventos que eu vou',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      GestureDetector(
                        onTap: () => _logout(),
                        child: const Text(
                          'Sair',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
  }

  void _logout() {
    final authService = Provider.of<AuthProvider>(context, listen: false);
    authService.logout().then((_) => Navigator.pop(context));
  }

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
}
