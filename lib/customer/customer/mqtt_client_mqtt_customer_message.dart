/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 15/06/2017
 * Copyright :  S.Hamblett
 */

//import 'package:mqtt_client/mqtt_client.dart';
//import 'package:mqtt_client/src/messages/customer/mqtt_client_mqtt_customer_variable_header.dart';
//part of mqtt_client;
part of mqtt_client;

/// Message that indicates a connection acknowledgement.
class MqttCustomerMessage extends MqttMessage {
  /// Initializes a new instance of the MqttConnectAckMessage class.
  /// Only called via the MqttMessage.Create operation during processing
  /// of an Mqtt message stream.

  /// Gets or sets the payload of the Mqtt Message.
  late MqttCustomerPayload payload;

  /// Gets or sets the variable header contents. Contains extended
  /// metadata about the message
  late MqttCustomerVariableHeader variableHeader;

  late int messageType;

  MqttCustomerMessage(int messageType,typed.Uint8Buffer? message) {
    header = MqttHeader().asType(MqttMessageType.reserved1);
    variableHeader = MqttCustomerVariableHeader();
    payload = MqttCustomerPayload();
    payload.header = header;
    payload.variableHeader = variableHeader;
    this.messageType = messageType;
    payload.message = message;
  }

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttCustomerMessage.fromByteBuffer(
      MqttHeader header, MqttByteBuffer messageStream) {
    this.header = header;
    readFrom(messageStream);
  }





  /// Reads a message from the supplied stream.
  @override
  void readFrom(MqttByteBuffer messageStream) {
    super.readFrom(messageStream);
    variableHeader = MqttCustomerVariableHeader.fromByteBuffer(messageStream);
    messageType = messageStream.readByte();
    payload = MqttCustomerPayload.fromByteBuffer(
        header, variableHeader, messageStream);
  }


  /// Writes a message to the supplied stream.
  @override
  void writeTo(MqttByteBuffer messageStream) {
    header!.writeTo(variableHeader.getWriteLength()+1+payload.getWriteLength(), messageStream);
    variableHeader.writeTo(messageStream);
    messageStream.writeByte(messageType);
    messageStream.write(payload.message);
    // payload.writeTo(messageStream);
    // print(messageStream);
  }

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write(super.toString());
    sb.writeln(variableHeader.toString());
    return sb.toString();
  }
}
