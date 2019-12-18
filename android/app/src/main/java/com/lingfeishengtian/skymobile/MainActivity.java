package com.lingfeishengtian.skymobile;

import android.content.ComponentName;
import android.os.Bundle;
import android.view.WindowManager;
import android.content.pm.PackageManager;

import io.flutter.app.FlutterFragmentActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterFragmentActivity {
  private static final String CHANNEL = "com.lingfeishengtian.SkyMobile/choose_icon";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler(){
      public void onMethodCall(MethodCall call, MethodChannel.Result result){
        if(call.method.equals("changeIcon")){
          String iconName = call.argument("iconName");
        /*
          Icon1,2,3,4,IconChristmas are valid.
         */
          System.out.println(iconName);
          getPackageManager().setComponentEnabledSetting(
                  getComponentName(), PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP);
          getPackageManager().setComponentEnabledSetting(
                  new ComponentName("com.lingfeishengtian.skymobile", "com.lingfeishengtian.skymobile.Main" + iconName),
                  PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP
          );
          result.success("YES!");
        }
      }
    });
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
