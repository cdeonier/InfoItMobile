package com.infoit.main;

import java.util.Arrays;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Parcelable;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.adapters.DbAdapter;
import com.infoit.async.DisplayInfoTask;
import com.infoit.async.TaskTrackerRunnable;

public class DisplayInfo extends TrackedActivity {
  private DbAdapter mDb;
  private int mIdentifier;
  private String mEntityType;
  private String mEntitySubType;
  private DisplayInfoTask mTask;

@Override
  public void onCreate(Bundle savedInstanceState) {

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

    mIdentifier = getIntent().getExtras().getInt("identifier");
    if (mIdentifier == 0) {
      nfcStart();
    }
  }

  @Override
  protected void onResume() {
    super.onResume();
    
    BaseApplication.initializeShell(this, R.layout.display_info);
    BaseApplication.setSplashScreen();
    setContentView(BaseApplication.getView());
    
    mDb = new DbAdapter(this);
    mDb.open();

    mTask = new DisplayInfoTask(this, mIdentifier);
    mTask.execute();
    Handler handler = new Handler();
    handler.postDelayed(new TaskTrackerRunnable(mTask), 20000);
  }

	@Override
  protected void onPause() {
    super.onPause();
    
    if (mTask != null)
    	mTask.cancel(true);
    
    BaseApplication.detachShell();

    mDb.close();
    mDb = null;
  }
  
  @Override
  protected void onDestroy() {
    super.onDestroy();
  }
  
  @Override
  public void onBackPressed() {
    if(BaseApplication.getView() == null ||  BaseApplication.getView().isActivityView()) {
      finish();
    } else {
    	BaseApplication.getView().scrollToApplicationView();
    }
    return;
  }
  
  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    setIntent(intent);
    nfcStart();
  }
  
  private void nfcStart() {
    if (NfcAdapter.ACTION_NDEF_DISCOVERED.equals(getIntent().getAction())) {
      Parcelable[] rawMsgs = getIntent().getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
      NdefMessage rawUrl = (NdefMessage) rawMsgs[0];
      NdefRecord rawUrlRecord = rawUrl.getRecords()[0];
      byte[] payload = rawUrlRecord.getPayload();
      String uri = new String(Arrays.copyOfRange(payload, 1, payload.length));

      int identifier = Integer.parseInt(uri.split("/services/")[1]);
      
      if (identifier != mIdentifier) {
        mIdentifier = identifier;
      }
    }
  }
  
  public void syncBookmarkButtons() {
//		TextView name = (TextView) BaseApplication.getView().findViewById(R.id.basic_name);
//
//		ImageView actionMenuIcon = (ImageView) BaseApplication.getView().findViewById(R.id.bookmark_icon);
//		ImageView contentIcon = (ImageView) findViewById(R.id.basic_bookmark_icon);
//		TextView contentBookmarkButtonText = (TextView) findViewById(R.id.basic_bookmark_text);
//		TextView actionMenuBookmarkButtonText = (TextView) BaseApplication.getView().findViewById(R.id.bookmark_button_text);
//
//		if (!contentBookmarkButtonText.getText().toString().contains("Remove")) {
//			if ("place".equals(getEntityType())) {
//				mDb.createPlaceBookmark(mIdentifier, (String) name.getText());
//			} else if ("thing".equals(getEntityType())) {
//				mDb.createThingBookmark(mIdentifier, (String) name.getText());
//			}
//
//			contentBookmarkButtonText.setText("Remove Bookmark");
//			actionMenuBookmarkButtonText.setText("Remove Bookmark");
//			contentIcon.setImageResource(R.drawable.bookmark_icon);
//			actionMenuIcon.setImageResource(R.drawable.bookmark_icon);
//		} else {
//			if ("place".equals(getEntityType())) {
//				mDb.deletePlaceBookmark(mIdentifier);
//			} else if ("thing".equals(getEntityType())) {
//				mDb.deleteThingBookmark(mIdentifier);
//			}
//
//			contentBookmarkButtonText.setText("Bookmark "+getEntitySubType());
//			actionMenuBookmarkButtonText.setText("Bookmark "+getEntitySubType());
//			contentIcon.setImageResource(R.drawable.bookmark_unbookmark_icon);
//			actionMenuIcon.setImageResource(R.drawable.bookmark_unbookmark_icon);
//		}
  }
  
  public DbAdapter getDbAdapter() {
    return mDb;
  }

  public int getIdentifier() {
    return mIdentifier;
  }

  public void setIdentifier(int identifier) {
    this.mIdentifier = identifier;
  }

	public String getEntityType() {
		return mEntityType;
	}

	public void setEntityType(String entityType) {
		this.mEntityType = entityType;
	}

	public String getEntitySubType() {
		return mEntitySubType;
	}

	public void setEntitySubType(String entitySubType) {
		this.mEntitySubType = entitySubType;
	}
}
