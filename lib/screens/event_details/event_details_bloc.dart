import 'package:eventos_da_rep/models/screen_message.dart';
import 'package:rxdart/subjects.dart';

class EventDetailsBloc {
  final _isLoading = BehaviorSubject<bool>();
  final _screenMessage = BehaviorSubject<ScreenMessage>();

  EventDetailsBloc() {
    _isLoading.sink.add(false);
    _screenMessage.sink.add(ScreenMessage("", ""));
  }

  Stream<bool> get isLoading => _isLoading.stream;
  Stream<ScreenMessage> get screenMessage => _screenMessage.stream;

  updateLoading(bool isLoading) {
    _isLoading.sink.add(isLoading);
  }

  updateMessage(ScreenMessage message) {
    _screenMessage.sink.add(message);
  }

  cleanValue() {
    _isLoading.sink.add(false);
    _screenMessage.sink.add(ScreenMessage("", ""));
  }
}
