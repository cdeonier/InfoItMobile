package com.infoit.adapters;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.graphics.Typeface;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.infoit.async.DownloadThumbnailTask;
import com.infoit.main.R;
import com.infoit.record.MenuItemRecord;

public class MenuItemListAdapter extends ArrayAdapter<MenuItemRecord> {
	private ArrayList<MenuItemRecord> mMenuItems;
	private Typeface mFont;
	
	
	public MenuItemListAdapter(Context context, int resource, int textViewResourceId, 
			List<MenuItemRecord> objects) {
		super(context, textViewResourceId, objects);
		mMenuItems = new ArrayList<MenuItemRecord>();
		mFont = Typeface.createFromAsset(context.getAssets(), "fonts/nyala.ttf"); 
	}
	
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View row = View.inflate(this.getContext(), R.layout.menu_list_item, null);
		
		MenuItemRecord currentMenuItem = mMenuItems.get(position);
		
		TextView rowName = (TextView) row.findViewById(R.id.menu_item_name);
		rowName.setText(currentMenuItem.getName());
		rowName.setTypeface(mFont, Typeface.BOLD);
		TextView rowDescription = (TextView) row.findViewById(R.id.menu_item_description);
		rowDescription.setText(currentMenuItem.getDescription());
		rowDescription.setTypeface(mFont);
		ImageView rowThumbnail = (ImageView) row.findViewById(R.id.menu_item_thumbnail);
		ProgressBar rowImageProgress = (ProgressBar) row.findViewById(R.id.menu_item_thumbnail_progress);
		new DownloadThumbnailTask(rowThumbnail, rowImageProgress).execute(currentMenuItem.getThumbnailUrl());
		TextView rowPrice = (TextView) row.findViewById(R.id.menu_item_price);
		rowPrice.setText("$"+currentMenuItem.getPrice());
		rowPrice.setTypeface(mFont);
	    
	    return row;
	}

	@Override
	public void add(MenuItemRecord menuItem) {
		mMenuItems.add(menuItem);
	}

	@Override
	public void clear() {
		mMenuItems.clear();
	}

	@Override
	public int getCount() {
		return mMenuItems.size();
	}

	@Override
	public MenuItemRecord getItem(int position) {
		return mMenuItems.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public int getPosition(MenuItemRecord item) {
		return mMenuItems.indexOf(item);
	}
	
	public void setMenuItems(ArrayList<MenuItemRecord> menuItems) {
		mMenuItems = menuItems;
	}

}
