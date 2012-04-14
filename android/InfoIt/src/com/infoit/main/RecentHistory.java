package com.infoit.main;

import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.os.Bundle;
import android.widget.ListView;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.adapters.DbAdapter;
import com.infoit.adapters.HistoryListAdapter;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class RecentHistory extends TrackedActivity {

  private UiMenuHorizontalScrollView mApplicationContainer;
  private DbAdapter mDb;
  private ListView mRecentHistory;
  private HistoryListAdapter mHistoryListAdapter;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

    mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
        R.layout.ui_navigation_menu, R.layout.history_actions_menu,
        R.layout.history_list);
    ShellUtil.clearActionMenuButton(mApplicationContainer);
    
    mDb = new DbAdapter(this);
  }

  @Override
  protected void onResume() {
    super.onResume();
    
    mDb.open();
    initializeRecentHistory();
    
    mApplicationContainer.scrollToApplicationView();
  }

  @Override
  protected void onPause() {
    super.onPause();
    
    mDb.close();
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
  }

  @Override
  public void onBackPressed() {
    if (mApplicationContainer.isApplicationView()) {
      finish();
    } else {
      mApplicationContainer.scrollToApplicationView();
    }
    return;
  }
  
  private void initializeRecentHistory() {
    Cursor recentHistory = mDb.fetchRecentHistory();
    startManagingCursor(recentHistory);

    mRecentHistory= (ListView) findViewById(R.id.history_list);
    mHistoryListAdapter = new HistoryListAdapter(this, recentHistory, 0);
    mRecentHistory.setAdapter(mHistoryListAdapter);
  }
}
