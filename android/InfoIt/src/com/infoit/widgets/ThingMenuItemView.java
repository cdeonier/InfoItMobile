package com.infoit.widgets;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.infoit.constants.Constants;
import com.infoit.main.DisplayMenu;
import com.infoit.main.R;
import com.infoit.record.BasicInformation;
import com.infoit.record.MenuItemInformation;
import com.infoit.widgetBlocks.BasicView;
import com.infoit.widgetBlocks.MenuItemView;
import com.infoit.widgetBlocks.MenuView;

public class ThingMenuItemView extends LinearLayout {
	private Activity mActivity;

	private BasicInformation mBasicInformation;
	private MenuItemInformation mMenuItemInformation;
	
	public ThingMenuItemView(Context context) {
		super(context);
		mActivity = (Activity) context;
		LayoutInflater.from(context).inflate(R.layout.thing_menu_item, this);
	}

	public ThingMenuItemView(Context context, AttributeSet attrs, int defStyle) {
		super(context);
		mActivity = (Activity) context;
		LayoutInflater.from(context).inflate(R.layout.thing_menu_item, this);
	}

	public ThingMenuItemView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mActivity = (Activity) context;
		LayoutInflater.from(context).inflate(R.layout.thing_menu_item, this);
	}
	
	public void initializeView(JsonNode rootNode) {
		LinearLayout container = (LinearLayout) findViewById(R.id.menu_item_container);

		mBasicInformation = new BasicInformation(rootNode);
		mMenuItemInformation = new MenuItemInformation(rootNode);

		BasicView basicView = new BasicView(this.getContext());
		basicView.setInformation(mBasicInformation);
		container.addView(basicView, container.getChildCount());
		basicView.setContentButtons(mActivity);
		
		MenuView menuView = new MenuView(this.getContext());
		menuView.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent menuIntent = new Intent(v.getContext(), DisplayMenu.class);
				menuIntent.setAction(Constants.DISPLAY_INFO);
				menuIntent.putExtra("identifier", mMenuItemInformation.getRestaurantId());
				v.getContext().startActivity(menuIntent);
			}
		});
		container.addView(menuView, container.getChildCount());
		
		MenuItemView menuItemView = new MenuItemView(this.getContext());
		container.addView(menuItemView, container.getChildCount());

		RelativeLayout spacer = new RelativeLayout(mActivity);
		// 50 should work, but not displaying correctly, so nudging to 70
		int menuBarHeight = (int) (75 * mActivity.getResources().getDisplayMetrics().density);
		spacer.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, menuBarHeight));
		container.addView(spacer);
	}
}
