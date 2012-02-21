package com.infoit.main;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.Display;
import android.view.View;
import android.view.View.OnClickListener;
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
    
    mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
        R.layout.ui_navigation_menu, R.layout.display_info_actions_menu,
        R.layout.info_chooser);
    
    //50 should work, but not displaying correctly, so nudging to 70
    int menuBarHeight = (int) (70 * getResources().getDisplayMetrics().density);
    Display display = getWindowManager().getDefaultDisplay();

    LinearLayout container = (LinearLayout) findViewById(R.id.chooser_layout);
    container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, display.getHeight() - menuBarHeight));
    
    FrameLayout qrCodeView = (FrameLayout) findViewById(R.id.qr_button);
    qrCodeView.setOnClickListener(new OnClickListener(){

      @Override
      public void onClick(View v) {
        Intent qrCaptureIntent = new Intent(v.getContext(),
            QrCodeCapture.class);
        v.getContext().startActivity(qrCaptureIntent);
      }
    });
  }
  
  @Override
  protected void onResume() {
    super.onResume();
    mApplicationContainer.scrollToApplicationView();
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
