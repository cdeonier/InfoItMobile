package com.infoit.adapters;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.infoit.constants.Constants;
import com.infoit.main.BaseApplication;
import com.infoit.main.DisplayInfo;
import com.infoit.main.R;
import com.infoit.record.MenuItemListRecord;
import com.infoit.ui.NoImageDrawable;
import com.infoit.util.ImageUtil;

public class MenuItemListAdapter extends ArrayAdapter<MenuItemListRecord> {
	private ArrayList<MenuItemListRecord> mMenuItems;
	private Drawable[] mThumbnails;
	private Typeface mFont;
	
	
	public MenuItemListAdapter(Context context, int resource, int textViewResourceId, 
			List<MenuItemListRecord> objects) {
		super(context, textViewResourceId, objects);
		mMenuItems = new ArrayList<MenuItemListRecord>();
		mFont = Typeface.createFromAsset(context.getAssets(), "fonts/nyala.ttf");
	}
	
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder;
		
		MenuItemListRecord currentMenuItem = mMenuItems.get(position);
		
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
			String currentDescription = currentMenuItem.getDescription();
			
			//We have a description for item, but the view doesn't have description field means we inflate new view
			if (currentDescription != null  && !currentDescription.equals("") && holder.description == null) {
				holder = new ViewHolder();
				convertView = View.inflate(this.getContext(), R.layout.menu_list_item, null);
				holder.description = (TextView) convertView.findViewById(R.id.menu_item_description);
				holder.name = (TextView) convertView.findViewById(R.id.menu_item_name);
				holder.price = (TextView) convertView.findViewById(R.id.menu_item_price);
				holder.thumbnail = (ImageView) convertView.findViewById(R.id.menu_item_thumbnail);
				holder.progressBar = (ProgressBar) convertView.findViewById(R.id.menu_item_thumbnail_progress);
				holder.likeContainer = (RelativeLayout) convertView.findViewById(R.id.menu_item_like_container);
				holder.likeText = (TextView) convertView.findViewById(R.id.menu_item_like_number);
				convertView.setTag(holder);
			} else if ((currentDescription == null || currentDescription.equals("")) && holder.description != null) {
				holder = new ViewHolder();
				convertView = View.inflate(this.getContext(), R.layout.menu_list_item_no_description, null);
				holder.description = null;
				holder.name = (TextView) convertView.findViewById(R.id.menu_item_name);
				holder.price = (TextView) convertView.findViewById(R.id.menu_item_price);
				holder.thumbnail = (ImageView) convertView.findViewById(R.id.menu_item_thumbnail);
				holder.progressBar = (ProgressBar) convertView.findViewById(R.id.menu_item_thumbnail_progress);
				holder.likeContainer = (RelativeLayout) convertView.findViewById(R.id.menu_item_like_container);
				holder.likeText = (TextView) convertView.findViewById(R.id.menu_item_like_number);
				convertView.setTag(holder);
			}
		}
		
		if(holder.description != null) {
			holder.description.setText(currentMenuItem.getDescription());
			holder.description.setTypeface(mFont);
		}
		
		holder.thumbnail.setImageDrawable(null);
		
		if (mThumbnails[position] == null) {
			if (currentMenuItem.getThumbnailUrl() != null && !currentMenuItem.getThumbnailUrl().equals("")) {
				holder.progressBar.setVisibility(View.VISIBLE);
				String thumbnailUrl = currentMenuItem.getThumbnailUrl();
				ImageUtil.downloadThumbnail(thumbnailUrl, holder.thumbnail, holder.progressBar, mThumbnails, position);
			} else {
				holder.progressBar.setVisibility(View.GONE);
				
				Resources res = BaseApplication.getCurrentActivity().getResources();
				Drawable thumbnail = convertView.getResources().getDrawable(R.drawable.basic_no_thumbnail);
				Bitmap bm = ((BitmapDrawable) thumbnail).getBitmap();
				NoImageDrawable noImage = new NoImageDrawable(currentMenuItem.getEntityId(), res, bm);
				holder.thumbnail.setImageDrawable(noImage);
				holder.thumbnail.setOnClickListener(noImage.getOnClickListener());
				mThumbnails[position] = noImage;
			}
		} else {
			holder.thumbnail.setImageDrawable(mThumbnails[position]);
			if (mThumbnails[position] instanceof NoImageDrawable) {
				holder.thumbnail.setOnClickListener(((NoImageDrawable) mThumbnails[position]).getOnClickListener());
			}
		}
		
		holder.name.setText(currentMenuItem.getName());
		holder.name.setTypeface(mFont, Typeface.BOLD);

		holder.price.setText("$"+currentMenuItem.getPrice());
		holder.price.setTypeface(mFont);
		
		
		if (currentMenuItem.getLikeCount() == 0) {
			holder.likeContainer.setVisibility(View.GONE);
		} else if (currentMenuItem.getLikeCount() == 1) {
			holder.likeContainer.setVisibility(View.VISIBLE);
			holder.likeText.setText("1 like");
		} else {
			holder.likeContainer.setVisibility(View.VISIBLE);
			holder.likeText.setText(String.valueOf(currentMenuItem.getLikeCount())+" likes");
		}
		
		convertView.setOnClickListener(new MenuItemOnClickListener(currentMenuItem.getEntityId()));
	    
	  return convertView;
	}

	@Override
	public void add(MenuItemListRecord menuItem) {
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
	public MenuItemListRecord getItem(int position) {
		return mMenuItems.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public int getPosition(MenuItemListRecord item) {
		return mMenuItems.indexOf(item);
	}
	
	@Override
	public void sort(Comparator<? super MenuItemListRecord> comparator) {
		Collections.sort(mMenuItems, comparator);
		Collections.reverse(mMenuItems);
		this.notifyDataSetChanged();
	}

	public void setMenuItems(ArrayList<MenuItemListRecord> menuItems) {
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
