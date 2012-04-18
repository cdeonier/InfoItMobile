package com.infoit.widgets;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;

import com.infoit.buttons.BookmarkButton;
import com.infoit.buttons.ViewMenuButton;
import com.infoit.main.BaseApplication;
import com.infoit.main.R;
import com.infoit.record.BasicInformation;
import com.infoit.record.LocationInformation;
import com.infoit.widgetBlocks.AddressView;
import com.infoit.widgetBlocks.BasicView;

public class PlaceRestaurantView extends LinearLayout {
	private Activity mActivity;
	
	private BasicInformation mBasicInformation;
	private LocationInformation mLocationInformation;

	public PlaceRestaurantView(Context context) {
		super(context);
		mActivity = (Activity) context;
		LayoutInflater.from(context).inflate(R.layout.place_restaurant, this);
	}

	public PlaceRestaurantView(Context context, AttributeSet attrs, int defStyle) {
		super(context);
		mActivity = (Activity) context;
		LayoutInflater.from(context).inflate(R.layout.place_restaurant, this);
	}

	public PlaceRestaurantView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mActivity = (Activity) context;
		LayoutInflater.from(context).inflate(R.layout.place_restaurant, this);
	}

	public void initializeView(JsonNode rootNode) {
		LinearLayout container = (LinearLayout) findViewById(R.id.restaurant_container);

		mBasicInformation = new BasicInformation(rootNode);
		mLocationInformation = new LocationInformation(rootNode);

		BasicView basicView = new BasicView(this.getContext());
		AddressView addressView = new AddressView(this.getContext());

		basicView.setInformation(mBasicInformation);
		addressView.setInformation(mLocationInformation);

		container.addView(basicView, container.getChildCount());
		container.addView(addressView, container.getChildCount());

		basicView.setContentButtons(mActivity);
		addressView.setContentButtons(mActivity);

    LinearLayout buttonContainer = (LinearLayout) findViewById(R.id.basic_button_container);
    
		int five_dip = (int) (5 * BaseApplication.getCurrentActivity().getResources().getDisplayMetrics().density);
		int ten_dip = (int) (10 * BaseApplication.getCurrentActivity().getResources().getDisplayMetrics().density);
    LayoutParams buttonParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
    buttonParams.setMargins(ten_dip, five_dip, ten_dip, 0);
    
    //For this case, the arguments aren't really necessary, but give default values just in case
    BookmarkButton bookmarkButton = new BookmarkButton(R.drawable.bookmark_icon, "Add Bookmark");
    View bookmarkButtonView = bookmarkButton.makeLargeButton();
    buttonContainer.addView(bookmarkButtonView, buttonParams);
    
    ViewMenuButton menuButton = new ViewMenuButton(R.drawable.menu_icon, "View Menu");
    String jsonAsString = rootNode.path("entity").path("place_details").toString();
    menuButton.setMenuJson(jsonAsString);
    menuButton.setRestaurantIdentifier(mBasicInformation.getEntityId());
    View menuButtonView = menuButton.makeLargeButton();
    buttonContainer.addView(menuButtonView, buttonParams);
	}

}
