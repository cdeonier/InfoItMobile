package com.infoit.main;

import java.util.Arrays;

import android.content.pm.ActivityInfo;
import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Parcelable;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.adapters.DbAdapter;
import com.infoit.async.DisplayInfoTask;
import com.infoit.async.TaskTrackerRunnable;
import com.infoit.record.BasicInformation;

public class DisplayInfo extends TrackedActivity {
  private DbAdapter mDb;
  private int mIdentifier;
  private BasicInformation mBasicInformation;
  private DisplayInfoTask mTask;

@Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
  }

  @Override
  protected void onResume() {
    super.onResume();
    
    mIdentifier = getIntent().getExtras().getInt("identifier");
    if (mIdentifier == 0) {
      nfcStart();
    }
    
    BaseApplication.initializeShell(this, R.layout.display_info);
    BaseApplication.showActionsMenu();
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
  
  public DbAdapter getDbAdapter() {
    return mDb;
  }
  
  public BasicInformation getBasicInformation() {
  	return mBasicInformation;
  }
  
  public void setBasicInformation(BasicInformation basicInformation) {
  	mBasicInformation = basicInformation;
  }

  public int getIdentifier() {
    return mIdentifier;
  }

  public void setIdentifier(int identifier) {
    this.mIdentifier = identifier;
  }
}
