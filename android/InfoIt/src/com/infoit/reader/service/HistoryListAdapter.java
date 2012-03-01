package com.infoit.reader.service;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.support.v4.widget.CursorAdapter;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.infoit.constants.Constants;
import com.infoit.main.DisplayInfo;
import com.infoit.main.R;
import com.infoit.reader.record.ListItemRecord;

public class HistoryListAdapter extends CursorAdapter {
  public HistoryListAdapter(Context context, Cursor cursor, int flags) {
    super(context, cursor, flags);
  }

  @Override
  public void bindView(View view, Context context, Cursor cursor) {
    TextView recentItemText = (TextView) view.findViewById(R.id.recent_item_text);
    FrameLayout detailButton = (FrameLayout) view.findViewById(R.id.detail_button);
    
    int identifier = cursor.getInt(cursor.getColumnIndex(DbAdapter.KEY_ENTITY_ID));
    String name = cursor.getString(cursor.getColumnIndex(DbAdapter.KEY_HISTORY_ITEM_NAME));
    
    OnRecentItemClickListener recentItemListener = new OnRecentItemClickListener(identifier, name);
    
    recentItemText.setText(name);
    recentItemText.setOnClickListener(recentItemListener);
    detailButton.setOnClickListener(recentItemListener);
  } 

  @Override
  public View newView(Context context, Cursor cursor, ViewGroup parent) {
    View row = View.inflate(context, R.layout.history_list_item, null);
    
    int rowHeight = (int) (50 * context.getResources().getDisplayMetrics().density);
    row.setLayoutParams(new ListView.LayoutParams(ListView.LayoutParams.MATCH_PARENT, rowHeight));
    
    return row;
  }
  
  private class OnRecentItemClickListener implements OnClickListener {
    private final ListItemRecord mListItem;
    
    public OnRecentItemClickListener(int identifier, String name) {
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
}
