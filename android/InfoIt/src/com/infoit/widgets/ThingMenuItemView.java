package com.infoit.widgets;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.infoit.main.R;
import com.infoit.record.BasicInformation;
import com.infoit.widgetBlocks.BasicView;

public class ThingMenuItemView extends LinearLayout {
	private Activity mActivity;

	private BasicInformation mBasicInformation;
	
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

		BasicView basicView = new BasicView(this.getContext());

		basicView.setInformation(mBasicInformation);

		container.addView(basicView, container.getChildCount());

		basicView.setContentButtons(mActivity);

		RelativeLayout spacer = new RelativeLayout(mActivity);
		// 50 should work, but not displaying correctly, so nudging to 70
		int menuBarHeight = (int) (50 * mActivity.getResources()
				.getDisplayMetrics().density);
		spacer.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,
				menuBarHeight));
		container.addView(spacer);
	}
}
