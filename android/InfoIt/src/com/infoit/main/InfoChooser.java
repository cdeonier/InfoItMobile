package com.infoit.main;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;

public class InfoChooser extends Activity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    android.os.Debug.waitForDebugger();
    super.onCreate(savedInstanceState);
    
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    setContentView(R.layout.info_chooser);
    
    FrameLayout qrCodeView = (FrameLayout) findViewById(R.id.qr_choice);
    qrCodeView.setOnClickListener(new OnClickListener(){

      @Override
      public void onClick(View v) {
        Intent qrCaptureIntent = new Intent(v.getContext(),
            QrCodeCapture.class);
        v.getContext().startActivity(qrCaptureIntent);
      }
    });
  }

}
