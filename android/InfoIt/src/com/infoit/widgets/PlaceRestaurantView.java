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
import com.infoit.record.LocationInformation;
import com.infoit.widgetBlocks.AddressView;
import com.infoit.widgetBlocks.BasicView;
import com.infoit.widgetBlocks.MenuView;

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
		MenuView menuView = new MenuView(this.getContext());
		
		final String jsonAsString = rootNode.path("entity").path("place_details").toString();
		
		menuView.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent menuIntent = new Intent(v.getContext(), DisplayMenu.class);
				menuIntent.setAction(Constants.DISPLAY_INFO);
				menuIntent.putExtra("menu", jsonAsString);
				menuIntent.putExtra("identifier", mBasicInformation.getEntityId());
				v.getContext().startActivity(menuIntent);
			}
		});

		basicView.setInformation(mBasicInformation);
		addressView.setInformation(mLocationInformation);

		container.addView(basicView, container.getChildCount());
		container.addView(menuView, container.getChildCount());
		container.addView(addressView, container.getChildCount());

		basicView.setContentButtons(mActivity);
		addressView.setContentButtons(mActivity);

		RelativeLayout spacer = new RelativeLayout(mActivity);
		// 50 should work, but not displaying correctly, so nudging to 70
		int menuBarHeight = (int) (50 * mActivity.getResources().getDisplayMetrics().density);
		spacer.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, menuBarHeight));
		container.addView(spacer);
	}
}
