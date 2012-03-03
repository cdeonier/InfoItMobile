package com.infoit.main;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.view.Display;
import android.widget.FrameLayout.LayoutParams;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.infoit.async.GetNearbyLocationsTask;
import com.infoit.reader.record.GpsRecord;
import com.infoit.reader.service.GpsListAdapter;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class NearbyLocations extends Activity {
	private UiMenuHorizontalScrollView mApplicationContainer;
	private GpsListAdapter mListAdapter;
	private ListView mGpsList;
	private ArrayList<GpsRecord> mNearbyLocations;

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
		
		mGpsList = (ListView) findViewById(R.id.gps_list);
		mNearbyLocations = new ArrayList<GpsRecord>();
		
		mListAdapter = new GpsListAdapter(this, R.layout.gps_list_item, R.id.gps_text, mNearbyLocations);
		mGpsList.setAdapter(mListAdapter);

		// 50 should work, but not displaying correctly, so nudging to 70
		int menuBarHeight = (int) (70 * getResources().getDisplayMetrics().density);
		Display display = getWindowManager().getDefaultDisplay();

		LinearLayout container = (LinearLayout) findViewById(R.id.container);
		container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,
				display.getHeight() - menuBarHeight));
		
		setupLocationListening();
		
		setContentView(R.layout.gps_list);
	}

	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
	}

	private void setupLocationListening() {

		// Acquire a reference to the system Location Manager
		LocationManager locationManager = (LocationManager) this
				.getSystemService(Context.LOCATION_SERVICE);

		// Define a listener that responds to location updates
		LocationListener locationListener = new LocationListener() {
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
				LocationManager.NETWORK_PROVIDER, 0, 0, locationListener);
	}

	private void makeUseOfNewLocation(Location location) {
		new GetNearbyLocationsTask(this, location).execute();
	}
	
	public GpsListAdapter getGpsListAdapter() {
		return mListAdapter;
	}

}
