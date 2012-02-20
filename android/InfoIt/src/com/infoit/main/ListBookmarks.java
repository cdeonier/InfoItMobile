package com.infoit.main;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

import com.infoit.constants.Constants;
import com.infoit.reader.service.BookmarkDbAdapter;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class ListBookmarks extends Activity {
  private BookmarkDbAdapter mDbHelper;
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
    
    mDbHelper = new BookmarkDbAdapter(this);
  }
  
  @Override
  protected void onResume(){
    super.onResume();
    mDbHelper.open();

    initializeBookmarkList();
    
    mApplicationContainer.scrollToApplicationView();
  }
  
  @Override 
  protected void onPause(){
    super.onPause();
    mBookmarksList.setAdapter(null);
    mDbHelper.close();
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
 

  private void fillData() {
    Cursor bookmarksCursor = mDbHelper.fetchAllLocationBookmarks();
    startManagingCursor(bookmarksCursor);

    String[] from = new String[] { BookmarkDbAdapter.KEY_BOOKMARK_NAME };
    int[] to = new int[] { R.id.bookmark_text };

    SimpleCursorAdapter bookmarks = new SimpleCursorAdapter(this,
        R.layout.bookmarks_list_item, bookmarksCursor, from, to);
    mBookmarksList.setAdapter(bookmarks);
  }
  
  private void initializeBookmarkList(){
    mBookmarksList = (ListView) findViewById(R.id.bookmarks_list);

    fillData();
    
    mBookmarksList.setOnItemClickListener(new OnItemClickListener() {

      @Override
      public void onItemClick(AdapterView<?> parent, View view, int position,
          long id) {
        Context context = view.getContext();
        Cursor itemCursor = (Cursor) parent.getItemAtPosition(position);
        
        Intent displayInfoIntent = new Intent(context, DisplayInfo.class);
        displayInfoIntent.setAction(Constants.BOOKMARK);
        displayInfoIntent.putExtra("identifier", itemCursor.getInt(1));
        context.startActivity(displayInfoIntent);
      }
    });
  }

}
