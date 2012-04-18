package com.infoit.widgets;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;

import com.infoit.buttons.BookmarkButton;
import com.infoit.buttons.RestaurantButton;
import com.infoit.buttons.ViewMenuButton;
import com.infoit.main.BaseApplication;
import com.infoit.main.R;
import com.infoit.record.BasicInformation;
import com.infoit.record.MenuItemInformation;
import com.infoit.widgetBlocks.BasicView;

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
		
		LinearLayout buttonContainer = (LinearLayout) findViewById(R.id.basic_button_container);
		
		int five_dip = (int) (5 * BaseApplication.getCurrentActivity().getResources().getDisplayMetrics().density);
		int ten_dip = (int) (10 * BaseApplication.getCurrentActivity().getResources().getDisplayMetrics().density);
    LayoutParams buttonParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
    buttonParams.setMargins(ten_dip, five_dip, ten_dip, 0);
		
    //For this case, the arguments aren't really necessary, but give default values just in case
    BookmarkButton bookmarkButton = new BookmarkButton(R.drawable.bookmark_icon, "Add Bookmark");
    View bookmarkButtonView = bookmarkButton.makeLargeButton();
    buttonContainer.addView(bookmarkButtonView, buttonParams);
    
    RestaurantButton restaurantButton = new RestaurantButton(R.drawable.restaurant_icon, "View Restaurant");
    restaurantButton.setRestaurantIdentifier(mMenuItemInformation.getRestaurantId());
    View restaurantButtonView = restaurantButton.makeLargeButton();
    buttonContainer.addView(restaurantButtonView, buttonParams);
    
    ViewMenuButton menuButton = new ViewMenuButton(R.drawable.menu_icon, "View Menu");
    menuButton.setRestaurantIdentifier(mMenuItemInformation.getRestaurantId());
    View menuButtonView = menuButton.makeLargeButton();
    buttonContainer.addView(menuButtonView, buttonParams);
	}
}
