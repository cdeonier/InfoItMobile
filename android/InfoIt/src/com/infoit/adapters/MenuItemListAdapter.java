package com.infoit.adapters;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.infoit.async.DownloadThumbnailTask;
import com.infoit.constants.Constants;
import com.infoit.main.DisplayInfo;
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
		
		
		if (currentMenuItem.getLikeCount() == 0) {
			RelativeLayout likeContainer = (RelativeLayout) row.findViewById(R.id.menu_item_like_container);
			likeContainer.setVisibility(View.GONE);
		} else if (currentMenuItem.getLikeCount() == 1) {
			TextView likeText = (TextView) row.findViewById(R.id.menu_item_like_number);
			likeText.setText("1 like");
		} else {
			TextView likeText = (TextView) row.findViewById(R.id.menu_item_like_number);
			likeText.setText(String.valueOf(currentMenuItem.getLikeCount())+" likes");
		}
		
		row.setOnClickListener(new MenuItemOnClickListener(currentMenuItem.getEntityId()));
	    
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

	private class MenuItemOnClickListener implements OnClickListener {
		private int mIdentifier;
		
		public MenuItemOnClickListener(int identifier) {
			mIdentifier = identifier;
		}

		@Override
		public void onClick(View view) {
		      Intent displayInfoIntent = new Intent(view.getContext(), DisplayInfo.class);
		      displayInfoIntent.setAction(Constants.MENU);
		      displayInfoIntent.putExtra("identifier", mIdentifier);
		      view.getContext().startActivity(displayInfoIntent);	
		}
		
	}
}
