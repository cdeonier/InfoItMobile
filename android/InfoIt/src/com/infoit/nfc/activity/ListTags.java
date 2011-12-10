package com.infoit.nfc.activity;

import android.app.Activity;
import android.content.Context;
import android.database.Cursor;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

import com.infoit.nfc.service.TagsDbAdapter;
import com.infoit.nfc.service.TagsWebServiceAdapter;

public class ListTags extends Activity {
	private ListView mTagsList;
	private TagsDbAdapter mDbHelper;
	
	private LocationManager mLocationManager;
	private LocationListener mLocationListener = new MyLocationListener();
	
	private double mLatitude, mLongitude;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		//android.os.Debug.waitForDebugger();
		
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tagslist);
		
		mTagsList = (ListView) findViewById(R.id.tags_list);
		
		mDbHelper = new TagsDbAdapter(this);
		mDbHelper.open();
		mDbHelper.seedDataLong();
		fillData();
		
		mLocationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
		setInfoButton();
	}
	
	private void fillData() {
		Cursor tagsCursor = mDbHelper.fetchAllTags();
		startManagingCursor(tagsCursor);
		
		String[] from = new String[]{TagsDbAdapter.KEY_LOCATION_NAME};
		int[] to = new int[]{R.id.text1};
		
		SimpleCursorAdapter tags =
			new SimpleCursorAdapter(this, R.layout.tagslist_item, tagsCursor, from, to);
		mTagsList.setAdapter(tags);
	}
	
	private void setInfoButton(){
		Button infoButton = (Button) findViewById(R.id.info_button);
		infoButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v){
				mLocationManager.requestSingleUpdate(LocationManager.NETWORK_PROVIDER, mLocationListener, getMainLooper());
			}
		});
	}
	
	class MyLocationListener implements LocationListener {
		@Override
		public void onLocationChanged(Location location){
			if(location != null){
				mLocationManager.removeUpdates(mLocationListener);
				mLatitude = location.getLatitude();
				mLongitude = location.getLongitude();
				TagsWebServiceAdapter.getTagLocationsViaGPS(mLatitude, mLongitude);
			}
		}

		@Override
		public void onProviderDisabled(String arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void onProviderEnabled(String arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void onStatusChanged(String arg0, int arg1, Bundle arg2) {
			// TODO Auto-generated method stub
			
		}
	}
}
