package com.infoit.main;

import com.infoit.util.ShellUtil;

import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;

public class ListSavedEntities extends FragmentActivity {
  @Override
  public void onCreate(Bundle savedInstanceState) {

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    setContentView(R.layout.list_saved_entities);

    ShellUtil.initializeShellForActivity(this);
  }
}
