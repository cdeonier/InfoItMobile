package com.infoit.main;

import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.os.Bundle;
import android.widget.ListView;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.adapters.DbAdapter;
import com.infoit.adapters.HistoryListAdapter;

public class RecentHistory extends TrackedActivity {
  private DbAdapter mDb;
  private ListView mRecentHistory;
  private HistoryListAdapter mHistoryListAdapter;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

    mDb = new DbAdapter(this);
  }

  @Override
  protected void onResume() {
    super.onResume();
    
    BaseApplication.initializeShell(this, R.layout.history_list);
    BaseApplication.hideActionsMenu();
    setContentView(BaseApplication.getView());
    
    mDb.open();
    initializeRecentHistory();
  }

  @Override
  protected void onPause() {
    super.onPause();
    
    BaseApplication.detachShell();
    
    mDb.close();
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
  }

  @Override
  public void onBackPressed() {
    if (BaseApplication.getView() == null || BaseApplication.getView().isActivityView()) {
      finish();
    } else {
    	BaseApplication.getView().scrollToApplicationView();
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
