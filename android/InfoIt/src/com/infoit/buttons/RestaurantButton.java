package com.infoit.buttons;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;

import com.infoit.constants.Constants;
import com.infoit.main.BaseApplication;
import com.infoit.main.DisplayInfo;
import com.infoit.main.R;

public class RestaurantButton extends BaseButton implements ActionButton {

	private int mRestaurantIdentifier;

	public RestaurantButton(int buttonIconId, String buttonText) {
		super(buttonIconId, buttonText);
	}

	@Override
	public View makeSmallButton() {
		return null;
	}

	@Override
	public View makeLargeButton() {
		Activity currentActivity = BaseApplication.getCurrentActivity();
		Resources applicationResources = BaseApplication.getCurrentActivity().getResources();
		
		int five_dip = (int) (5 * currentActivity.getResources().getDisplayMetrics().density);
		int ten_dip = (int) (10 * currentActivity.getResources().getDisplayMetrics().density);
		int buttonHeight = (int) (45 * currentActivity.getResources().getDisplayMetrics().density);
		
		LinearLayout button = new LinearLayout(BaseApplication.getCurrentActivity());
		button.setOrientation(LinearLayout.HORIZONTAL);
		Drawable buttonBackground = applicationResources.getDrawable(R.drawable.basic_button);
		button.setBackgroundDrawable(buttonBackground);
		LayoutParams buttonParams = new LayoutParams(LayoutParams.MATCH_PARENT, buttonHeight);
		buttonParams.setMargins(ten_dip, 0, ten_dip, five_dip);
		
		ImageView buttonIcon = new ImageView(BaseApplication.getCurrentActivity());
		Drawable buttonIconImage = applicationResources.getDrawable(getButtonIconId());
		buttonIcon.setImageDrawable(buttonIconImage);
		LayoutParams iconParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		iconParams.setMargins(ten_dip, 0, 0, 0);
		iconParams.gravity = Gravity.CENTER_VERTICAL;
		
		TextView buttonText = new TextView(BaseApplication.getCurrentActivity());
		buttonText.setText(getButtonText());
		buttonText.setTextColor(Color.BLACK);
		buttonText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20);
		LayoutParams textParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
		buttonText.setPadding(ten_dip, ten_dip, ten_dip, ten_dip);
		
		button.addView(buttonIcon, iconParams);
		button.addView(buttonText, textParams);
		
		setImageView(buttonIcon);
		setTextView(buttonText);
		
		ButtonOnClickListener clickListener = new ButtonOnClickListener();
		button.setOnClickListener(clickListener);
		
		//For Actions Menu
		setOnClickListener(clickListener);
		
		BaseApplication.addActionsButton(this);
		
		return button;
	}

	public void setRestaurantIdentifier(int identifier) {
		mRestaurantIdentifier = identifier;
	}

	private class ButtonOnClickListener implements OnClickListener {
		@Override
		public void onClick(View view) {
			Intent displayIntent = new Intent(BaseApplication.getCurrentActivity(), DisplayInfo.class);
			displayIntent.setAction(Constants.MENU_ITEM);
			displayIntent.putExtra("identifier", mRestaurantIdentifier);
			BaseApplication.getCurrentActivity().startActivity(displayIntent);
		}
	}

}
