// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/assist.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'assist_processor.dart';

// todo: update for SizedBox

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FlutterWrapSizedBoxTest);
  });
}

@reflectiveTest
class FlutterWrapSizedBoxTest extends AssistProcessorTest {
  @override
  AssistKind get kind => DartAssistKind.FLUTTER_WRAP_SIZED_BOX;

  @override
  void setUp() {
    super.setUp();
    writeTestPackageConfig(
      flutter: true,
    );
  }

  Future<void> test_aroundContainer() async {
    await resolveTestCode('''
import 'package:flutter/widgets.dart';
class FakeFlutter {
  Widget f() {
    return /*caret*/Container();
  }
}
''');
    await assertHasAssist('''
import 'package:flutter/widgets.dart';
class FakeFlutter {
  Widget f() {
    return SizedBox(child: Container());
  }
}
''');
  }

  Future<void> test_aroundNamedConstructor() async {
    await resolveTestCode('''
import 'package:flutter/widgets.dart';

class MyWidget extends StatelessWidget {
  MyWidget.named();

  Widget build(BuildContext context) => Text('');
}

Widget f() {
  return MyWidget./*caret*/named();
}
''');
    await assertHasAssist('''
import 'package:flutter/widgets.dart';

class MyWidget extends StatelessWidget {
  MyWidget.named();

  Widget build(BuildContext context) => Text('');
}

Widget f() {
  return SizedBox(child: MyWidget.named());
}
''');
  }

  Future<void> test_aroundSizedBox() async {
    await resolveTestCode('''
import 'package:flutter/widgets.dart';
class FakeFlutter {
  Widget f() {
    return /*caret*/SizedBox();
  }
}
''');
    await assertNoAssist();
  }

  Future<void> test_assignment() async {
    await resolveTestCode('''
import 'package:flutter/widgets.dart';

void f() {
  Widget w;
  w = /*caret*/Container();
}
''');
    await assertHasAssist('''
import 'package:flutter/widgets.dart';

void f() {
  Widget w;
  w = SizedBox(child: Container());
}
''');
  }

  Future<void> test_expressionFunctionBody() async {
    await resolveTestCode('''
import 'package:flutter/widgets.dart';
class FakeFlutter {
  Widget f() => /*caret*/Container();
}
''');
    await assertHasAssist('''
import 'package:flutter/widgets.dart';
class FakeFlutter {
  Widget f() => SizedBox(child: Container());
}
''');
  }
}
