package com.infoit.main;

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

public class ListBookmarks extends TrackedActivity {
  private DbAdapter mDb;
  private BookmarkListAdapter mPlaceBookmarksListAdapter;
  private BookmarkListAdapter mThingBookmarksListAdapter;
  private SeparatedListAdapter mListAdapter;
  private ListView mBookmarksList;
  private int mDeleteCount;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    
    mDb = new DbAdapter(this);
  }
  
  @Override
  protected void onResume(){
    super.onResume();
 
    BaseApplication.initializeShell(this, R.layout.bookmarks_list);
    BaseApplication.hideActionsMenu();
    
    setContentView(BaseApplication.getView());
    
    mDb.open();
    initializeBookmarkList();
    resetNotification();
  }
  
  @Override 
  protected void onPause(){
    super.onPause();
    
    BaseApplication.detachShell();
    mBookmarksList.setAdapter(null);
    mListAdapter = null;
    mPlaceBookmarksListAdapter = null;
    mThingBookmarksListAdapter = null;
    mDb.close();
  }
  
  @Override
  public void onBackPressed() {
    if(BaseApplication.getView() == null ||  BaseApplication.getView().isActivityView()) {
      finish();
    } else {
    	BaseApplication.getView().scrollToApplicationView();
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
    		new BookmarksListTask(BaseApplication.getCurrentActivity(), mPlaceBookmarksListAdapter, 
        					  BookmarksListTask.DELETE_BOOKMARKS, Constants.PLACE).execute();
    	}
    	if (mThingBookmarksListAdapter != null) {
    		new BookmarksListTask(BaseApplication.getCurrentActivity(), mThingBookmarksListAdapter, 
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
    		new BookmarksListTask(BaseApplication.getCurrentActivity(), mPlaceBookmarksListAdapter, 
        					  BookmarksListTask.UNDO_DELETE_BOOKMARKS, Constants.PLACE).execute();
    	}
    	if (mThingBookmarksListAdapter != null) {
    		new BookmarksListTask(BaseApplication.getCurrentActivity(), mThingBookmarksListAdapter, 
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
