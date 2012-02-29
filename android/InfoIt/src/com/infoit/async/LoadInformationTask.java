package com.infoit.async;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.os.AsyncTask;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.main.DisplayInfo;
import com.infoit.main.R;
import com.infoit.reader.service.BookmarkDbAdapter;
import com.infoit.reader.service.WebServiceAdapter;
import com.infoit.widgets.PlaceRealEstateView;

public class LoadInformationTask extends AsyncTask<Void, Void, Void> {
  final private Activity mActivity;
  final private int mIdentifier;
  
  public LoadInformationTask(Activity activity, int identifier) {
    mActivity = activity;
    mIdentifier = identifier;
  }

  @Override
  protected Void doInBackground(Void... params) {
    final JsonNode webServiceResponse = WebServiceAdapter.getInformationAsJson(mIdentifier);
   
    if("place".equals(WebServiceAdapter.getEntityType(webServiceResponse))){
      if("Real Estate Property".equals(WebServiceAdapter.getEntitySubType(webServiceResponse))){
        final PlaceRealEstateView child = new PlaceRealEstateView(mActivity);
        child.initializeView(webServiceResponse);

        mActivity.runOnUiThread(new Runnable() {    
          @Override
          public void run() {
            DisplayInfo displayActivity = (DisplayInfo) mActivity;

            LinearLayout content = (LinearLayout) displayActivity.getApplicationContainer().findViewById(R.id.content);
            content.removeViewAt(content.getChildCount() - 1);
            content.addView(child, content.getChildCount() - 1);
            
            initializeActionMenu();
          }
        });
        
      }
    }
    
    return null;
  }

  @Override
  protected void onPostExecute(Void result) {
    DisplayInfo displayActivity = (DisplayInfo) mActivity;
    displayActivity.setContentView(displayActivity.getApplicationContainer());
  }
  
  private void initializeActionMenu() {
    final DisplayInfo displayActivity = (DisplayInfo) mActivity;
    final BookmarkDbAdapter db = displayActivity.getDbAdapter();
    
    LinearLayout bookmarkButton = (LinearLayout) displayActivity.getApplicationContainer()
        .findViewById(R.id.action_display_info_bookmark_button);
    final ImageView icon = (ImageView) displayActivity.getApplicationContainer().findViewById(R.id.bookmark_icon);
    final TextView bookmarkButtonText = (TextView) displayActivity.getApplicationContainer().findViewById(R.id.bookmark_button_text);
    
    if (db.doesBookmarkExist(mIdentifier)) {
      bookmarkButtonText.setText("Remove Bookmark");
      icon.setImageResource(R.drawable.bookmark_icon);
    }
    bookmarkButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        displayActivity.syncBookmarkButtons();
      }
    });
  }

}
