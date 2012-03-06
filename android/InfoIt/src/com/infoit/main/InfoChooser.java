package com.infoit.main;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.Display;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;
import android.widget.LinearLayout;

import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class InfoChooser extends Activity {
  private UiMenuHorizontalScrollView mApplicationContainer;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
  }
  
  @Override
  protected void onResume() {
    super.onResume();
    
    mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
        R.layout.ui_navigation_menu, R.layout.ui_empty_action_menu,
        R.layout.info_chooser);
    ShellUtil.clearActionMenuButton(mApplicationContainer);
    
    //50 should work, but not displaying correctly, so nudging to 70
    int menuBarHeight = (int) (70 * getResources().getDisplayMetrics().density);
    Display display = getWindowManager().getDefaultDisplay();

    LinearLayout container = (LinearLayout) findViewById(R.id.container);
    container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, display.getHeight() - menuBarHeight));
    
    FrameLayout nfcInstructionsView = (FrameLayout) findViewById(R.id.nfc_choice);
    nfcInstructionsView.setOnClickListener(new OnClickListener(){

      @Override
      public void onClick(View v) {
        Intent nfcIntent = new Intent(v.getContext(),
            NfcInstructions.class);
        v.getContext().startActivity(nfcIntent);
      }
    });
    
    FrameLayout qrCodeView = (FrameLayout) findViewById(R.id.qr_choice);
    qrCodeView.setOnClickListener(new OnClickListener(){

      @Override
      public void onClick(View v) {
        Intent qrCaptureIntent = new Intent(v.getContext(),
            QrCodeCapture.class);
        v.getContext().startActivity(qrCaptureIntent);
      }
    });
    
    FrameLayout gpsView = (FrameLayout) findViewById(R.id.gps_choice);
    gpsView.setOnClickListener(new OnClickListener(){

      @Override
      public void onClick(View v) {
        Intent nearbyLocations = new Intent(v.getContext(),
            NearbyLocations.class);
        v.getContext().startActivity(nearbyLocations);
      }
    });
    
    mApplicationContainer.scrollToApplicationView();
  }
  
  @Override
  protected void onPause() {
    super.onPause();
    
    unbindDrawables(mApplicationContainer);
    mApplicationContainer = null;
  }
  
  private void unbindDrawables(View view) {
    if (view.getBackground() != null) {
      view.getBackground().setCallback(null);
    }
    if (view instanceof ViewGroup) {
      for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
        unbindDrawables(((ViewGroup) view).getChildAt(i));
      }
      ((ViewGroup) view).removeAllViews();
    }
  }
  
  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    setIntent(intent);
  }
  
  @Override
  public void onBackPressed() {
    if(mApplicationContainer.isApplicationView()) {
      finish();
    } else {
      mApplicationContainer.scrollToApplicationView();
    }
    return;
  }

}
