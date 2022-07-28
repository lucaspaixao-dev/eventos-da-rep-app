import 'package:eventos_da_rep/screens/update_password/update_password.dart';
import 'package:eventos_da_rep/services/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/app_version.dart';
import '../../widgets/app_snack_bar.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SettingsService _settingsService = SettingsService();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: const Color(0xff102733),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xff102733)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: mediaQuery.size.height * 0.64,
              child: ListView(
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdatePassword(),
                      ),
                    ),
                    child: const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Alterar Senha',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                  ),
                  InkWell(
                    onTap: () {
                      showCupertinoDialog(
                              context: context,
                              builder: (_) => _getDeleteDialog(context))
                          .then((value) => {
                                if (value)
                                  {
                                    Navigator.pop(context),
                                  }
                              });
                    },
                    child: const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Excluir conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                  ),
                  InkWell(
                    onTap: () => _settingsService.logout(context),
                    child: const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Sair',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<AppVersion>(
            future: _settingsService.getAppVersion(),
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

  Widget _getDeleteDialog(BuildContext context) => CupertinoAlertDialog(
        title: const Text("Você deseja realmente excluir sua conta? 😭"),
        content: const Text(
            "Ao excluir sua conta você perderá seu convite e talvez não consiga mais novamente!"),
        actions: [
          CupertinoButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          CupertinoButton(
            child: const Text(
              'Excluir minha conta',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              try {
                await _settingsService.deleteUser(context);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  buildErrorSnackBar(
                    "Ocorreu um erro ao excluir sua conta. Tente novamente mais tarde.",
                  ),
                );
              }
            },
          )
        ],
      );
}
