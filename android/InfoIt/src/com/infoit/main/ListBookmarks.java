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

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.adapters.BookmarkCategoryAdapter;
import com.infoit.adapters.BookmarkListAdapter;
import com.infoit.adapters.DbAdapter;
import com.infoit.adapters.SeparatedListAdapter;
import com.infoit.async.BookmarksListTask;
import com.infoit.constants.Constants;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class ListBookmarks extends TrackedActivity {
  private DbAdapter mDb;
  private BookmarkListAdapter mPlaceBookmarksListAdapter;
  private BookmarkListAdapter mThingBookmarksListAdapter;
  private SeparatedListAdapter mListAdapter;
  private UiMenuHorizontalScrollView mApplicationContainer;
  private ListView mBookmarksList;
  private int mDeleteCount;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    
    mApplicationContainer 
      = ShellUtil.initializeApplicationContainer(this, R.layout.ui_navigation_menu, 
                                                       R.layout.ui_empty_action_menu, 
                                                       R.layout.bookmarks_list);
    ShellUtil.clearActionMenuButton(mApplicationContainer);
    mDb = new DbAdapter(this);
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
    mListAdapter = null;
    mPlaceBookmarksListAdapter = null;
    mThingBookmarksListAdapter = null;
    mDb.close();
  }
  
  @Override
  public void onBackPressed() {
    if(mApplicationContainer == null ||  mApplicationContainer.isApplicationView()) {
      finish();
    } else {
      mApplicationContainer.scrollToApplicationView();
    }
    return;
  }
  
  private void initializeBookmarkList() {
	mBookmarksList = (ListView) findViewById(R.id.bookmarks_list);
	mDeleteCount = 0;
	
	BookmarkCategoryAdapter headerAdapter = new BookmarkCategoryAdapter(this, R.layout.bookmark_list_header, R.id.bookmark_list_header_title, null);
	mListAdapter = new SeparatedListAdapter(this, headerAdapter);
	  
    Cursor placeBookmarksCursor = mDb.fetchAllPlaceBookmarks();
    if (placeBookmarksCursor.getCount() > 0) {
	    startManagingCursor(placeBookmarksCursor);
	    mPlaceBookmarksListAdapter = new BookmarkListAdapter(this, placeBookmarksCursor, 0);
	    mListAdapter.addSection("Places", mPlaceBookmarksListAdapter);
    }
    
    Cursor thingBookmakrsCursor = mDb.fetchAllThingBookmarks();
    if (thingBookmakrsCursor.getCount() > 0) {
	    startManagingCursor(thingBookmakrsCursor);
	    mThingBookmarksListAdapter = new BookmarkListAdapter(this, thingBookmakrsCursor, 1);
	    mListAdapter.addSection("Things", mThingBookmarksListAdapter);
    }
    
    mBookmarksList.setAdapter(mListAdapter);
  }
  
  public void resetNotification() {
	mDeleteCount--;
	
	if (mDeleteCount < 1) {
	    FrameLayout notificationBox = (FrameLayout) findViewById(R.id.notification);
	    mDeleteCount = 0;
	    notificationBox.setVisibility(View.GONE);
	}
  }
  
  public void setNotificationDelete() {
    FrameLayout notificationBox = (FrameLayout) findViewById(R.id.notification);
    TextView notificationText = (TextView) findViewById(R.id.notification_text);
    
    mDeleteCount++;
    
    notificationText.setText("Delete");
    notificationBox.setOnClickListener(new OnClickListener() {
      
      @Override
      public void onClick(View v) {
    	if (mPlaceBookmarksListAdapter != null) {
    		new BookmarksListTask((Activity) v.getContext(), mPlaceBookmarksListAdapter, 
        					  BookmarksListTask.DELETE_BOOKMARKS, Constants.PLACE).execute();
    	}
    	if (mThingBookmarksListAdapter != null) {
    		new BookmarksListTask((Activity) v.getContext(), mThingBookmarksListAdapter, 
				  			  BookmarksListTask.DELETE_BOOKMARKS, Constants.THING).execute();
    	}
        mDeleteCount = 0;
        setNotificationUndoRemoveBookmarks();
      }
    });
    notificationBox.setVisibility(View.VISIBLE);
  }

  public void setNotificationUndoRemoveBookmarks() {
    FrameLayout notificationBox = (FrameLayout) findViewById(R.id.notification);
    TextView notificationText = (TextView) findViewById(R.id.notification_text);
    
    mDeleteCount = 0;
    
    notificationText.setText("Undo");
    notificationBox.setOnClickListener(new OnClickListener() {
      
      @Override
      public void onClick(View v) {
    	if (mPlaceBookmarksListAdapter != null) {
    		new BookmarksListTask((Activity) v.getContext(), mPlaceBookmarksListAdapter, 
        					  BookmarksListTask.UNDO_DELETE_BOOKMARKS, Constants.PLACE).execute();
    	}
    	if (mThingBookmarksListAdapter != null) {
    		new BookmarksListTask((Activity) v.getContext(), mThingBookmarksListAdapter, 
				  			  BookmarksListTask.UNDO_DELETE_BOOKMARKS, Constants.THING).execute();
    	}
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
  
  public DbAdapter getDb() {
    return mDb;
  }
  
  public SeparatedListAdapter getListAdapter() {
	  return mListAdapter;
  }

}
