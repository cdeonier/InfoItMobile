package com.infoit.main;

import java.util.Arrays;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.os.Bundle;
import android.os.Parcelable;
import android.widget.FrameLayout;

import com.infoit.async.LoadInformationTask;
import com.infoit.reader.service.BookmarkDbAdapter;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class DisplayInfo extends Activity {
  private BookmarkDbAdapter mDbHelper;
  private UiMenuHorizontalScrollView mApplicationContainer;
  private int mIdentifier;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    android.os.Debug.waitingForDebugger();

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

    mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
        R.layout.ui_navigation_menu, R.layout.display_info_actions_menu,
        R.layout.display_info);

    mDbHelper = new BookmarkDbAdapter(this);
    
    //temp
    mIdentifier = 1;
    
    if(NfcAdapter.ACTION_NDEF_DISCOVERED.equals(getIntent().getAction())) {
      Parcelable[] rawMsgs = getIntent().getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
      NdefMessage rawUrl = (NdefMessage) rawMsgs[0];
      NdefRecord rawUrlRecord = rawUrl.getRecords()[0];
      byte[] payload = rawUrlRecord.getPayload();
      String uri = new String(Arrays.copyOfRange(payload, 1, payload.length));
      mIdentifier = Integer.parseInt(uri.split("/locations/")[1]);
    }

    setContentView(R.layout.ui_splash_screen);
  }

  @Override
  protected void onResume() {
    super.onResume();
    mDbHelper.open();
    
    //See whether we're loading for first time, in which case we load data
    FrameLayout splashScreen = (FrameLayout) findViewById(R.id.splash_screen);
    if(splashScreen != null) {
      new LoadInformationTask(this, mIdentifier).execute();
    }

    mApplicationContainer.scrollToApplicationView();
  }

  @Override
  protected void onPause() {
    super.onPause();
    mDbHelper.close();
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
  
  public UiMenuHorizontalScrollView getApplicationContainer() {
    return mApplicationContainer;
  }
  
  public BookmarkDbAdapter getDbAdapter() {
    return mDbHelper;
  }
}
