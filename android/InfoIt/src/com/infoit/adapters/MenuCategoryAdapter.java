package com.infoit.adapters;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.graphics.Typeface;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.infoit.main.R;

public class MenuCategoryAdapter extends ArrayAdapter<String> {
	
	private ArrayList<String> mMenuCategories;
	private Typeface mFont;

	public MenuCategoryAdapter(Context context, int resource,
			int textViewResourceId, List<String> objects) {
		super(context, resource, textViewResourceId, objects);
		mMenuCategories = new ArrayList<String>();
		mFont = Typeface.createFromAsset(context.getAssets(), "fonts/nyala.ttf"); 
	}

	@Override
	public void add(String menuCategory) {
		mMenuCategories.add(menuCategory);
	}

	@Override
	public void clear() {
		mMenuCategories.clear();
	}

	@Override
	public int getCount() {
		return mMenuCategories.size();
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if (convertView == null) {
			convertView = View.inflate(this.getContext(), R.layout.menu_list_header, null);
		}
		
		TextView menuCategory = (TextView) convertView.findViewById(R.id.list_header_title);
		menuCategory.setTypeface(mFont, Typeface.BOLD);
		menuCategory.setText(mMenuCategories.get(position));
		
		return convertView;
	}

	@Override
	public String getItem(int position) {
		return mMenuCategories.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}
	
}
