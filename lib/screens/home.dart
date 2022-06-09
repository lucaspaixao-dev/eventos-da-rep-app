import 'package:eventos_da_rep/models/event.dart';
import 'package:eventos_da_rep/screens/event_details.dart';
import 'package:eventos_da_rep/screens/menu.dart';
import 'package:eventos_da_rep/widgets/app_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../helpers/date_helper.dart';
import '../helpers/string_helper.dart';
import '../http/event_client.dart';

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

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xff102733)),
          ),
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
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
                          )
                        ],
                      ),
                      const Spacer(),
                      // SizedBox(
                      //   height: 22,
                      //   child: GestureDetector(
                      //     onTap: () => {},
                      //     child: const Icon(
                      //       Icons.notifications,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(
                        width: 16,
                      ),
                      SizedBox(
                        height: 22,
                        child: GestureDetector(
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Menu(),
                              ),
                            ),
                          },
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                              fontSize: 21,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          SizedBox(
                            width: mediaQuery.size.width * 0.70,
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
                      const Spacer(),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xffFAE072),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(authUser?.photoURL ?? ""),
                          radius: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: mediaQuery.size.height * 0.90,
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
                            onTap: () =>
                                _navigateAndDisplayResult(context, item),
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
          )
        ],
      ),
    );
  }
}

class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            "assets/not_found.png",
            width: 110,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "A REP não tem nenhum próximo evento agendado, mas fique ligado que logo terá!",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class PopularEventTile extends StatefulWidget {
  String desc;
  String date;
  String address;
  String imgeAssetPath;

  /// later can be changed with imgUrl
  PopularEventTile(
      {Key? key,
      required this.address,
      required this.date,
      required this.imgeAssetPath,
      required this.desc})
      : super(key: key);

  @override
  State<PopularEventTile> createState() => _PopularEventTileState();
}

class _PopularEventTileState extends State<PopularEventTile> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xff29404E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16),
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: mediaQuery.size.width * 0.50,
                    child: Text(
                      widget.desc,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        widget.date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        width: mediaQuery.size.width * 0.35,
                        child: Text(
                          widget.address,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              child: Image.network(
                widget.imgeAssetPath,
                height: 100,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
