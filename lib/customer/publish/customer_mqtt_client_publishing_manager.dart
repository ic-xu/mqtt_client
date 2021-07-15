

import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:mqtt_client/mqtt_client.dart';

class CustomerPublishingManager extends PublishingManager{

  EventBus? _clientEventBus ;



  CustomerPublishingManager(IMqttConnectionHandler? connectionHandler, EventBus? clientEventBus) : super(connectionHandler, clientEventBus){
    _clientEventBus = clientEventBus;
    connectionHandler!.registerForMessage(MqttMessageType.reserved1, handleCustomerMessageRelease);
  }
  /// The stream on which all confirmed published messages are added to
  StreamController<MqttCustomerMessage> get customer =>  StreamController<MqttCustomerMessage>.broadcast();

  // final StreamController<MqttCustomerMessage> _customer =
  // StreamController<MqttCustomerMessage>.broadcast();


  int sendCustomerMessage(MqttCustomerMessage message) {
    // TODO: implement sendCustomerMessage
    // final msgId = messageIdentifierDispenser.getNextMessageIdentifier();
    connectionHandler!.sendMessage(message);
    return 1;
  }


  /// Handles the publish release, for messages that are undergoing Qos ExactlyOnce processing.
  bool handleCustomerMessageRelease(MqttMessage? msg) {
    final customerMessage = msg as MqttCustomerMessage;
    final messageIdentifier = customerMessage.variableHeader.messageIdentifier;
    MqttLogger.log(
        'PublishingManager::handlePublishRelease - for message identifier $messageIdentifier');
    var receiverSuccess = true;
    try {
      _clientEventBus!.fire(customerMessage);
      final pubMsg = receivedMessages.remove(messageIdentifier);
      if (pubMsg != null) {
        // Send the message for processing to whoever is waiting.
        _clientEventBus!.fire(pubMsg);
//        final compMsg = MqttPublishCompleteMessage()
//            .withMessageIdentifier(pubMsg.variableHeader!.messageIdentifier);
//        connectionHandler!.sendMessage(compMsg);
      }
    } on Exception {
      receiverSuccess = false;
    }
    return receiverSuccess;
  }

}