package com.infoit.service;

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
import com.infoit.record.ListItemRecord;

public class BookmarkListAdapter extends CursorAdapter {
  
  protected ListView mListView;
  protected ArrayList<ListItemRecord> mSelectedBookmarkIdentifiers;
  protected ArrayList<ListItemRecord> mDeletedBookmarkIdentifiers;
  protected ListBookmarks mActivity;
  protected DbAdapter mDb;

  public BookmarkListAdapter(Context context, Cursor cursor, int flags) {
    super(context, cursor, flags);
    mListView = ((ListBookmarks) context).getBookmarksList();
    mActivity =  (ListBookmarks) context;
    mDb = mActivity.getDb();
    mSelectedBookmarkIdentifiers = new ArrayList<ListItemRecord>();
    mDeletedBookmarkIdentifiers = new ArrayList<ListItemRecord>();
  }
  
  @Override
  public View newView(Context context, Cursor cursor, ViewGroup parent) {
    View row = View.inflate(context, R.layout.bookmarks_list_item, null);
    
    int rowHeight = (int) (50 * context.getResources().getDisplayMetrics().density);
    row.setLayoutParams(new ListView.LayoutParams(ListView.LayoutParams.MATCH_PARENT, rowHeight));
    
    return row;
  }

  @Override
  public void bindView(View view, Context context, Cursor cursor) {
    FrameLayout checkbox = (FrameLayout) view.findViewById(R.id.bookmark_checkbox);
    ImageView checkboxIcon = (ImageView) view.findViewById(R.id.bookmark_checkbox_icon);
    FrameLayout detailButton = (FrameLayout) view.findViewById(R.id.detail_button);
    TextView bookmarkTitle = (TextView) view.findViewById(R.id.bookmark_text);
    
    checkboxIcon.setImageResource(R.drawable.ui_unchecked_box_icon);
    bookmarkTitle.setText(cursor.getString(cursor.getColumnIndex(DbAdapter.KEY_BOOKMARK_NAME)));
    
    int identifier = cursor.getInt(cursor.getColumnIndex(DbAdapter.KEY_ENTITY_ID));
    String name = cursor.getString(cursor.getColumnIndex(DbAdapter.KEY_BOOKMARK_NAME));
    
    OnCheckboxClickListener checkboxListener = new OnCheckboxClickListener(identifier, name);
    OnBookmarkClickListener bookmarkListener = new OnBookmarkClickListener(identifier, name);
    
    checkbox.setOnClickListener(checkboxListener);
    bookmarkTitle.setOnClickListener(bookmarkListener);
    detailButton.setOnClickListener(bookmarkListener);
  }
  
  public void removeSelectedBookmarks() {
    for (ListItemRecord identifier : mSelectedBookmarkIdentifiers) {
      mDb.deleteLocationBookmark(identifier.getIdentifier());
    }
    mDeletedBookmarkIdentifiers.addAll(mSelectedBookmarkIdentifiers);
    mSelectedBookmarkIdentifiers.clear();
  }
  
  public void undoDeleteBookmarks() {
    for (ListItemRecord identifier : mDeletedBookmarkIdentifiers) {
      mDb.createLocationBookmark(identifier.getIdentifier(), identifier.getName());
    }
    mDeletedBookmarkIdentifiers.clear();
  }
  
  public DbAdapter getDb() {
    return mDb;
  }
  
  private class OnBookmarkClickListener implements OnClickListener {
    private final ListItemRecord mListItem;
    
    public OnBookmarkClickListener(int identifier, String name) {
      mListItem = new ListItemRecord(identifier, name);
    }

    @Override
    public void onClick(View view) {
      Intent displayInfoIntent = new Intent(view.getContext(), DisplayInfo.class);
      displayInfoIntent.setAction(Constants.BOOKMARK);
      displayInfoIntent.putExtra("identifier", mListItem.getIdentifier());
      view.getContext().startActivity(displayInfoIntent);
    }
  }
  
  private class OnCheckboxClickListener implements OnClickListener {
    private ListItemRecord mListItem;
    private boolean mChecked;
    
    public OnCheckboxClickListener(int identifier, String name) {
      mListItem = new ListItemRecord(identifier, name);
      mChecked = false;
    }

    @Override
    public void onClick(View view) {
      ImageView checkbox = (ImageView) view.findViewById(R.id.bookmark_checkbox_icon);
      
      
      if (mChecked) {
        checkbox.setImageResource(R.drawable.ui_unchecked_box_icon);
        mChecked = false;
        mSelectedBookmarkIdentifiers.remove(mListItem);
        if (mSelectedBookmarkIdentifiers.size() == 0) {
          mActivity.resetNotification();
        }
      } else {
        checkbox.setImageResource(R.drawable.ui_checked_box_icon);
        mChecked = true;
        mSelectedBookmarkIdentifiers.add(mListItem);
        mActivity.setNotificationDelete();
      }
      
    }
  }
}
