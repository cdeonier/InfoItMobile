package com.infoit.reader.service;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.support.v4.widget.CursorAdapter;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.infoit.constants.Constants;
import com.infoit.main.DisplayInfo;
import com.infoit.main.ListBookmarks;
import com.infoit.main.R;
import com.infoit.reader.record.BookmarkRecord;

public class BookmarkListAdapter extends CursorAdapter {
  
  protected ListView mListView;
  protected ArrayList<BookmarkRecord> mSelectedBookmarkIdentifiers;
  protected ArrayList<BookmarkRecord> mDeletedBookmarkIdentifiers;
  protected ListBookmarks mActivity;
  protected BookmarkDbAdapter mDb;

  public BookmarkListAdapter(Context context, Cursor cursor, int flags) {
    super(context, cursor, flags);
    mListView = ((ListBookmarks) context).getBookmarksList();
    mActivity =  (ListBookmarks) context;
    mDb = mActivity.getDb();
    mSelectedBookmarkIdentifiers = new ArrayList<BookmarkRecord>();
    mDeletedBookmarkIdentifiers = new ArrayList<BookmarkRecord>();
  }
  
  @Override
  public View newView(Context context, Cursor cursor, ViewGroup parent) {
    View row = View.inflate(context, R.layout.bookmarks_list_item, null);
    
    int rowHeight = (int) (50 * context.getResources().getDisplayMetrics().density);
    
    row.setLayoutParams(new ListView.LayoutParams(ListView.LayoutParams.MATCH_PARENT, rowHeight));

    FrameLayout checkbox = (FrameLayout) row.findViewById(R.id.bookmark_checkbox);
    FrameLayout detailButton = (FrameLayout) row.findViewById(R.id.detail_button);
    TextView bookmarkTitle = (TextView) row.findViewById(R.id.bookmark_text);
    
    int identifier = cursor.getInt(cursor.getColumnIndex(BookmarkDbAdapter.KEY_ENTITY_ID));
    String name = cursor.getString(cursor.getColumnIndex(BookmarkDbAdapter.KEY_BOOKMARK_NAME));
    
    checkbox.setOnClickListener(new OnCheckboxClickListener(identifier, name));
    bookmarkTitle.setOnClickListener(new OnBookmarkClickListener(identifier, name));
    detailButton.setOnClickListener(new OnBookmarkClickListener(identifier, name));
    
    return row;
  }

  @Override
  public void bindView(View view, Context context, Cursor cursor) {
    ImageView checkbox = (ImageView) view.findViewById(R.id.bookmark_checkbox_icon);
    TextView bookmarkTitle = (TextView) view.findViewById(R.id.bookmark_text);
    
    checkbox.setImageResource(R.drawable.ui_unchecked_box_icon);
    bookmarkTitle.setText(cursor.getString(cursor.getColumnIndex(BookmarkDbAdapter.KEY_BOOKMARK_NAME)));
  }
  
  public void removeSelectedBookmarks() {
    for (BookmarkRecord identifier : mSelectedBookmarkIdentifiers) {
      mDb.deleteLocationBookmark(identifier.getIdentifier());
    }
    mDeletedBookmarkIdentifiers.addAll(mSelectedBookmarkIdentifiers);
    mSelectedBookmarkIdentifiers.clear();
  }
  
  public void undoDeleteBookmarks() {
    for (BookmarkRecord identifier : mDeletedBookmarkIdentifiers) {
      mDb.createLocationBookmark(identifier.getIdentifier(), identifier.getName());
    }
    mDeletedBookmarkIdentifiers.clear();
  }
  
  public BookmarkDbAdapter getDb() {
    return mDb;
  }
  
  private class OnBookmarkClickListener implements OnClickListener {
    private BookmarkRecord mBookmarkRecord;
    
    public OnBookmarkClickListener(int identifier, String name) {
      mBookmarkRecord = new BookmarkRecord(identifier, name);
    }

    @Override
    public void onClick(View view) {
      Intent displayInfoIntent = new Intent(view.getContext(), DisplayInfo.class);
      displayInfoIntent.setAction(Constants.BOOKMARK);
      displayInfoIntent.putExtra("identifier", mBookmarkRecord.getIdentifier());
      view.getContext().startActivity(displayInfoIntent);
    }
  }
  
  private class OnCheckboxClickListener implements OnClickListener {
    private BookmarkRecord mBookmarkRecord;
    private boolean mChecked;
    
    public OnCheckboxClickListener(int identifier, String name) {
      mBookmarkRecord = new BookmarkRecord(identifier, name);
      mChecked = false;
    }

    @Override
    public void onClick(View view) {
      ImageView checkbox = (ImageView) view.findViewById(R.id.bookmark_checkbox_icon);
      
      
      if (mChecked) {
        checkbox.setImageResource(R.drawable.ui_unchecked_box_icon);
        mChecked = false;
        mSelectedBookmarkIdentifiers.remove(mBookmarkRecord);
        if (mSelectedBookmarkIdentifiers.size() == 0) {
          mActivity.resetNotification();
        }
      } else {
        checkbox.setImageResource(R.drawable.ui_checked_box_icon);
        mChecked = true;
        mSelectedBookmarkIdentifiers.add(mBookmarkRecord);
        mActivity.setNotificationDelete();
      }
      
    }
  }
}
