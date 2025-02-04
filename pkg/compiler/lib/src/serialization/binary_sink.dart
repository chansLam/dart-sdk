// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:kernel/binary/ast_to_binary.dart';
import 'data_sink.dart';

/// [DataSink] that writes data as a sequence of bytes.
///
/// This data sink works together with [BinarySourceWriter].
class BinaryDataSink implements DataSink {
  final Sink<List<int>> sink;
  // Nullable and non-final to allow storage to be released.
  BufferedSink? _bufferedSink;
  int _length = 0;

  BinaryDataSink(this.sink) : _bufferedSink = BufferedSink(sink);

  @override
  int get length => _length;

  @override
  void beginTag(String tag) {
    // TODO(johnniwinther): Support tags in binary serialization?
  }

  @override
  void endTag(String tag) {
    // TODO(johnniwinther): Support tags in binary serialization?
  }

  @override
  void writeString(String value) {
    List<int> bytes = utf8.encode(value);
    writeInt(bytes.length);
    _bufferedSink!.addBytes(bytes);
    _length += bytes.length;
  }

  @override
  void writeInt(int value) {
    assert(value >= 0 && value >> 30 == 0);
    if (value < 0x80) {
      _bufferedSink!.addByte(value);
      _length += 1;
    } else if (value < 0x4000) {
      _bufferedSink!.addByte2((value >> 8) | 0x80, value & 0xFF);
      _length += 2;
    } else {
      _bufferedSink!.addByte4((value >> 24) | 0xC0, (value >> 16) & 0xFF,
          (value >> 8) & 0xFF, value & 0xFF);
      _length += 4;
    }
  }

  @override
  void writeEnum(dynamic value) {
    writeInt(value.index);
  }

  @override
  void close() {
    _bufferedSink!.flushAndDestroy();
    _bufferedSink = null;
    sink.close();
  }
}
