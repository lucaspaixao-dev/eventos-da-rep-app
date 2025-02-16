import 'package:eventos_da_rep/exceptions/exceptions.dart';
import 'package:eventos_da_rep/models/event.dart';
import 'package:eventos_da_rep/models/user_resume.dart';
import 'package:eventos_da_rep/screens/event_details/event_details.dart';
import 'package:eventos_da_rep/widgets/app_logo.dart';
import 'package:eventos_da_rep/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../helpers/date_helper.dart';
import '../../helpers/string_helper.dart';
import '../../http/event_client.dart';
import '../../http/user_client.dart';
import '../../models/user.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../services/firebase_service.dart';
import 'components/navigation_drawer.dart';
import '../../widgets/no_items_found_indicator.dart';
import 'components/popular_event_tile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final eventClient = EventClient();
  final userClient = UserClient();
  final FirebaseService firebaseService = FirebaseService();
  final authUser = FirebaseService().getAuthUser();
  final firebaseMessaging = FirebaseService().getMessaging();
  final SharedPreferencesProvider sharedPreferencesProvider =
      SharedPreferencesProvider();

  static const _pageSize = 20;

  final PagingController<int, Event> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _verifyUserPreferences();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    FlutterNativeSplash.remove();
    super.initState();
  }

  _verifyUserPreferences() async {
    String? userId = await sharedPreferencesProvider.getStringValue(prefUserId);

    if (userId == null) {
      final User user = await userClient.findByEmail(authUser!.email!);
      await sharedPreferencesProvider.putStringValue(prefUserId, user.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      drawer: FutureBuilder<UserResume>(
        future: _updateUserInfos(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return NavigationDrawer(
              name: snapshot.data!.name,
              email: snapshot.data!.email,
              photo: snapshot.data!.photo,
            );
          } else {
            return const Text("");
          }
        },
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff102733),
        elevation: 0,
        title: const AppLogo(fontSize: 25),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xff102733)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FutureBuilder<String>(
                          future: _getName(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              String? data = snapshot.data;
                              return SizedBox(
                                width: mediaQuery.size.width * 0.80,
                                child: Text(
                                  "Olá, $data!",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                  ),
                                ),
                              );
                            } else {
                              return const Text("");
                            }
                          },
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        SizedBox(
                          width: mediaQuery.size.width * 0.80,
                          child: const Text(
                            "Vamos ver quais são os próximos eventos da REP mais badalada de Araraquara?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: mediaQuery.size.height * 0.64,
                  child: RefreshIndicator(
                    onRefresh: () => Future.sync(
                      () => _pagingController.refresh(),
                    ),
                    child: PagedListView<int, Event>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Event>(
                        transitionDuration: const Duration(milliseconds: 500),
                        noItemsFoundIndicatorBuilder: (_) =>
                            const NoItemsFoundIndicator(
                          message:
                              "A REP não tem nenhum próximo evento agendado, mas fique ligado que logo terá!",
                        ),
                        itemBuilder: (context, item, index) => InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetails(
                                  eventId: item.id,
                                ),
                              ),
                            );
                          },
                          child: PopularEventTile(
                            desc: item.title,
                            imgeAssetPath: item.photo,
                            date: formatDate(item.date),
                            address: buildAddressResume(item),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newEvents = await eventClient.getEvents(pageKey, _pageSize);
      final isLastPage = newEvents.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newEvents);
      } else {
        final nextPageKey = pageKey + newEvents.length;
        _pagingController.appendPage(newEvents, nextPageKey);
      }
    } on ApiException catch (e) {
      SnackBar snackBar = buildErrorSnackBar(e.cause);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      _pagingController.error = e;
    }
  }

  Future<String> _getName() async {
    if (authUser!.displayName != null) {
      return authUser!.displayName!;
    }

    String? name = await sharedPreferencesProvider.getStringValue(prefUserName);
    if (name != null) {
      return name;
    }

    return "";
  }

  Future<UserResume> _updateUserInfos() async {
    if (authUser!.displayName != null && authUser!.photoURL != null) {
      return UserResume(
        authUser!.displayName!,
        authUser!.email!,
        authUser!.photoURL!,
      );
    }

    String? name = await sharedPreferencesProvider.getStringValue(prefUserName);
    String? photoUrl =
        await sharedPreferencesProvider.getStringValue(prefUserPhotoUrl);

    if (name != null && photoUrl != null) {
      await authUser?.updateDisplayName(name);
      await authUser?.updatePhotoURL(photoUrl);
      await authUser?.reload();

      return UserResume(name, authUser!.email!, photoUrl);
    }

    return UserResume("", "", "");
  }
}
