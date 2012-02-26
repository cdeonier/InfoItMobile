package com.infoit.main;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.infoit.async.BookmarksListTask;
import com.infoit.reader.service.BookmarkDbAdapter;
import com.infoit.reader.service.BookmarkListAdapter;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class ListBookmarks extends Activity {
  private BookmarkDbAdapter mDb;
  private BookmarkListAdapter mBookmarksListAdapter;
  private UiMenuHorizontalScrollView mApplicationContainer;
  private ListView mBookmarksList;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    
    //android.os.Debug.waitingForDebugger();

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    
    mApplicationContainer 
      = ShellUtil.initializeApplicationContainer(this, R.layout.ui_navigation_menu, 
                                                       R.layout.bookmarks_actions_menu, 
                                                       R.layout.bookmarks_list);
    
    mDb = new BookmarkDbAdapter(this);
  }
  
  @Override
  protected void onResume(){
    super.onResume();
    
    mDb.open();
    initializeBookmarkList();
    
    resetNotification();
    
    mApplicationContainer.scrollToApplicationView();
  }
  
  @Override 
  protected void onPause(){
    super.onPause();
    mBookmarksList.setAdapter(null);
    mBookmarksListAdapter.changeCursor(null);
    mDb.close();
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
  
  private void initializeBookmarkList(){
    Cursor bookmarksCursor = mDb.fetchAllLocationBookmarks();
    startManagingCursor(bookmarksCursor);

    mBookmarksList = (ListView) findViewById(R.id.bookmarks_list);
    mBookmarksListAdapter = new BookmarkListAdapter(this, bookmarksCursor, 0);
    mBookmarksList.setAdapter(mBookmarksListAdapter);
  }
  
  public void resetNotification() {
    FrameLayout notificationBox = (FrameLayout) findViewById(R.id.notification);
    notificationBox.setVisibility(View.GONE);
  }
  
  public void setNotificationDelete() {
    FrameLayout notificationBox = (FrameLayout) findViewById(R.id.notification);
    TextView notificationText = (TextView) findViewById(R.id.notification_text);
    
    notificationText.setText("Delete");
    notificationBox.setOnClickListener(new OnClickListener() {
      
      @Override
      public void onClick(View v) {
        new BookmarksListTask((Activity) v.getContext(), mBookmarksListAdapter, BookmarksListTask.DELETE_BOOKMARKS).execute();
        setNotificationUndoRemoveBookmarks();
      }
    });
    notificationBox.setVisibility(View.VISIBLE);
  }

  public void setNotificationUndoRemoveBookmarks() {
    FrameLayout notificationBox = (FrameLayout) findViewById(R.id.notification);
    TextView notificationText = (TextView) findViewById(R.id.notification_text);
    
    notificationText.setText("Undo");
    notificationBox.setOnClickListener(new OnClickListener() {
      
      @Override
      public void onClick(View v) {
        new BookmarksListTask((Activity) v.getContext(), mBookmarksListAdapter, BookmarksListTask.UNDO_DELETE_BOOKMARKS).execute();
        resetNotification();
      }
    });
    notificationBox.setVisibility(View.VISIBLE);
  }

  public ListView getBookmarksList() {
    return mBookmarksList;
  }

  public void setBookmarksList(ListView bookmarksList) {
    this.mBookmarksList = bookmarksList;
  }
  
  public BookmarkDbAdapter getDb() {
    return mDb;
  }

}
