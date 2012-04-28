package com.infoit.main;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.util.TypedValue;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.infoit.buttons.BaseButton;
import com.infoit.ui.UiShell;
import com.infoit.widgets.listeners.UiMenuOnClickListener;
import com.infoit.widgets.listeners.UiNavigationItemOnClickListener;

public class BaseApplication extends Application {
	
	private static UiShell mShell;
	private static Activity mCurrentActivity;
	private static FrameLayout mContentContainer;

	@Override
	public void onCreate() {
		super.onCreate();
		
		LayoutInflater inflater = LayoutInflater.from(this);
		mShell = (UiShell) inflater.inflate(R.layout.ui_application_container, null);
		
    View navMenu = inflater.inflate(R.layout.ui_navigation_menu, null);
    View actionsMenu = inflater.inflate(R.layout.ui_actions_menu, null);
    View activityContainer = inflater.inflate(R.layout.ui_activity_container, null);
    
    RelativeLayout touchInterceptor = (RelativeLayout) activityContainer.findViewById(R.id.touch_interceptor);
    RelativeLayout menuButton = (RelativeLayout) activityContainer.findViewById(R.id.menu_button);
    RelativeLayout actionsButton = (RelativeLayout) activityContainer.findViewById(R.id.action_button);
    
    menuButton.setOnClickListener(new UiMenuOnClickListener(mShell, navMenu, touchInterceptor, 0));
    actionsButton.setOnClickListener(new UiMenuOnClickListener(mShell, actionsMenu, touchInterceptor, 2));
    
    final View[] children = new View[] { navMenu, activityContainer, actionsMenu };
    int scrollToViewIndex = 1;
    mShell.initViews(children, scrollToViewIndex);
    
    mContentContainer = (FrameLayout) mShell.findViewById(R.id.content_container);
	}

	public static void initializeShell(Activity activity, int layoutId) {
		mCurrentActivity = activity;
		
		//First, initialize Navigation menu
    LinearLayout bookmarksListButton = (LinearLayout) mShell.findViewById(R.id.nav_bookmarks_list_button);
    bookmarksListButton.setOnClickListener(new UiNavigationItemOnClickListener(mShell, ListBookmarks.class, activity));
    LinearLayout historyListButton = (LinearLayout) mShell.findViewById(R.id.nav_recent_history_button);
    historyListButton.setOnClickListener(new UiNavigationItemOnClickListener(mShell, RecentHistory.class, activity));
    LinearLayout accountsButton = (LinearLayout) mShell.findViewById(R.id.nav_account_button);
    accountsButton.setOnClickListener(new UiNavigationItemOnClickListener(mShell, Account.class, activity));
    
    //Then Actions menu
    clearActionsMenu();
    
    RelativeLayout infoItButton = (RelativeLayout) mShell.findViewById(R.id.infoit_button);
    infoItButton.setOnClickListener(new OnClickListener() {
      @Override
      public void onClick(View v) {
        Intent intent = new Intent(mCurrentActivity, InfoChooser.class);
        mCurrentActivity.startActivity(intent);
      }
    });
    
    setBackgroundColor(R.color.standard_bg);
    
    setActivityContent(layoutId);
    mShell.scrollToApplicationView();
	}
	
	public static void detachShell() {
		//Basically, contentView of Activity, we're doing the opposite of setContentView
		ViewGroup parent = (ViewGroup) mShell.getParent();
		parent.removeView(mShell);

		//Clear out activity specific stuff from shell
		clearActionsMenu();
		unbindDrawables(mShell.findViewById(R.id.content_container));
	}
	
	public static void hideActionsMenu() {
		RelativeLayout actionsButton = (RelativeLayout) mShell.findViewById(R.id.action_button);
		actionsButton.setOnClickListener(null);
		actionsButton.setVisibility(View.INVISIBLE);
	}
	
	public static void showActionsMenu() {
		RelativeLayout actionsButton = (RelativeLayout) mShell.findViewById(R.id.action_button);
		RelativeLayout touchInterceptor = (RelativeLayout) mShell.findViewById(R.id.touch_interceptor);
		View actionsMenu = mShell.getActionMenuView();
		actionsButton.setOnClickListener(new UiMenuOnClickListener(mShell, actionsMenu, touchInterceptor, 2));
		actionsButton.setVisibility(View.VISIBLE);
	}
	
	public static void addActionsButton(BaseButton baseButton) {
		Drawable iconImage = mShell.getResources().getDrawable(baseButton.getButtonIconId());
		
		int ten_dip = (int) (10 * mShell.getResources().getDisplayMetrics().density);
		
		ImageView buttonIcon = new ImageView(mShell.getContext());
		buttonIcon.setImageDrawable(iconImage);
		LayoutParams iconParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		iconParams.setMargins(ten_dip, 0, 0, 0);
		iconParams.gravity = Gravity.CENTER_VERTICAL;
		
		TextView buttonText = new TextView(mShell.getContext());
		buttonText.setText(baseButton.getButtonText());
		buttonText.setTextColor(Color.WHITE);
		buttonText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20);
		LayoutParams textParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
		buttonText.setPadding(ten_dip, ten_dip, ten_dip, ten_dip);
		
		LinearLayout button = new LinearLayout(mShell.getContext());
		button.addView(buttonIcon, iconParams);
		button.addView(buttonText, textParams);
		
		baseButton.setActionImageView(buttonIcon);
		baseButton.setActionTextView(buttonText);
		
		button.setOnClickListener(baseButton.getOnClickListener());
		
		ActionButtonRunnable addButtonRunnable = new ActionButtonRunnable(button);
		mCurrentActivity.runOnUiThread(addButtonRunnable);
	}
	
	public static void setSplashScreen() {
		LayoutInflater inflater = LayoutInflater.from(mShell.getContext());
		View splashScreen = (View) inflater.inflate(R.layout.ui_splash_screen, null);

		TextView splashText = (TextView) splashScreen.findViewById(R.id.splash_text);
		splashText.setText("Downloading information...");

		FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		mContentContainer.addView(splashScreen, 0, lp);
		
		mContentContainer.getChildAt(1).setVisibility(View.INVISIBLE);
	}
	
	public static void removeSplashScreen() {
		mContentContainer.getChildAt(1).setVisibility(View.VISIBLE);
		mContentContainer.removeViewAt(0);
	}
	
	private static void setContentContainerSize() {
		// 50 should work, but not displaying correctly, so nudging to 70
		int menuBarHeight = (int) (75 * mCurrentActivity.getResources().getDisplayMetrics().density);
		Display display = mCurrentActivity.getWindowManager().getDefaultDisplay();
		mContentContainer.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, display.getHeight() - menuBarHeight));
	}
	
	private static void setActivityContent(int layoutId) {
		LayoutInflater inflater = LayoutInflater.from(mShell.getContext());
		View content = (View) inflater.inflate(layoutId, null);
		
		FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		setContentContainerSize();
		mContentContainer.addView(content, lp);
	}
	
	public static void setBackgroundColor(int color) {
		FrameLayout activityContainer = (FrameLayout) mShell.findViewById(R.id.activity_container);
		activityContainer.setBackgroundResource(color);
	}
	
	public static UiShell getView() {
		return mShell;
	}
	
	public static Activity getCurrentActivity() {
		return mCurrentActivity;
	}
	
	private static void clearActionsMenu() {
		LinearLayout actionsButtons = (LinearLayout) mShell.findViewById(R.id.action_buttons_container);
		actionsButtons.removeAllViews();
	}
	
	private static void unbindDrawables(View view) {
		if (view.getBackground() != null) {
			view.getBackground().setCallback(null);
		}
		if (view instanceof ViewGroup && !(view instanceof AdapterView)) {
			for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
				unbindDrawables(((ViewGroup) view).getChildAt(i));
			}
			((ViewGroup) view).removeAllViews();
		}
	}
	
	private static class ActionButtonRunnable implements Runnable {
		private LinearLayout mButton;
		
		public ActionButtonRunnable(LinearLayout button) {
			mButton = button;
		}

		@Override
		public void run() {
			LinearLayout actionsButtons = (LinearLayout) mShell.findViewById(R.id.action_buttons_container);
			
			ImageView menuSeparator = new ImageView(mShell.getContext());
			Drawable menuSeparatorImage = mShell.getResources().getDrawable(R.drawable.ui_menu_separator);
			menuSeparator.setImageDrawable(menuSeparatorImage);
			menuSeparator.setScaleType(ScaleType.FIT_XY);
			LayoutParams separatorParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
			
			actionsButtons.addView(mButton, actionsButtons.getChildCount());
			actionsButtons.addView(menuSeparator, separatorParams);
		}
	}
}
