package com.infoit.main;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;
import android.widget.Toast;

import com.infoit.reader.service.BookmarkDbAdapter;

public class ListBookmarks extends Activity {
  private BookmarkDbAdapter mDbHelper;
  private ListView mBookmarksList;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    
    android.os.Debug.waitingForDebugger();

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    setContentView(R.layout.list_bookmarks);

    mBookmarksList = (ListView) findViewById(R.id.bookmarks_list);

    mDbHelper = new BookmarkDbAdapter(this);
    mDbHelper.open();
    fillData();
    
    mBookmarksList.setOnItemClickListener(new OnItemClickListener() {

      @Override
      public void onItemClick(AdapterView<?> parent, View view, int position,
          long id) {
        Context context = view.getContext();
        Cursor itemCursor = (Cursor) parent.getItemAtPosition(position);
        Toast.makeText(context, itemCursor.getString(1), 1000).show();
        
      }
    });

  }

  private void fillData() {
    Cursor bookmarksCursor = mDbHelper.fetchAllLocationBookmarks();
    startManagingCursor(bookmarksCursor);

    String[] from = new String[] { BookmarkDbAdapter.KEY_BOOKMARK_NAME };
    int[] to = new int[] { R.id.bookmark_text };

    SimpleCursorAdapter bookmarks = new SimpleCursorAdapter(this,
        R.layout.bookmark_list_item, bookmarksCursor, from, to);
    mBookmarksList.setAdapter(bookmarks);
  }

}
