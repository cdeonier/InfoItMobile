package com.infoit.main;

import java.util.Arrays;
import java.util.Comparator;
import java.util.Set;

import org.codehaus.jackson.JsonNode;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.ColorStateList;
import android.graphics.drawable.Drawable;
import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.os.Bundle;
import android.os.Parcelable;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.FrameLayout.LayoutParams;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.apps.analytics.easytracking.EasyTracker;
import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.adapters.MenuCategoryAdapter;
import com.infoit.adapters.MenuItemListAdapter;
import com.infoit.adapters.SeparatedListAdapter;
import com.infoit.adapters.WebServiceAdapter;
import com.infoit.async.LoadMenuTask;
import com.infoit.constants.Constants;
import com.infoit.record.MenuInformation;
import com.infoit.record.MenuItemListRecord;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class DisplayMenu extends TrackedActivity {
	private UiMenuHorizontalScrollView mApplicationContainer;
	private ListView mMenuItemList;
	private MenuInformation mMenuInformation;
	private String mCurrentMenuType;
	private int mRestaurantIdentifier;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Lock to Portrait Mode
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
	}

	@Override
	protected void onResume() {
		super.onResume();

		if (NfcAdapter.ACTION_NDEF_DISCOVERED.equals(getIntent().getAction())) {
			Parcelable[] rawMsgs = getIntent().getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
			NdefMessage rawUrl = (NdefMessage) rawMsgs[0];
			NdefRecord rawUrlRecord = rawUrl.getRecords()[0];
			byte[] payload = rawUrlRecord.getPayload();
			String uri = new String(Arrays.copyOfRange(payload, 1, payload.length));
			mRestaurantIdentifier = Integer.parseInt(uri.split("/menus/")[1]);
			new LoadMenuTask(this, mRestaurantIdentifier).execute();
			setSplashScreen();
		} else if (Constants.QRCODE.equals(getIntent().getAction())) {
			mRestaurantIdentifier = getIntent().getExtras().getInt("identifier");
			new LoadMenuTask(this, mRestaurantIdentifier).execute();
		} else if (Constants.RESTAURANT.equals(getIntent().getAction())) {
			String jsonAsString = getIntent().getExtras().getString("menu");
			JsonNode json = WebServiceAdapter.createJsonFromString(jsonAsString);
			mRestaurantIdentifier = getIntent().getExtras().getInt("identifier");
			mMenuInformation = new MenuInformation(json);
			mCurrentMenuType = (String) ((Set<String>) mMenuInformation.getMenuTypes()).iterator().next();
		} else if (Constants.DISPLAY_INFO.equals(getIntent().getAction())){
			mRestaurantIdentifier = getIntent().getExtras().getInt("identifier");
			new LoadMenuTask(this, mRestaurantIdentifier).execute();
		}

		// Adapters intialized in async for NFC
		if (Constants.RESTAURANT.equals(getIntent().getAction())) {
			mApplicationContainer = ShellUtil.initializeApplicationContainer(this, R.layout.ui_navigation_menu,
					R.layout.ui_empty_action_menu, R.layout.menu);
			ShellUtil.clearActionMenuButton(mApplicationContainer);

			// 50 should work, but not displaying correctly, so nudging to 70
			int menuBarHeight = (int) (75 * getResources().getDisplayMetrics().density);
			Display display = getWindowManager().getDefaultDisplay();

			LinearLayout container = (LinearLayout) findViewById(R.id.container);
			container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, display.getHeight() - menuBarHeight));

			initializeMenuTypeSelector();
			initializeList();
			initializeAdapters();

			mApplicationContainer.scrollToApplicationView();
		}
	}

	@Override
	protected void onPause() {
		super.onPause();

		unbindDrawables(mApplicationContainer);
		mApplicationContainer = null;
		mMenuItemList = null;
	}

	@Override
	public void onBackPressed() {
		if (mApplicationContainer == null || mApplicationContainer.isApplicationView()) {
			finish();
		} else {
			mApplicationContainer.scrollToApplicationView();
		}
		return;
	}

	private void unbindDrawables(View view) {
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

	public void initializeAdapters() {	
		Set<String> currentMenuCategories = mMenuInformation.getCategoriesForMenu(mCurrentMenuType);

		MenuCategoryAdapter headerAdapter = 
				new MenuCategoryAdapter(this, R.layout.menu_list_header, R.id.list_header_title, null);
		SeparatedListAdapter menuAdapter = new SeparatedListAdapter(this, headerAdapter);

		for (String category : currentMenuCategories) {
			MenuItemListAdapter menuItemListAdapter = 
					new MenuItemListAdapter(this, R.layout.menu_list_item, R.id.menu_item_name, null);
			menuItemListAdapter.setMenuItems(mMenuInformation.getMenuItemsForCategory(mCurrentMenuType, category));

			menuAdapter.addSection(category, menuItemListAdapter);
		}

		mMenuItemList.setAdapter(menuAdapter);
	}
	
	public void initializeMostLikedAdapter() {
		EasyTracker.getTracker().trackEvent(Constants.LIKE_CATEGORY, Constants.LIKE_ACTION_MOST_LIKED, null, 0);
		
		MenuCategoryAdapter headerAdapter = 
				new MenuCategoryAdapter(this, R.layout.menu_list_header, R.id.list_header_title, null);
		SeparatedListAdapter menuAdapter = new SeparatedListAdapter(this, headerAdapter);
		
		MenuItemListAdapter mostLikedAdapter = 
				new MenuItemListAdapter(this, R.layout.menu_list_item, R.id.menu_item_name, null);
		mostLikedAdapter.setMenuItems(mMenuInformation.getAllMenuItemsForMenuType(mCurrentMenuType));
		mostLikedAdapter.sort(new MostLikedComparator());
		
		menuAdapter.addSection("Most Liked Items", mostLikedAdapter);
		
		mMenuItemList.setAdapter(menuAdapter);
	}
	
	public void initializeList() {
		mMenuItemList = (ListView) findViewById(R.id.menu_item_list);
		
		LayoutInflater inflater = getLayoutInflater();
		ViewGroup header = (ViewGroup) inflater.inflate(R.layout.menu_buttons, mMenuItemList, false);
		
		RelativeLayout restaurantButton = (RelativeLayout) header.findViewById(R.id.restaurant_button);
		restaurantButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
	      Intent displayInfoIntent = new Intent(view.getContext(), DisplayInfo.class);
	      displayInfoIntent.setAction(Constants.MENU);
	      displayInfoIntent.putExtra("identifier", mRestaurantIdentifier);
	      view.getContext().startActivity(displayInfoIntent);
			}
		});
		
		RelativeLayout mostLikedButton = (RelativeLayout) header.findViewById(R.id.most_liked_button);
		mostLikedButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				initializeMostLikedAdapter();
			}
		});
		
		mMenuItemList.addHeaderView(header);
	}

	public void initializeMenuTypeSelector() {
		LinearLayout menuTypesContainer = (LinearLayout) findViewById(R.id.menu_types);

		Set<String> menuTypes = mMenuInformation.getMenuTypes();

		int menuTypeWidth = (int) (150 * getResources().getDisplayMetrics().density);
		int menuTypeHeight = (int) (50 * getResources().getDisplayMetrics().density);

		for (String menuType : menuTypes) {
			TextView menuTypeTextView = new TextView(this);
			Drawable menuTypeDrawable = getResources().getDrawable(R.drawable.menu_types_container);
			ColorStateList menuTypeTextColor = getResources().getColorStateList(R.color.menu_type_button_text);

			menuTypeTextView.setText(menuType);
			menuTypeTextView.setBackgroundDrawable(menuTypeDrawable);
			menuTypeTextView.setTextColor(menuTypeTextColor);

			menuTypeTextView.setLayoutParams(new LinearLayout.LayoutParams(menuTypeWidth, menuTypeHeight));
			menuTypeTextView.setGravity(Gravity.CENTER);

			menuTypeTextView.setOnClickListener(new MenuTypeOnClickListener());

			menuTypesContainer.addView(menuTypeTextView);
		}

		RelativeLayout blank = new RelativeLayout(this);
		blank.setLayoutParams(new LinearLayout.LayoutParams(menuTypeWidth, menuTypeHeight));
		Drawable menuTypeDrawable = getResources().getDrawable(R.drawable.menu_types_container);
		blank.setBackgroundDrawable(menuTypeDrawable);
		menuTypesContainer.addView(blank);
		
		menuTypesContainer.getChildAt(0).setSelected(true);
	}

	private class MenuTypeOnClickListener implements OnClickListener {

		@Override
		public void onClick(View view) {
			mCurrentMenuType = (String) ((TextView) view).getText();
			initializeAdapters();
			
			LinearLayout menuTypeContainer = (LinearLayout) view.getParent();
			for (int i = 0; i < menuTypeContainer.getChildCount() - 1; i++) {
				TextView child = (TextView) (menuTypeContainer.getChildAt(i));
				child.setSelected(false);
			}
			
			view.setSelected(true);
		}

	}

	public void setMenuInformation(MenuInformation menuInformation) {
		mMenuInformation = menuInformation;
	}

	public void setCurrentMenuType(String currentMenuType) {
		mCurrentMenuType = currentMenuType;
	}
	
	public void setRestaurantIdentifier(int restaurantIdentifier) {
		mRestaurantIdentifier = restaurantIdentifier;
	}

	public UiMenuHorizontalScrollView getApplicationContainer() {
		return mApplicationContainer;
	}

	public void setApplicationContainer(UiMenuHorizontalScrollView applicationContainer) {
		mApplicationContainer = applicationContainer;
	}

	private void setSplashScreen() {
		UiMenuHorizontalScrollView splashContainer = ShellUtil.initializeApplicationContainer(this,
				R.layout.ui_navigation_menu, R.layout.ui_empty_action_menu, R.layout.ui_splash_screen);
		TextView splashText = (TextView) splashContainer.findViewById(R.id.splash_text);
		splashText.setText("Downloading information...");
		setContentView(splashContainer);
	}
	
	/**
	 * Comparator used when ordering items based on Like Count.
	 * 
	 * @author Christian
	 *
	 */
	private class MostLikedComparator implements Comparator<MenuItemListRecord> {

		@Override
		public int compare(MenuItemListRecord lhs, MenuItemListRecord rhs) {
			if (lhs.getLikeCount() < rhs.getLikeCount()) {
				return -1;
			} else if (lhs.getLikeCount() > rhs.getLikeCount()) {
				return 1;
			} else {
				return 0;
			}
		}
	}
}
