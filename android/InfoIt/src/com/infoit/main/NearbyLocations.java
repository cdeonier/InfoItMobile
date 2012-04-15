package com.infoit.main;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.view.Display;
import android.widget.FrameLayout.LayoutParams;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.adapters.GpsListAdapter;
import com.infoit.async.GetNearbyLocationsTask;
import com.infoit.async.TaskTrackerRunnable;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class NearbyLocations extends TrackedActivity {
	private UiMenuHorizontalScrollView mApplicationContainer;
	private GpsListAdapter mListAdapter;
	private ListView mGpsList;
	private LocationListener mLocationListener;
	private GetNearbyLocationsTask mTask;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
	}

	@Override
	protected void onResume() {
		super.onResume();

		mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
				R.layout.ui_navigation_menu, R.layout.ui_empty_action_menu,
				R.layout.gps_list);
		ShellUtil.clearActionMenuButton(mApplicationContainer);

		// 50 should work, but not displaying correctly, so nudging to 70
		int menuBarHeight = (int) (70 * getResources().getDisplayMetrics().density);
		Display display = getWindowManager().getDefaultDisplay();

		LinearLayout container = (LinearLayout) findViewById(R.id.container);
		container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, display.getHeight() - menuBarHeight));
		
		setupLocationListening();
		
		mGpsList = (ListView) findViewById(R.id.gps_list);
		mListAdapter = new GpsListAdapter(this, R.layout.gps_list_item, R.id.gps_text, null);
		mGpsList.setAdapter(mListAdapter);
		
		setSplashScreen();
		
		mApplicationContainer.scrollToApplicationView();
	}

	@Override
	protected void onPause() {
		super.onPause();
		
		LocationManager locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
		locationManager.removeUpdates(mLocationListener);
		
		//Because the task is kicked off from a location change even, its possibly null right before exit
		if (mTask != null)
			mTask.cancel(true);
		
		mGpsList.setAdapter(null);
		mListAdapter = null;
		mApplicationContainer = null;
	}

	@Override
	public void onBackPressed() {
		if (mApplicationContainer == null || mApplicationContainer.isApplicationView()) {
			finish();
		} else {
			mApplicationContainer.scrollToApplicationView();
		}
		return;
	}

	private void setupLocationListening() {

		// Acquire a reference to the system Location Manager
		LocationManager locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);

		// Define a listener that responds to location updates
		mLocationListener = new LocationListener() {
			public void onLocationChanged(Location location) {
				// Called when a new location is found by the network location
				// provider.
				makeUseOfNewLocation(location);
			}

			public void onStatusChanged(String provider, int status,
					Bundle extras) {
			}

			public void onProviderEnabled(String provider) {
			}

			public void onProviderDisabled(String provider) {
			}
		};

		// Register the listener with the Location Manager to receive location
		// updates
		locationManager.requestLocationUpdates(
				LocationManager.NETWORK_PROVIDER, 0, 0, mLocationListener);
	}

	private void makeUseOfNewLocation(Location location) {
		if (mTask != null) {
			mTask.cancel(true);
		}
		
		mTask = new GetNearbyLocationsTask(this, location);
		mTask.execute();
    Handler handler = new Handler();
    handler.postDelayed(new TaskTrackerRunnable(mTask), 20000);
	}
	
	public GpsListAdapter getGpsListAdapter() {
		return mListAdapter;
	}
	
	public UiMenuHorizontalScrollView getApplicationContainer() {
		return mApplicationContainer;
	}

	private void setSplashScreen() {
		UiMenuHorizontalScrollView splashContainer = ShellUtil
				.initializeApplicationContainer(this,
						R.layout.ui_navigation_menu,
						R.layout.ui_empty_action_menu,
						R.layout.ui_splash_screen);
		TextView splashText = (TextView) splashContainer.findViewById(R.id.splash_text);
		splashText.setText("Getting nearby locations...");
		setContentView(splashContainer);
	}

}
