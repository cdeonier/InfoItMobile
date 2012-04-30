package com.infoit.ui;

import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.view.View;
import android.view.View.OnClickListener;

import com.google.android.apps.analytics.easytracking.EasyTracker;
import com.infoit.constants.Constants;
import com.infoit.main.BaseApplication;
import com.infoit.main.CapturePhoto;

public class NoImageDrawable extends BitmapDrawable {
	private NoImageOnClickListener mListener;
	
	public NoImageDrawable(int identifier, Resources res, Bitmap bm) {
		super(res, bm);
		mListener = new NoImageOnClickListener(identifier);
	}

	public OnClickListener getOnClickListener() {
		return mListener;
	}
	
	private class NoImageOnClickListener implements OnClickListener {
		private int mIdentifier;
		
		public NoImageOnClickListener(int identifier) {
			mIdentifier = identifier;
		}

		@Override
		public void onClick(View view) {
			EasyTracker.getTracker().trackEvent(Constants.ACTIVITY_CATEGORY, Constants.ACTIVITY_BUTTON, Constants.PHOTO_BUTTON, 0);
			Intent capturePhotoIntent = new Intent(BaseApplication.getCurrentActivity(), CapturePhoto.class);
			capturePhotoIntent.putExtra("identifier", mIdentifier);
			BaseApplication.getCurrentActivity().startActivity(capturePhotoIntent);
		}
	}
}
