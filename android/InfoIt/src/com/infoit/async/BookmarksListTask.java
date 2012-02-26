package com.infoit.async;

import android.app.Activity;
import android.database.Cursor;
import android.os.AsyncTask;

import com.infoit.reader.service.BookmarkListAdapter;

public class BookmarksListTask extends AsyncTask<Void, Void, Void> {
  public static final int DELETE_BOOKMARKS = 1;
  public static final int UNDO_DELETE_BOOKMARKS = 2;
  
  private final Activity mActivity;
  private final BookmarkListAdapter mListAdapter;
  private final int mAction;
  
  public BookmarksListTask(Activity activity, BookmarkListAdapter listAdapter, int action) {
    mAction = action;
    mListAdapter = listAdapter;
    mActivity = activity;
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
    Cursor bookmarksCursor = mListAdapter.getDb().fetchAllLocationBookmarks();
    mActivity.startManagingCursor(bookmarksCursor);
    
    mListAdapter.changeCursor(bookmarksCursor);
    mListAdapter.notifyDataSetChanged();
    
//    mActivity.runOnUiThread(new Runnable() {
//
//      @Override
//      public void run() {
//        
//      }    
//    });
    
  }
}
