package com.infoit.async;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.os.AsyncTask;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.adapters.DbAdapter;
import com.infoit.adapters.WebServiceAdapter;
import com.infoit.main.DisplayInfo;
import com.infoit.main.R;
import com.infoit.record.BasicInformation;
import com.infoit.widgets.PlaceRealEstateView;
import com.infoit.widgets.PlaceRestaurantView;
import com.infoit.widgets.ThingMenuItemView;

public class LoadInformationTask extends AsyncTask<Void, Void, LinearLayout> {
  final private Activity mActivity;
  final private int mIdentifier;
  private String mEntitySubType;
  
  public LoadInformationTask(Activity activity, int identifier) {
    mActivity = activity;
    mIdentifier = identifier;
  }

  @Override
  protected LinearLayout doInBackground(Void... params) {
    final JsonNode webServiceResponse = WebServiceAdapter.getInformationAsJson(mIdentifier);
    
    //Save to recent history
    BasicInformation basicInfo = new BasicInformation(webServiceResponse);
    DbAdapter db = new DbAdapter(mActivity);
    db.open();
    db.createHistoryItem(mIdentifier, basicInfo.getName(), basicInfo.getEntityType());
    db.close();
    
    ((DisplayInfo) mActivity).setEntityType(basicInfo.getEntityType());
    ((DisplayInfo) mActivity).setEntitySubType(basicInfo.getEntitySubType());
    mEntitySubType = basicInfo.getEntitySubType();
    
    LinearLayout child = null;
    
    if ("place".equals(WebServiceAdapter.getEntityType(webServiceResponse))){
      if("Real Estate Property".equals(WebServiceAdapter.getEntitySubType(webServiceResponse))){
        child = new PlaceRealEstateView(mActivity);
        ((PlaceRealEstateView)child).initializeView(webServiceResponse);      
      } else if ("Restaurant".equals(WebServiceAdapter.getEntitySubType(webServiceResponse))) {
    	  child = new PlaceRestaurantView(mActivity);
    	  ((PlaceRestaurantView)child).initializeView(webServiceResponse);
      }
    } else if ("thing".equals(WebServiceAdapter.getEntityType(webServiceResponse))) {
    	if ("Menu Item".equals(WebServiceAdapter.getEntitySubType(webServiceResponse))) {
    		child = new ThingMenuItemView(mActivity);
    		((ThingMenuItemView)child).initializeView(webServiceResponse);
    	}
    }
    
    return child;
  }

  @Override
  protected void onPostExecute(LinearLayout child) {
    DisplayInfo displayActivity = (DisplayInfo) mActivity;

    LinearLayout content = (LinearLayout) displayActivity.getApplicationContainer().findViewById(R.id.content);
    content.removeViewAt(content.getChildCount() - 1);
    content.addView(child, content.getChildCount() - 1);
    
    initializeActionMenu();
    
    displayActivity.setContentView(displayActivity.getApplicationContainer());
  }
  
  private void initializeActionMenu() {
    final DisplayInfo displayActivity = (DisplayInfo) mActivity;
    final DbAdapter db = displayActivity.getDbAdapter();
    
    LinearLayout bookmarkButton = (LinearLayout) displayActivity.getApplicationContainer()
        .findViewById(R.id.action_display_info_bookmark_button);
    final ImageView icon = (ImageView) displayActivity.getApplicationContainer().findViewById(R.id.bookmark_icon);
    final TextView bookmarkButtonText = (TextView) displayActivity.getApplicationContainer().findViewById(R.id.bookmark_button_text);
    
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

}
