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
			if (mTask instanceof LoadInformationTask) {
				EasyTracker.getTracker().trackEvent(Constants.ERROR_CATEGORY, 
																						Constants.DISPLAY_ERROR, 
																						null, 
																						((LoadInformationTask) mTask).getIdentifier());
			}
			mTask.cancel(true);
		}
	}

}
