package com.infoit.adapters;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.infoit.async.DownloadThumbnailTask;
import com.infoit.async.TaskTrackerRunnable;
import com.infoit.constants.Constants;
import com.infoit.main.DisplayInfo;
import com.infoit.main.R;
import com.infoit.record.MenuItemRecord;

public class MenuItemListAdapter extends ArrayAdapter<MenuItemRecord> {
	private ArrayList<MenuItemRecord> mMenuItems;
	private Drawable[] mThumbnails;
	private Typeface mFont;
	
	
	public MenuItemListAdapter(Context context, int resource, int textViewResourceId, 
			List<MenuItemRecord> objects) {
		super(context, textViewResourceId, objects);
		mMenuItems = new ArrayList<MenuItemRecord>();
		mFont = Typeface.createFromAsset(context.getAssets(), "fonts/nyala.ttf");
	}
	
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder;
		
		MenuItemRecord currentMenuItem = mMenuItems.get(position);
		
		if (convertView == null) {
			holder = new ViewHolder();
		
			if (currentMenuItem.getDescription() != null  && !currentMenuItem.getDescription().equals("")) {
				convertView = View.inflate(this.getContext(), R.layout.menu_list_item, null);
				holder.description = (TextView) convertView.findViewById(R.id.menu_item_description);
			} else {
				convertView = View.inflate(this.getContext(), R.layout.menu_list_item_no_description, null);
			}
		
			holder.name = (TextView) convertView.findViewById(R.id.menu_item_name);
			holder.price = (TextView) convertView.findViewById(R.id.menu_item_price);
			holder.thumbnail = (ImageView) convertView.findViewById(R.id.menu_item_thumbnail);
			holder.progressBar = (ProgressBar) convertView.findViewById(R.id.menu_item_thumbnail_progress);
			holder.likeContainer = (RelativeLayout) convertView.findViewById(R.id.menu_item_like_container);
			holder.likeText = (TextView) convertView.findViewById(R.id.menu_item_like_number);
			
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}
		
		if(holder.description != null) {
			holder.description.setText(currentMenuItem.getDescription());
			holder.description.setTypeface(mFont);
		}
		
		holder.thumbnail.setImageDrawable(null);
		
		if (mThumbnails[position] == null) {
			if (currentMenuItem.getThumbnailUrl() != null && !currentMenuItem.getThumbnailUrl().equals("")) {
				holder.progressBar.setVisibility(View.VISIBLE);
				DownloadThumbnailTask thumbnailsTask = 
						new DownloadThumbnailTask(holder.thumbnail, holder.progressBar, mThumbnails, position);
				thumbnailsTask.execute(currentMenuItem.getThumbnailUrl());
				Handler handler = new Handler();
		    handler.postDelayed(new TaskTrackerRunnable(thumbnailsTask), 20000);
			} else {
				Drawable thumbnail = convertView.getResources().getDrawable(R.drawable.basic_no_thumbnail);
				holder.progressBar.setVisibility(View.GONE);
				holder.thumbnail.setImageDrawable(thumbnail);
				mThumbnails[position] = thumbnail;
			}
		} else {
			holder.thumbnail.setImageDrawable(mThumbnails[position]);
		}
		
		holder.name.setText(currentMenuItem.getName());
		holder.name.setTypeface(mFont, Typeface.BOLD);

		holder.price.setText("$"+currentMenuItem.getPrice());
		holder.price.setTypeface(mFont);
		
		
		if (currentMenuItem.getLikeCount() == 0) {
			holder.likeContainer.setVisibility(View.GONE);
		} else if (currentMenuItem.getLikeCount() == 1) {
			holder.likeText.setText("1 like");
		} else {
			holder.likeText.setText(String.valueOf(currentMenuItem.getLikeCount())+" likes");
		}
		
		convertView.setOnClickListener(new MenuItemOnClickListener(currentMenuItem.getEntityId()));
	    
	  return convertView;
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
	
	@Override
	public void sort(Comparator<? super MenuItemRecord> comparator) {
		Collections.sort(mMenuItems, comparator);
		Collections.reverse(mMenuItems);
		this.notifyDataSetChanged();
	}

	public void setMenuItems(ArrayList<MenuItemRecord> menuItems) {
		mMenuItems = menuItems;
		mThumbnails = new Drawable[mMenuItems.size()];
	}

	
	/**
	 * Simple OnClickListener to drill down to the menu item Display Info page.
	 * 
	 * @author Christian
	 *
	 */
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
	
	private static class ViewHolder {
		TextView name;
		TextView description;
		TextView price;
		TextView likeText;
		RelativeLayout likeContainer;
		ProgressBar progressBar;
		ImageView thumbnail;
	}
}
