package com.softbrewstudio.pacto

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (statt FlutterActivity) ist Voraussetzung fuer
// local_auth (Biometrie-Prompt der App-Sperre).
class MainActivity : FlutterFragmentActivity()
