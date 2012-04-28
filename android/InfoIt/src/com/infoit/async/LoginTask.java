package com.infoit.async;

import com.infoit.adapters.WebServiceAdapter;
import com.infoit.adapters.WebServiceException;
import com.infoit.main.Account;
import com.infoit.main.BaseApplication;

import android.os.AsyncTask;

public class LoginTask  extends AsyncTask<String, Void, Boolean> {
	private Account mAccountActivity;
	
	public LoginTask(Account accountActivity) {
		mAccountActivity = accountActivity;
	}

	@Override
	protected Boolean doInBackground(String... params) {
		String email = params[0];
		String password = params[1];
		
		Boolean loggedIn = false;
		
		try {
			loggedIn = WebServiceAdapter.login(email, password);
		} catch (WebServiceException e) {
			BaseApplication.getCurrentActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					mAccountActivity.getFsm().error();
				}
			});
		}
		
		return loggedIn;
	}

	@Override
	protected void onPostExecute(Boolean loggedIn) {
		if (!mAccountActivity.getFsm().inError()) {
			if (loggedIn) {
				mAccountActivity.getFsm().success();
			} else {
				mAccountActivity.getFsm().failure();
			}
		}
	}
}
