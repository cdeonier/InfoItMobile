package com.infoit.main;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.widget.ListView;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.adapters.GpsListAdapter;
import com.infoit.async.GetNearbyLocationsTask;
import com.infoit.async.TaskTrackerRunnable;

public class NearbyLocations extends TrackedActivity {
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

		BaseApplication.initializeShell(this, R.layout.gps_list);
		BaseApplication.hideActionsMenu();
		setContentView(BaseApplication.getView());
		
		BaseApplication.setSplashScreen();

		setupLocationListening();

		mGpsList = (ListView) findViewById(R.id.gps_list);
		mListAdapter = new GpsListAdapter(this, R.layout.gps_list_item, R.id.gps_text, null);
		mGpsList.setAdapter(mListAdapter);
	}

	@Override
	protected void onPause() {
		super.onPause();

		BaseApplication.detachShell();

		LocationManager locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
		locationManager.removeUpdates(mLocationListener);

		// Because the task is kicked off from a location change even, its possibly null right before exit
		if (mTask != null)
			mTask.cancel(true);

		mGpsList.setAdapter(null);
		mListAdapter = null;
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

			public void onStatusChanged(String provider, int status, Bundle extras) {
			}

			public void onProviderEnabled(String provider) {
			}

			public void onProviderDisabled(String provider) {
			}
		};

		// Register the listener with the Location Manager to receive location updates
		locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, mLocationListener);
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
}
