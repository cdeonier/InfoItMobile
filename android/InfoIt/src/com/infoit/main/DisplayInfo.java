package com.infoit.main;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

import com.infoit.async.LoadInformationTask;
import com.infoit.reader.service.BookmarkDbAdapter;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class DisplayInfo extends Activity {
  private BookmarkDbAdapter mDbHelper;
  private UiMenuHorizontalScrollView mApplicationContainer;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    android.os.Debug.waitingForDebugger();

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

    mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
        R.layout.ui_navigation_menu, R.layout.display_info_actions_menu,
        R.layout.display_info);

    mDbHelper = new BookmarkDbAdapter(this);

    setContentView(R.layout.ui_splash_screen);
  }

  @Override
  protected void onResume() {
    super.onResume();
    mDbHelper.open();
    
    //See whether we're loading for first time, in which case we load data
    FrameLayout splashScreen = (FrameLayout) findViewById(R.id.splash_screen);
    if(splashScreen != null) {
      new LoadInformationTask(this, 1).execute();
    }

    //Leave this here to handle coming back to this activity from another activity
    RelativeLayout touchInterceptor = (RelativeLayout) mApplicationContainer.findViewById(R.id.touch_interceptor);
    touchInterceptor.setVisibility(View.GONE);
    mApplicationContainer.scrollToApplicationView();
  }

  @Override
  protected void onPause() {
    super.onPause();
    mDbHelper.close();
  }
  
  public UiMenuHorizontalScrollView getApplicationContainer() {
    return mApplicationContainer;
  }
  
  public BookmarkDbAdapter getDbAdapter() {
    return mDbHelper;
  }
}
