import 'package:eventos_da_rep/models/event.dart';
import 'package:eventos_da_rep/screens/event_details/event_details.dart';
import 'package:eventos_da_rep/widgets/app_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../helpers/date_helper.dart';
import '../../helpers/string_helper.dart';
import '../../http/event_client.dart';
import 'components/navigation_drawer.dart';
import 'components/no_items_found_indicator.dart';
import 'components/popular_event_tile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final eventClient = EventClient();
  static const _pageSize = 20;

  final PagingController<int, Event> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    FlutterNativeSplash.remove();
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
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _navigateAndDisplayResult(
    BuildContext context,
    Event event,
  ) async {
    final result = await showCupertinoModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) => EventDetails(
        event: event,
      ),
    );

    if (result != null) {
      final isSuccess = result['isSuccess'] == 'success' ? true : false;

      final appSnackBar = AppSnackBar(
        duration: const Duration(milliseconds: 2000),
        title: result['title']!,
        message: result['message']!,
        isSuccess: isSuccess,
        elevation: 10.0,
      ).buildSnackBar();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(appSnackBar);

      if (isSuccess) {
        _pagingController.refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final authUser = FirebaseAuth.instance.currentUser;

    final name = authUser!.displayName!;
    final email = authUser.email!;
    final photo = authUser.photoURL!;

    return Scaffold(
      drawer: NavigationDrawer(
        name: name,
        email: email,
        photo: photo,
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff102733),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: const <Widget>[
              Text(
                "EVENTOS ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                "DA REP",
                style: TextStyle(
                    color: Color(0xffFCCD00),
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
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
                        Text(
                          "Olá, ${authUser?.displayName}!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        SizedBox(
                          width: mediaQuery.size.width * 0.80,
                          child: const Text(
                            "Vamos ver quais são os próximos eventos da rep?",
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
                  height: mediaQuery.size.height * 0.65,
                  child: RefreshIndicator(
                    onRefresh: () => Future.sync(
                      () => _pagingController.refresh(),
                    ),
                    child: PagedListView<int, Event>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Event>(
                        transitionDuration: const Duration(milliseconds: 500),
                        noItemsFoundIndicatorBuilder: (_) =>
                            const NoItemsFoundIndicator(),
                        itemBuilder: (context, item, index) => InkWell(
                          onTap: () => _navigateAndDisplayResult(context, item),
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
}
