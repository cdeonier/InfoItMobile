package com.infoit.async;

import com.infoit.adapters.WebServiceAdapter;
import com.infoit.adapters.WebServiceException;
import com.infoit.main.Account;
import com.infoit.main.BaseApplication;

import android.os.AsyncTask;

public class CreateAccountTask  extends AsyncTask<String, Void, Boolean> {
	private Account mAccountActivity;
	
	public CreateAccountTask(Account accountActivity) {
		mAccountActivity = accountActivity;
	}

	@Override
	protected Boolean doInBackground(String... params) {
		String email = params[0];
		String password = params[1];
		
		Boolean accountCreated = false;
		
		try {
			accountCreated = WebServiceAdapter.createAccount(email, password);
		} catch (WebServiceException e) {
			BaseApplication.getCurrentActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					mAccountActivity.getFsm().error();
				}
			});
		}
		
		return accountCreated;
	}

	@Override
	protected void onPostExecute(Boolean accountCreated) {
		if (!mAccountActivity.getFsm().inError()) {
			if (accountCreated) {
				mAccountActivity.getFsm().success();
			} else {
				mAccountActivity.getFsm().failure();
			}
		}
	}
}