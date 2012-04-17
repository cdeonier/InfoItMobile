package com.infoit.async;

import com.google.android.apps.analytics.easytracking.EasyTracker;
import com.infoit.constants.Constants;

import android.os.AsyncTask;

public class TaskTrackerRunnable implements Runnable {
	private AsyncTask<?, ?, ?> mTask;

	public TaskTrackerRunnable(AsyncTask<?, ?, ?> task) {
		mTask = task;
	}

	@Override
	public void run() {
		if (AsyncTask.Status.RUNNING.equals(mTask.getStatus())) {
			if (mTask instanceof DisplayInfoTask) {
				EasyTracker.getTracker().trackEvent(Constants.ERROR_CATEGORY, Constants.ASYNC_DISPLAY_ERROR, null,
						((DisplayInfoTask) mTask).getIdentifier());
			} else if (mTask instanceof GetNearbyLocationsTask) {
				EasyTracker.getTracker().trackEvent(Constants.ERROR_CATEGORY, Constants.ASYNC_NEARBY_LOCATIONS_ERROR, null, 0);
			}
			mTask.cancel(true);
		}
	}

}
