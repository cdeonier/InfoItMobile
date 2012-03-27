package com.infoit.adapters;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.infoit.main.R;

public class BookmarkCategoryAdapter extends ArrayAdapter<String> {
	
	private ArrayList<String> mBookmarkCategories;

	public BookmarkCategoryAdapter(Context context, int resource,
			int textViewResourceId, List<String> objects) {
		super(context, resource, textViewResourceId, objects);
		mBookmarkCategories = new ArrayList<String>();
	}

	@Override
	public void add(String menuCategory) {
		mBookmarkCategories.add(menuCategory);
	}

	@Override
	public void clear() {
		mBookmarkCategories.clear();
	}

	@Override
	public int getCount() {
		return mBookmarkCategories.size();
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View row = View.inflate(this.getContext(), R.layout.bookmark_list_header, null);
		
		TextView bookmarkCategory = (TextView) row.findViewById(R.id.bookmark_list_header_title);
		bookmarkCategory.setText(mBookmarkCategories.get(position));
		
		return row;
	}

	@Override
	public String getItem(int position) {
		return mBookmarkCategories.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}
	
}
