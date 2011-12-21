package com.infoit.reader.activity;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
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
import android.widget.Toast;

import com.infoit.reader.activity.R;
import com.infoit.reader.service.TagLocation;
import com.infoit.reader.service.TagsDbAdapter;
import com.infoit.reader.service.TagsWebServiceAdapter;

public class ListTags extends Activity {
	private ListView mTagsList;
	private TagsDbAdapter mDbHelper;
	
	private AlertDialog.Builder builder;
	
	private LocationManager mLocationManager;
	private LocationListener mLocationListener = new MyLocationListener();
	
	private double mLatitude, mLongitude;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		//android.os.Debug.waitForDebugger();
		
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tagslist);
		
		builder  = new AlertDialog.Builder(this);
		
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
				//Test
				ArrayList<TagLocation> nearbyLocations = TagsWebServiceAdapter.generateNearbyLocations();
				
				final String[] dialogLocations = new String[nearbyLocations.size()];
				final String[] dialogIdentifiers = new String[nearbyLocations.size()];
				for(int i = 0; i < nearbyLocations.size(); i++){
					dialogLocations[i] = nearbyLocations.get(i).getLocationName();
					dialogIdentifiers[i] = nearbyLocations.get(i).getLocationIdentifier();
				}
				
				builder.setTitle("Choose Nearby Location:");
				builder.setItems(dialogLocations, new DialogInterface.OnClickListener() {
				    public void onClick(DialogInterface dialog, int item) {
				        Toast.makeText(getApplicationContext(), dialogLocations[item], Toast.LENGTH_SHORT).show();
				        Intent viewTag = new Intent(getApplicationContext(), ViewTag.class);
				        viewTag.putExtra("locationIdentifier", dialogIdentifiers[item]);
				        startActivity(viewTag);
				    }
				});
				AlertDialog alert = builder.create();
				alert.show();
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
