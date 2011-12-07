package com.infoit.nfc.activity;

import android.app.ListActivity;
import android.database.Cursor;
import android.os.Bundle;
import android.widget.SimpleCursorAdapter;

import com.infoit.nfc.activity.R;
import com.infoit.nfc.service.TagsDbAdapter;

public class ListTags extends ListActivity {
	
	private TagsDbAdapter mDbHelper;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.list_tags);
		mDbHelper = new TagsDbAdapter(this);
		mDbHelper.open();
		fillData();
	}
	
	private void fillData() {
		Cursor tagsCursor = mDbHelper.fetchAllTags();
		startManagingCursor(tagsCursor);
		
		String[] from = new String[]{TagsDbAdapter.KEY_LOCATION_ID};
		int[] to = new int[]{R.id.text1};
		
		SimpleCursorAdapter tags =
			new SimpleCursorAdapter(this, R.layout.tags_row, tagsCursor, from, to);
		setListAdapter(tags);
	}

}
