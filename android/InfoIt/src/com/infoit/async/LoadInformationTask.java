package com.infoit.async;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.android.apps.analytics.easytracking.EasyTracker;
import com.infoit.adapters.DbAdapter;
import com.infoit.adapters.WebServiceAdapter;
import com.infoit.constants.Constants;
import com.infoit.main.DisplayInfo;
import com.infoit.main.R;
import com.infoit.record.BasicInformation;
import com.infoit.util.CacheUtil;
import com.infoit.widgets.PlaceRealEstateView;
import com.infoit.widgets.PlaceRestaurantView;
import com.infoit.widgets.ThingMenuItemView;

public class LoadInformationTask extends AsyncTask<Void, Void, LinearLayout> {
  final private Activity mActivity;
  final private int mIdentifier;
  private String mEntitySubType;
  private Exception mException;
  
  public LoadInformationTask(Activity activity, int identifier) {
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

			((DisplayInfo) mActivity).setEntityType(basicInfo.getEntityType());
			((DisplayInfo) mActivity).setEntitySubType(basicInfo.getEntitySubType());
			mEntitySubType = basicInfo.getEntitySubType();



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
  	
  	DisplayInfo displayActivity = (DisplayInfo) mActivity;
  	
  	if (child != null && displayActivity != null && displayActivity.getApplicationContainer() != null) {
	    
	    LinearLayout content = (LinearLayout) displayActivity.getApplicationContainer().findViewById(R.id.content);
	    content.removeViewAt(content.getChildCount() - 1);
	    content.addView(child, content.getChildCount() - 1);
	    
	    initializeActionMenu();
	    
	    displayActivity.setContentView(displayActivity.getApplicationContainer());
  	}
  }
  
  private void initializeActionMenu() {
    final DisplayInfo displayActivity = (DisplayInfo) mActivity;
    final DbAdapter db = displayActivity.getDbAdapter();
    
    LinearLayout bookmarkButton = (LinearLayout) displayActivity.getApplicationContainer()
        .findViewById(R.id.action_display_info_bookmark_button);
    final ImageView icon = (ImageView) displayActivity.getApplicationContainer().findViewById(R.id.bookmark_icon);
    final TextView bookmarkButtonText = 
    		(TextView) displayActivity.getApplicationContainer().findViewById(R.id.bookmark_button_text);
    
    if (db.doesBookmarkExist(mIdentifier)) {
      bookmarkButtonText.setText("Remove Bookmark");
      icon.setImageResource(R.drawable.bookmark_icon);
    } else {
    	bookmarkButtonText.setText("Bookmark "+mEntitySubType);
    	icon.setImageResource(R.drawable.bookmark_unbookmark_icon);
    }
    bookmarkButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        displayActivity.syncBookmarkButtons();
      }
    });
  }

  public int getIdentifier() {
  	return mIdentifier;
  }
}
