package com.infoit.main;

import android.content.pm.ActivityInfo;
import android.content.res.Resources;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.async.CreateAccountTask;
import com.infoit.async.LoginTask;

public class Account extends TrackedActivity {
	
	private AccountFsm mFsm;
	private static AsyncTask<String, Void, Boolean> mTask;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		
		BaseApplication.initializeShell(this, R.layout.account);
		BaseApplication.setBackgroundColor(R.color.settings_bg);
		BaseApplication.hideActionsMenu();
		setContentView(BaseApplication.getView());
		
		//Must come after setContentView, because FSM adjusts views on creation
		mFsm = new AccountFsm();
	}

	@Override
	protected void onPause() {
		super.onPause();
		
		BaseApplication.detachShell();
		
		if (mTask != null) {
			mTask.cancel(true);
		}
	}
	
	@Override
	public void onBackPressed() {
		if (!mFsm.getFsmState().equals(AccountFsm.State.INITIALIZED)) {
			mFsm.changeState(AccountFsm.State.INITIALIZED);
		} else if (BaseApplication.getView() == null ||  BaseApplication.getView().isActivityView()) {
      finish();
    } else {
    	BaseApplication.getView().scrollToApplicationView();
    }
	}
	
	public AccountFsm getFsm() {
		return mFsm;
	}
	
	public static class AccountFsm {
		public static enum State { 	
			INITIALIZED, 						//"Enter email and password"
			LOGIN_WARNING, 					//"Please enter email and password" (in red)
			CREATE_ACCOUNT_WARNING, //"Please choose a email and password"
			LOGGING_IN,  						//"Logging in"
			NEW_ACCOUNT, 						//"Verify password to create account"
			NEW_ACCOUNT_WARNING,		//"Verify password to create account" (in red) || "Password did not match" (in red)
			CREATING_ACCOUNT,				//"Creating account"
			LOGIN_SUCCESS, 					//"Successfully logged in"
			CREATION_SUCCESS, 			//"Created account"
			LOGIN_FAILURE,					//"Incorrect email/username or password"
			CREATION_FAILURE,				//"Email already registered"
			SERVER_ERROR						//"Server unresponsive; try again later"
		}
		
		private State mState;
		private EditText mEmail;
		private EditText mPassword;
		private LinearLayout mLoginButtons;
		private LinearLayout mCreateAccountButtons;
		private LinearLayout mLoginFields;
		private FrameLayout mAccountButtons;
		private LinearLayout mUsernameFields;
		private TextView mStatusText;
		private ProgressBar mProgressBar;
		private Resources mResources;
		
		private String password;
		
		public AccountFsm() {
			mLoginButtons = (LinearLayout) BaseApplication.getView().findViewById(R.id.login_buttons);
			mCreateAccountButtons = (LinearLayout) BaseApplication.getView().findViewById(R.id.create_account_buttons);
			mStatusText = (TextView) BaseApplication.getView().findViewById(R.id.account_status);
			mResources = BaseApplication.getCurrentActivity().getResources();
			mEmail = (EditText) BaseApplication.getView().findViewById(R.id.account_email);
			mPassword = (EditText) BaseApplication.getView().findViewById(R.id.account_password);
			mProgressBar = (ProgressBar) BaseApplication.getView().findViewById(R.id.status_progress_bar);
			mLoginFields = (LinearLayout) BaseApplication.getView().findViewById(R.id.account_login_fields);
			mAccountButtons = (FrameLayout) BaseApplication.getView().findViewById(R.id.account_buttons);
			mUsernameFields = (LinearLayout) BaseApplication.getView().findViewById(R.id.account_username_fields);
			
			changeState(State.INITIALIZED);
			initializeButtons();
		}
		
		public void changeState(State state) {
			Button loginButton = (Button) BaseApplication.getView().findViewById(R.id.account_log_in);
			Button newAccountButton = (Button) BaseApplication.getView().findViewById(R.id.account_new_account);
			
			switch(state) {
				case INITIALIZED:
					mState = State.INITIALIZED;
					mLoginButtons.setVisibility(View.VISIBLE);
					mCreateAccountButtons.setVisibility(View.INVISIBLE);
					mStatusText.setText("Enter email and password");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_blue));
					mEmail.setEnabled(true);
					mEmail.setText("");
					mPassword.setText("");
					loginButton.setEnabled(true);
					newAccountButton.setEnabled(true);
					mProgressBar.setVisibility(View.GONE);
					mUsernameFields.setVisibility(View.GONE);
					mLoginFields.setVisibility(View.VISIBLE);
					password = null;
					break;
				case LOGIN_WARNING:
					mState = State.LOGIN_WARNING;
					mStatusText.setText("Please enter email and password");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_red));
					break;
				case CREATE_ACCOUNT_WARNING:
					mState = State.CREATE_ACCOUNT_WARNING;
					mStatusText.setText("Please enter a valid email and password");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_red));
					break;
				case LOGGING_IN:
					mState = State.LOGGING_IN;
					mStatusText.setText("Logging in...");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_blue));
					mProgressBar.setVisibility(View.VISIBLE);
					loginButton.setEnabled(false);
					newAccountButton.setEnabled(false);
					break;
				case NEW_ACCOUNT:
					mState = State.NEW_ACCOUNT;
					mLoginButtons.setVisibility(View.INVISIBLE);
					mCreateAccountButtons.setVisibility(View.VISIBLE);
					mEmail.setEnabled(false);
					password = mPassword.getText().toString();
					mPassword.setText("");
					mStatusText.setText("Verify password to create account");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_blue));
					break;
				case NEW_ACCOUNT_WARNING:
					mState = State.NEW_ACCOUNT_WARNING;
					if (mPassword.getText().length() == 0) {
						mStatusText.setText("Please verify password to create account");
					} else {
						mStatusText.setText("Password did not match");
					}
					
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_red));
					break;
				case CREATING_ACCOUNT:
					mState = State.CREATING_ACCOUNT;
					if (password.equals(mPassword.getText().toString())) {
						mStatusText.setText("Creating account...");
						mProgressBar.setVisibility(View.VISIBLE);
						mStatusText.setTextColor(mResources.getColor(R.color.account_status_blue));
					} else {
						changeState(State.NEW_ACCOUNT_WARNING);
					}
					break;
				case LOGIN_SUCCESS:
					mState = State.LOGIN_SUCCESS;
					mLoginButtons.setVisibility(View.INVISIBLE);
					mCreateAccountButtons.setVisibility(View.INVISIBLE);
					mStatusText.setText("Successfully logged in");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_blue));
					mProgressBar.setVisibility(View.GONE);
					mLoginFields.setVisibility(View.GONE);
					mAccountButtons.setVisibility(View.GONE);
					mUsernameFields.setVisibility(View.VISIBLE);
					break;
				case CREATION_SUCCESS:
					mState = State.CREATION_SUCCESS;
					mLoginButtons.setVisibility(View.INVISIBLE);
					mCreateAccountButtons.setVisibility(View.INVISIBLE);		
					mStatusText.setText("Created Account");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_blue));
					mProgressBar.setVisibility(View.GONE);
					mLoginFields.setVisibility(View.GONE);
					mAccountButtons.setVisibility(View.GONE);
					mUsernameFields.setVisibility(View.VISIBLE);
					break;
				case LOGIN_FAILURE:
					mState = State.LOGIN_FAILURE;
					mLoginButtons.setVisibility(View.VISIBLE);
					mCreateAccountButtons.setVisibility(View.INVISIBLE);
					mStatusText.setText("Incorrect email/username or password");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_red));
					mEmail.setEnabled(true);
					loginButton.setEnabled(true);
					newAccountButton.setEnabled(true);
					mProgressBar.setVisibility(View.GONE);
					password = null;
					break;
				case CREATION_FAILURE:
					mState = State.LOGIN_FAILURE;
					mLoginButtons.setVisibility(View.VISIBLE);
					mCreateAccountButtons.setVisibility(View.INVISIBLE);
					mStatusText.setText("Email already registered");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_red));
					mEmail.setEnabled(true);
					loginButton.setEnabled(true);
					newAccountButton.setEnabled(true);
					mProgressBar.setVisibility(View.GONE);
					password = null;
					break;
				case SERVER_ERROR:
					mLoginButtons.setVisibility(View.INVISIBLE);
					mCreateAccountButtons.setVisibility(View.INVISIBLE);
					mStatusText.setText("Server unresponsive; try again later");
					mStatusText.setTextColor(mResources.getColor(R.color.account_status_red));
					mProgressBar.setVisibility(View.GONE);
					((Button) BaseApplication.getView().findViewById(R.id.account_done)).setVisibility(View.VISIBLE);
					break;
				default:
					mState = State.INITIALIZED;
					break;
			}
		}
		
		private void initializeButtons() {
			Button loginButton = (Button) BaseApplication.getView().findViewById(R.id.account_log_in);
			Button newAccountButton = (Button) BaseApplication.getView().findViewById(R.id.account_new_account);
			Button createAccountButton = (Button) BaseApplication.getView().findViewById(R.id.account_create_account);
			Button cancelButton = (Button) BaseApplication.getView().findViewById(R.id.cancel_new_account);
			Button doneButton = (Button) BaseApplication.getView().findViewById(R.id.account_done);
			
			loginButton.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					if (mEmail.getText().length() != 0 && mPassword.getText().length() != 0) {
						changeState(State.LOGGING_IN);
						mTask = new LoginTask((Account) BaseApplication.getCurrentActivity());
						mTask.execute(mEmail.getText().toString(), mPassword.getText().toString());
					} else {
						changeState(State.LOGIN_WARNING);
					}
				}
			});
			
			newAccountButton.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					if (mEmail.getText().length() != 0 && mPassword.getText().length() != 0) {
						changeState(State.NEW_ACCOUNT);
					} else {
						changeState(State.CREATE_ACCOUNT_WARNING);
					}
				}
			});
			
			createAccountButton.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					if (mPassword.getText().length() != 0) {
						changeState(State.CREATING_ACCOUNT);
						mTask = new CreateAccountTask((Account) BaseApplication.getCurrentActivity());
						mTask.execute(mEmail.getText().toString(), mPassword.getText().toString());
					} else {
						changeState(State.NEW_ACCOUNT_WARNING);
					}
				}
			});
			
			cancelButton.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					changeState(State.INITIALIZED);
				}
			});
			
			doneButton.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					BaseApplication.getCurrentActivity().finish();
				}
			});
		}
		
		public State getFsmState() {
			return mState;
		}
		
		public boolean inError() {
			if (getFsmState().equals(State.SERVER_ERROR)) {
				return true;
			} else {
				return false;
			}	
		}
		
		public void failure() {
			if (getFsmState().equals(State.CREATING_ACCOUNT)) {
				changeState(State.CREATION_FAILURE);
			} else if (getFsmState().equals(State.LOGGING_IN)) {
				changeState(State.LOGIN_FAILURE);
			}
		}
		
		public void success() {
			if (getFsmState().equals(State.CREATING_ACCOUNT)) {
				changeState(State.CREATION_SUCCESS);
			} else if (getFsmState().equals(State.LOGGING_IN)) {
				changeState(State.LOGIN_SUCCESS);
			}
		}
		
		public void error() {
			changeState(State.SERVER_ERROR);
		}
	}

}
