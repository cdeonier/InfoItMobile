package com.infoit.main;

import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;

import com.infoit.util.ShellUtil;

public class DisplayEntityInfo extends FragmentActivity {

  @Override
  public void onCreate(Bundle savedInstanceState) {
    

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    setContentView(R.layout.display_entity_info);
    
    ShellUtil.initializeShellForActivity(this);
  }

}
