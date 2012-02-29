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
import android.widget.ImageView;
import android.widget.TextView;

import com.infoit.async.LoadInformationTask;
import com.infoit.reader.service.BookmarkDbAdapter;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class DisplayInfo extends Activity {
  private BookmarkDbAdapter mDb;
  private UiMenuHorizontalScrollView mApplicationContainer;
  private int mIdentifier;
  private boolean mReloadData;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    android.os.Debug.waitingForDebugger();

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

    mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
        R.layout.ui_navigation_menu, R.layout.display_info_actions_menu,
        R.layout.display_info);
    
    setSplashScreen();

    mDb = new BookmarkDbAdapter(this);
    
    mIdentifier = getIntent().getExtras().getInt("identifier");
    if (mIdentifier == 0) {
      nfcStart();
    }
    
    
    
    mReloadData = true;
  }

  @Override
  protected void onResume() {
    super.onResume();
    mDb.open();
    
    //The async task will remove splash screen when complete
    if (mReloadData) {
      mReloadData = false;
      new LoadInformationTask(this, mIdentifier).execute();
    }

    mApplicationContainer.scrollToApplicationView();
  }

  @Override
  protected void onPause() {
    super.onPause();
    mDb.close();
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
  
  private void nfcStart() {
    if (NfcAdapter.ACTION_NDEF_DISCOVERED.equals(getIntent().getAction())) {
      Parcelable[] rawMsgs = getIntent().getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
      NdefMessage rawUrl = (NdefMessage) rawMsgs[0];
      NdefRecord rawUrlRecord = rawUrl.getRecords()[0];
      byte[] payload = rawUrlRecord.getPayload();
      String uri = new String(Arrays.copyOfRange(payload, 1, payload.length));

      int identifier = Integer.parseInt(uri.split("/services/")[1]);
      
      if (identifier != mIdentifier) {
        mReloadData = true;
        setSplashScreen();
        mIdentifier = identifier;
      }
    }
  }
  
  private void setSplashScreen() {
    UiMenuHorizontalScrollView splashContainer = 
        ShellUtil.initializeApplicationContainer(this, R.layout.ui_navigation_menu, 
                                                       R.layout.ui_blank_actions_menu, 
                                                       R.layout.ui_splash_screen);
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
  
  public BookmarkDbAdapter getDbAdapter() {
    return mDb;
  }

  public int getIdentifier() {
    return mIdentifier;
  }

  public void setIdentifier(int identifier) {
    this.mIdentifier = identifier;
  }
}
