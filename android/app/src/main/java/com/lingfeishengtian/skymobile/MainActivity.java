package com.lingfeishengtian.skymobile;

import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager;

import io.flutter.app.FlutterFragmentActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterFragmentActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
  }

//  @Override
//  public void onResume() {
//    super.onResume();
//    getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
//  }
//
//  @Override
//  public void onPause() {
//    super.onPause();
//    getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
//  }
}
