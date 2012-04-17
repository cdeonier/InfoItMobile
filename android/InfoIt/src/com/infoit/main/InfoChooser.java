package com.infoit.main;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;

import com.google.android.apps.analytics.easytracking.TrackedActivity;

public class InfoChooser extends TrackedActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
  }
  
  @Override
  protected void onResume() {
    super.onResume();
    
    BaseApplication.initializeShell(this, R.layout.info_chooser);
    
    setContentView(BaseApplication.getView());
    
    FrameLayout nfcInstructionsView = (FrameLayout) findViewById(R.id.nfc_choice);
    nfcInstructionsView.setOnClickListener(new OnClickListener(){

      @Override
      public void onClick(View v) {
        Intent nfcIntent = new Intent(BaseApplication.getCurrentActivity(), NfcInstructions.class);
        BaseApplication.getCurrentActivity().startActivity(nfcIntent);
      }
    });
    
    FrameLayout qrCodeView = (FrameLayout) findViewById(R.id.qr_choice);
    qrCodeView.setOnClickListener(new OnClickListener(){
      @Override
      public void onClick(View v) {
        Intent qrCaptureIntent = new Intent(BaseApplication.getCurrentActivity(),QrCodeCapture.class);
        BaseApplication.getCurrentActivity().startActivity(qrCaptureIntent);
      }
    });
    
    FrameLayout gpsView = (FrameLayout) findViewById(R.id.gps_choice);
    gpsView.setOnClickListener(new OnClickListener(){
      @Override
      public void onClick(View v) {
        Intent nearbyLocations = new Intent(BaseApplication.getCurrentActivity(), NearbyLocations.class);
        BaseApplication.getCurrentActivity().startActivity(nearbyLocations);
      }
    });
  }
  
  @Override
  protected void onPause() {
    super.onPause();
    
    BaseApplication.detachShell();
  }

  
  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    setIntent(intent);
  }
  
  @Override
  public void onBackPressed() {
    if(BaseApplication.getView() == null || BaseApplication.getView().isActivityView()) {
      finish();
    } else {
    	BaseApplication.getView().scrollToApplicationView();
    }
    return;
  }

}
