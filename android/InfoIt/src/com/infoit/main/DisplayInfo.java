package com.infoit.main;

import java.util.Arrays;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.os.Bundle;
import android.os.Parcelable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.infoit.adapters.DbAdapter;
import com.infoit.async.LoadInformationTask;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class DisplayInfo extends Activity {
  private DbAdapter mDb;
  private UiMenuHorizontalScrollView mApplicationContainer;
  private int mIdentifier;

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
       
    mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
        R.layout.ui_navigation_menu, R.layout.display_info_actions_menu,
        R.layout.display_info);
    
    setSplashScreen();
    
    mDb = new DbAdapter(this);
    mDb.open();

    new LoadInformationTask(this, mIdentifier).execute();

    mApplicationContainer.scrollToApplicationView();
  }

  @Override
  protected void onPause() {
    super.onPause();
    
    unbindDrawables(mApplicationContainer);
    mApplicationContainer = null;
    mDb.close();
    mDb = null;
  }
  
  @Override
  protected void onDestroy() {
    super.onDestroy();
  }
  
  @Override
  public void onBackPressed() {
    if(mApplicationContainer.isApplicationView()) {
      finish();
    } else {
      mApplicationContainer.scrollToApplicationView();
    }
    return;
  }
  
  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    setIntent(intent);
    nfcStart();
  }
  
  private void unbindDrawables(View view) {
    if (view.getBackground() != null) {
      view.getBackground().setCallback(null);
    }
    if (view instanceof ViewGroup) {
      for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
        unbindDrawables(((ViewGroup) view).getChildAt(i));
      }
      ((ViewGroup) view).removeAllViews();
    }
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
        setSplashScreen();
        mIdentifier = identifier;
      }
    }
  }
  
  private void setSplashScreen() {
    UiMenuHorizontalScrollView splashContainer = 
        ShellUtil.initializeApplicationContainer(this, R.layout.ui_navigation_menu, 
                                                       R.layout.ui_empty_action_menu, 
                                                       R.layout.ui_splash_screen);
    TextView splashText = (TextView) splashContainer.findViewById(R.id.splash_text);
	splashText.setText("Downloading information...");
    setContentView(splashContainer);
  }
  
  public void syncBookmarkButtons() {
    TextView name = (TextView) getApplicationContainer().findViewById(R.id.basic_name);
    
    ImageView actionMenuIcon = (ImageView) getApplicationContainer().findViewById(R.id.bookmark_icon);  
    ImageView contentIcon = (ImageView) findViewById(R.id.basic_bookmark_icon);
    TextView contentBookmarkButtonText = (TextView) findViewById(R.id.basic_bookmark_text);  
    TextView actionMenuBookmarkButtonText = (TextView) getApplicationContainer().findViewById(R.id.bookmark_button_text);
    
    if (contentBookmarkButtonText.getText().toString().contains("Bookmark this place")) {
      mDb.createLocationBookmark(mIdentifier, (String) name.getText());
      contentBookmarkButtonText.setText("Remove Bookmark");
      actionMenuBookmarkButtonText.setText("Remove Bookmark");
      contentIcon.setImageResource(R.drawable.bookmark_icon);
      actionMenuIcon.setImageResource(R.drawable.bookmark_icon);
    } else {
      mDb.deleteLocationBookmark(mIdentifier);
      contentBookmarkButtonText.setText("Bookmark this place");
      actionMenuBookmarkButtonText.setText("Bookmark this place");
      contentIcon.setImageResource(R.drawable.bookmark_unbookmark_icon);
      actionMenuIcon.setImageResource(R.drawable.bookmark_unbookmark_icon);
    }
  }
  
  public UiMenuHorizontalScrollView getApplicationContainer() {
    return mApplicationContainer;
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
}
