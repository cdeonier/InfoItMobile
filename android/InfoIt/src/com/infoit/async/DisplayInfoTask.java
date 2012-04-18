package com.infoit.async;

import org.codehaus.jackson.JsonNode;

import android.os.AsyncTask;
import android.util.Log;
import android.widget.LinearLayout;

import com.google.android.apps.analytics.easytracking.EasyTracker;
import com.infoit.adapters.DbAdapter;
import com.infoit.adapters.WebServiceAdapter;
import com.infoit.constants.Constants;
import com.infoit.main.BaseApplication;
import com.infoit.main.DisplayInfo;
import com.infoit.main.R;
import com.infoit.record.BasicInformation;
import com.infoit.util.CacheUtil;
import com.infoit.widgets.PlaceRealEstateView;
import com.infoit.widgets.PlaceRestaurantView;
import com.infoit.widgets.ThingMenuItemView;

public class DisplayInfoTask extends AsyncTask<Void, Void, LinearLayout> {
  final private DisplayInfo mActivity;
  final private int mIdentifier;
  private Exception mException;
  
  public DisplayInfoTask(DisplayInfo activity, int identifier) {
    mActivity = activity;
    mIdentifier = identifier;
  }

  @Override
  protected LinearLayout doInBackground(Void... params) {
		LinearLayout child = null;
  	
		try {
			JsonNode jsonResult = null;
			if (CacheUtil.entityJsonExists(mActivity, mIdentifier)) {
				String cachedJsonString = CacheUtil.getEntityJsonString(mActivity, mIdentifier);
				jsonResult = WebServiceAdapter.createJsonFromString(cachedJsonString);
			} else {
				jsonResult = WebServiceAdapter.getInformationAsJson(mIdentifier);
				CacheUtil.saveEntityJson(mActivity, jsonResult, mIdentifier);
			}
			
			final JsonNode jsonResponse = jsonResult;
			// Save to recent history
			BasicInformation basicInfo = new BasicInformation(jsonResponse);
			DbAdapter db = new DbAdapter(mActivity);
			db.open();
			db.createHistoryItem(mIdentifier, basicInfo.getName(), basicInfo.getEntityType());
			db.close();

			mActivity.setBasicInformation(basicInfo);

			if ("place".equals(WebServiceAdapter.getEntityType(jsonResponse))) {
				if ("Real Estate Property".equals(WebServiceAdapter.getEntitySubType(jsonResponse))) {
					child = new PlaceRealEstateView(mActivity);
					((PlaceRealEstateView) child).initializeView(jsonResponse);
				} else if ("Restaurant".equals(WebServiceAdapter.getEntitySubType(jsonResponse))) {
					EasyTracker.getTracker().trackEvent(Constants.DISPLAY_CATEGORY, Constants.RESTAURANT_DRILLDOWN, null, 0);
					child = new PlaceRestaurantView(mActivity);
					((PlaceRestaurantView) child).initializeView(jsonResponse);
				}
			} else if ("thing".equals(WebServiceAdapter.getEntityType(jsonResponse))) {
				if ("Menu Item".equals(WebServiceAdapter.getEntitySubType(jsonResponse))) {
					EasyTracker.getTracker().trackEvent(Constants.DISPLAY_CATEGORY, Constants.MENU_ITEM_ACTION_DRILLDOWN, null, 0);
					child = new ThingMenuItemView(mActivity);
					((ThingMenuItemView) child).initializeView(jsonResponse);
				}
			}
			
			
		} catch (Exception e) {
			mException = e;
		}
		
		return child;
  }

  @Override
  protected void onPostExecute(LinearLayout child) {
  	if (mException != null  && mException.getMessage() != null) {
  		Log.w("LoadInformation Async", mException.getMessage());
  	}
  	
  	if (child != null && mActivity != null) {
  		LinearLayout displayedContent = (LinearLayout) BaseApplication.getView().findViewById(R.id.displayed_content);
  		displayedContent.addView(child, displayedContent.getChildCount() - 1);
  	}
  	
  	BaseApplication.removeSplashScreen();
  }

  public int getIdentifier() {
  	return mIdentifier;
  }
}
