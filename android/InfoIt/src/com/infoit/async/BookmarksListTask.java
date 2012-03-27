package com.infoit.async;

import android.app.Activity;
import android.database.Cursor;
import android.os.AsyncTask;

import com.infoit.adapters.BookmarkListAdapter;
import com.infoit.constants.Constants;
import com.infoit.main.ListBookmarks;

public class BookmarksListTask extends AsyncTask<Void, Void, Void> {
  public static final int DELETE_BOOKMARKS = 1;
  public static final int UNDO_DELETE_BOOKMARKS = 2;
  
  private final Activity mActivity;
  private final BookmarkListAdapter mListAdapter;
  private final int mAction;
  private final String mEntityType;
  
  public BookmarksListTask(Activity activity, BookmarkListAdapter listAdapter, int action, String entityType) {
    mAction = action;
    mListAdapter = listAdapter;
    mActivity = activity;
    mEntityType = entityType;
  }
  
  @Override
  protected Void doInBackground(Void... arg0) {
    if (BookmarksListTask.DELETE_BOOKMARKS == mAction) {
      mListAdapter.removeSelectedBookmarks();
    } else if (BookmarksListTask.UNDO_DELETE_BOOKMARKS == mAction) {
      mListAdapter.undoDeleteBookmarks();
    }
      
    return null;
  }
  
  @Override
  protected void onPostExecute(Void result) {
	Cursor bookmarksCursor = null;
	if (Constants.PLACE.equals(mEntityType)) {
		bookmarksCursor = mListAdapter.getDb().fetchAllPlaceBookmarks();
	} else if (Constants.THING.equals(mEntityType)) {
		bookmarksCursor = mListAdapter.getDb().fetchAllThingBookmarks();
	}
    mActivity.startManagingCursor(bookmarksCursor);
    
    mListAdapter.changeCursor(bookmarksCursor);
    mListAdapter.notifyDataSetChanged();
    
    ((ListBookmarks) mActivity).getListAdapter().notifyDataSetChanged();
  }
}
