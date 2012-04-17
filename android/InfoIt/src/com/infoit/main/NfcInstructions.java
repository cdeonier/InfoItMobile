package com.infoit.main;

import android.content.pm.ActivityInfo;
import android.os.Bundle;

import com.google.android.apps.analytics.easytracking.TrackedActivity;

public class NfcInstructions extends TrackedActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
	}

	@Override
	protected void onResume() {
		super.onResume();
		
		BaseApplication.initializeShell(this, R.layout.nfc_instructions);
		BaseApplication.hideActionsMenu();
		setContentView(BaseApplication.getView());
	}

	@Override
	protected void onPause() {
		super.onPause();
		
		BaseApplication.detachShell();
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
}
