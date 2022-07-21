import 'package:eventos_da_rep/http/payment_client.dart';
import 'package:eventos_da_rep/models/payment.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../exceptions/exceptions.dart';
import '../../helpers/math_helper.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/no_items_found_indicator.dart';

class PaymentList extends StatefulWidget {
  const PaymentList({Key? key}) : super(key: key);

  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  final _paymentClient = PaymentClient();

  final PagingController<int, Payment> _pagingController = PagingController(
    firstPageKey: 0,
  );

  final SharedPreferencesProvider sharedPreferencesProvider =
      SharedPreferencesProvider();

  static const _pageSize = 20;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      String? userId =
          await sharedPreferencesProvider.getStringValue(prefUserId);

      if (userId == null) {}

      final newEvents =
          await _paymentClient.getPaymentsByUser(userId!, pageKey, _pageSize);
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pagamentos'),
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
              height: mediaQuery.size.height * 0.80,
              child: RefreshIndicator(
                onRefresh: () => Future.sync(
                  () => _pagingController.refresh(),
                ),
                child: PagedListView<int, Payment>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Payment>(
                    transitionDuration: const Duration(milliseconds: 500),
                    noItemsFoundIndicatorBuilder: (_) =>
                        const NoItemsFoundIndicator(
                      message: "Nenhum pagamento efetuado ainda!",
                    ),
                    itemBuilder: (context, item, index) => Card(
                      color: const Color(0xff29404E),
                      child: ListTile(
                        leading: getIcon(item),
                        title: Text(
                          item.eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: getStatus(item),
                        trailing: Text(
                          centsToReal(item.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getStatus(Payment payment) {
    switch (payment.status) {
      case PaymentStatus.success:
        return const Text(
          'Pagamento Aprovado!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green,
          ),
        );
      case PaymentStatus.failed:
        return const Text(
          'Pagamento Reprovado!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        );
      case PaymentStatus.processing:
        return const Text(
          'Pagamento em Processamento!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.orange,
          ),
        );
      case PaymentStatus.pending:
        return const Text(
          'Pagamento Pendente!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue,
          ),
        );
      case PaymentStatus.refunded:
        return const Text(
          'Pagamento Estornado!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        );
    }
  }

  Widget getIcon(Payment payment) {
    switch (payment.status) {
      case PaymentStatus.success:
        return CircleAvatar(
          backgroundColor: Colors.green,
          child: SizedBox(
            width: 60,
            height: 60,
            child: ClipOval(
              child: Image.asset(
                "assets/completed_list.png",
              ),
            ),
          ),
        );
      case PaymentStatus.failed:
        return CircleAvatar(
          backgroundColor: Colors.red,
          child: SizedBox(
            width: 35,
            height: 35,
            child: ClipOval(
              child: Image.asset(
                "assets/denied.png",
              ),
            ),
          ),
        );
      case PaymentStatus.processing:
        return CircleAvatar(
          backgroundColor: Colors.orange,
          child: SizedBox(
            width: 35,
            height: 35,
            child: ClipOval(
              child: Image.asset(
                "assets/processing.png",
              ),
            ),
          ),
        );
      case PaymentStatus.pending:
        return CircleAvatar(
          backgroundColor: Colors.blue,
          child: SizedBox(
            width: 35,
            height: 35,
            child: ClipOval(
              child: Image.asset("assets/pending.png"),
            ),
          ),
        );
      case PaymentStatus.refunded:
        return CircleAvatar(
          backgroundColor: Colors.grey,
          child: SizedBox(
            width: 60,
            height: 60,
            child: ClipOval(
              child: Image.asset(
                "assets/refund.png",
              ),
            ),
          ),
        );
    }
  }
}
