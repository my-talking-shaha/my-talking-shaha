import 'package:flutter/material.dart';

bool usesCupertinoNativeUi(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}
