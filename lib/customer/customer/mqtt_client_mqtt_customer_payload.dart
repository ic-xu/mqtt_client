/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/06/2017
 * Copyright :  S.Hamblett
 */

part of mqtt_client;

/// Class that contains details related to an MQTT Connect messages payload
class MqttCustomerPayload extends MqttPayload {
  /// Initializes a new instance of the MqttPublishPayload class.
  MqttCustomerPayload() {
    message = typed.Uint8Buffer();
  }


  /// Message header
  MqttHeader? header;


  /// Variable header
  MqttCustomerVariableHeader? variableHeader;

  /// The message that forms the payload of the publish message.
  typed.Uint8Buffer? message;

  /// Creates a payload from the specified header stream.
  @override
  void readFrom(MqttByteBuffer payloadStream) {
    // The payload of the publish message is not a string, just
    // a binary chunk of bytes.
    // The length of the bytes is the length specified in the header,
    // minus any bytes spent in the variable header.,messageType 1byte
    final messageBytes = header!.messageSize - variableHeader!.length-1;
    message = payloadStream.read(messageBytes);
  }

  /// Initializes a new instance of the MqttPublishPayload class.
  MqttCustomerPayload.fromByteBuffer(
      this.header, this.variableHeader, MqttByteBuffer payloadStream) {
    readFrom(payloadStream);
  }

  /// Writes the payload to the supplied stream.
  @override
  void writeTo(MqttByteBuffer payloadStream) {
    payloadStream.write(message);
  }

  /// Gets the length of the payload in bytes when written to a stream.
  @override
  int getWriteLength() => message!.length;

  @override
  String toString() =>
      'Payload: {${message!.length} bytes={${bytesToString(message!)}';

  /// Converts an array of bytes to a byte string.
  static String bytesToString(typed.Uint8Buffer message) {
    final sb = StringBuffer();
    for (final b in message) {
      sb.write('<');
      sb.write(b);
      sb.write('>');
    }
    return sb.toString();
  }

  /// Converts an array of bytes to a character string.
  static String bytesToStringAsString(typed.Uint8Buffer message) {
    final sb = StringBuffer();
    message.forEach(sb.writeCharCode);
    return sb.toString();
  }

}
