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
import android.view.WindowManager;
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
import com.infoit.ui.UiShell;

public class DisplayMenu extends TrackedActivity {
	private UiShell mApplicationContainer;
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
		
		getIdentifier();
		
		BaseApplication.initializeShell(this, R.layout.menu);
		BaseApplication.hideActionsMenu();
		setContentView(BaseApplication.getView());

		if(Constants.RESTAURANT.equals(getIntent().getAction())) {
			String jsonAsString = getIntent().getExtras().getString("menu");
			JsonNode json = WebServiceAdapter.createJsonFromString(jsonAsString);
			mMenuInformation = new MenuInformation(json);
			mCurrentMenuType = (String) ((Set<String>) mMenuInformation.getMenuTypes()).iterator().next();
			initializeMenuTypeSelector();
			initializeList();
			initializeAdapters();
		} else {
			BaseApplication.setSplashScreen();
			new LoadMenuTask(this, mRestaurantIdentifier).execute();
		}
	}

	@Override
	protected void onPause() {
		super.onPause();

		BaseApplication.detachShell();

		mMenuItemList = null;
	}

	@Override
	public void onBackPressed() {
		if (BaseApplication.getView() == null || BaseApplication.getView().isActivityView()) {
			finish();
		} else {
			BaseApplication.getView().scrollToApplicationView();
		}
		return;
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
				EasyTracker.getTracker().trackEvent(Constants.ACTIVITY_CATEGORY, Constants.ACTIVITY_BUTTON, Constants.RESTAURANT_BUTTON, 0);
	      Intent displayInfoIntent = new Intent(BaseApplication.getCurrentActivity(), DisplayInfo.class);
	      displayInfoIntent.setAction(Constants.MENU);
	      displayInfoIntent.putExtra("identifier", mRestaurantIdentifier);
	      BaseApplication.getCurrentActivity().startActivity(displayInfoIntent);
			}
		});
		
		RelativeLayout mostLikedButton = (RelativeLayout) header.findViewById(R.id.most_liked_button);
		mostLikedButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				EasyTracker.getTracker().trackEvent(Constants.ACTIVITY_CATEGORY, Constants.ACTIVITY_BUTTON, Constants.MOST_LIKED_BUTTON, 0);
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

		WindowManager w = getWindowManager();
		Display d = w.getDefaultDisplay();
		int screenWidth = d.getWidth();
		if (menuTypesContainer.getChildCount() * menuTypeWidth < screenWidth) {
			RelativeLayout blank = new RelativeLayout(this);
			int blankWidth = screenWidth - menuTypesContainer.getChildCount() * menuTypeWidth;
			blank.setLayoutParams(new LinearLayout.LayoutParams(blankWidth, menuTypeHeight));
			Drawable menuTypeDrawable = getResources().getDrawable(R.drawable.menu_types_container);
			blank.setBackgroundDrawable(menuTypeDrawable);
			menuTypesContainer.addView(blank);
		}

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

	public UiShell getApplicationContainer() {
		return mApplicationContainer;
	}

	public void setApplicationContainer(UiShell applicationContainer) {
		mApplicationContainer = applicationContainer;
	}
	
	private void getIdentifier() {
		if (NfcAdapter.ACTION_NDEF_DISCOVERED.equals(getIntent().getAction())) {
			Parcelable[] rawMsgs = getIntent().getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
			NdefMessage rawUrl = (NdefMessage) rawMsgs[0];
			NdefRecord rawUrlRecord = rawUrl.getRecords()[0];
			byte[] payload = rawUrlRecord.getPayload();
			String uri = new String(Arrays.copyOfRange(payload, 1, payload.length));
			mRestaurantIdentifier = Integer.parseInt(uri.split("/menus/")[1]);
		} else {
			mRestaurantIdentifier = getIntent().getExtras().getInt("identifier");
		}
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
