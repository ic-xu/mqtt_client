import 'package:meta/meta.dart';
import 'package:mqtt_client/customer/publish/customer_mqtt_client_publishing_manager.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:event_bus/event_bus.dart' as events;
import 'customer/subscribe/customer_subscriptions_manager.dart';

class CustomerMqttClient extends MqttServerClient {
  CustomerMqttClient(String server, String clientIdentifier)
      : super(server, clientIdentifier);

  /// Published message stream. A publish message is added to this
  /// stream on completion of the message publishing protocol for a Qos level.
  /// Attach listeners only after connect has been called.
  Stream<MqttCustomerMessage>? get customer => subscriptionsManager != null
      ? (subscriptionsManager as CustomerSubscriptionManager).customerMessage
      : null;

  @override
  Future<MqttClientConnectionStatus?> connect(
      [String? username, String? password]) async {
    instantiationCorrect = true;
    clientEventBus = events.EventBus();
    connectionHandler = SynchronousMqttServerConnectionHandler(
      clientEventBus,
      maxConnectionAttempts: maxConnectionAttempts,
    );
    if (useWebSocket) {
      connectionHandler.secure = false;
      connectionHandler.useWebSocket = true;
      connectionHandler.useAlternateWebSocketImplementation =
          useAlternateWebSocketImplementation;
      if (websocketProtocolString != null) {
        connectionHandler.websocketProtocols = websocketProtocolString;
      }
    }
    if (secure) {
      connectionHandler.secure = true;
      connectionHandler.useWebSocket = false;
      connectionHandler.useAlternateWebSocketImplementation = false;
      connectionHandler.securityContext = securityContext;
      connectionHandler.onBadCertificate = onBadCertificate;
    }

    //TODO 拆分
    // Protect against an incorrect instantiation
    if (!instantiationCorrect) {
      throw IncorrectInstantiationException();
    }
    // Generate the client id for logging
    MqttLogger.clientId++;

    checkCredentials(username, password);
    // Set the authentication parameters in the connection
    // message if we have one.
    connectionMessage?.authenticateAs(username, password);

    // Do the connection
    if (websocketProtocolString != null) {
      connectionHandler.websocketProtocols = websocketProtocolString;
    }
    connectionHandler.onDisconnected = internalDisconnect;
    connectionHandler.onConnected = onConnected;
    connectionHandler.onAutoReconnect = onAutoReconnect;
    connectionHandler.onAutoReconnected = onAutoReconnected;

    publishingManager =
        CustomerPublishingManager(connectionHandler, clientEventBus);

    publishingManager!.manuallyAcknowledgeQos1 = manuallyAcknowledgeQos1;
    subscriptionsManager = CustomerSubscriptionManager(
        connectionHandler, publishingManager, clientEventBus);
    subscriptionsManager!.onSubscribed = onSubscribed;
    subscriptionsManager!.onUnsubscribed = onUnsubscribed;
    subscriptionsManager!.onSubscribeFail = onSubscribeFail;
    subscriptionsManager!.resubscribeOnAutoReconnect =
        resubscribeOnAutoReconnect;
    if (keepAlivePeriod != MqttClientConstants.defaultKeepAlive) {
      MqttLogger.log(
          'MqttClient::connect - keep alive is enabled with a value of $keepAlivePeriod seconds');

      keepAlive = MqttConnectionKeepAlive(connectionHandler,clientEventBus, keepAlivePeriod);

      if (pongCallback != null) {
        keepAlive!.pongCallback = pongCallback;
      }
    } else {
      MqttLogger.log('MqttClient::connect - keep alive is disabled');
    }
    final connectMessage = getConnectMessage(username, password);
    // If the client id is not set in the connection message use the one
    // supplied in the constructor.
    if (connectMessage.payload.clientIdentifier.isEmpty) {
      connectMessage.payload.clientIdentifier = clientIdentifier;
    }
    // Set keep alive period.
    connectMessage.variableHeader?.keepAlive = keepAlivePeriod;
    connectionMessage = connectMessage;
    return connectionHandler.connect(server, port, connectMessage);
  }

  int? sendCustomerMessage(MqttCustomerMessage message) {
    // CustomerPublishingManager publishingManager = publishingManager;
    var result = (publishingManager as CustomerPublishingManager)
        .sendCustomerMessage(message);
    return result;
  }
}
