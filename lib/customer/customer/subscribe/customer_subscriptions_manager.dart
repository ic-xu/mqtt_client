import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:mqtt_client/mqtt_client.dart';

class CustomerSubscriptionManager extends SubscriptionsManager {

  CustomerSubscriptionManager(IMqttConnectionHandler? connectionHandler,
      PublishingManager? publishingManager, EventBus? clientEventBus)
      : super(connectionHandler, publishingManager, clientEventBus) {
    clientEventBus!.on<MqttCustomerMessage>().listen(_customerMessageRever);
  }

  /// Stream for all customer message
  final _customerMessage =
      StreamController<MqttCustomerMessage>.broadcast(sync: true);

  /// Subscription notifier
  Stream<MqttCustomerMessage> get customerMessage =>
      _customerMessage.stream;

  // Re subscribe.
  // Takes all active completed subscriptions and re subscribes them if
  // [resubscribeOnAutoReconnect] is true.
  // Automatically fired after auto reconnect has completed.
  void _customerMessageRever(MqttCustomerMessage mqttCustomerMessage) {
    print("===receiver=======>" + mqttCustomerMessage.toString());
    _customerMessage.add(mqttCustomerMessage);
  }
}
