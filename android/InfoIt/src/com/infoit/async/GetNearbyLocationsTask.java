package com.infoit.async;

import org.codehaus.jackson.JsonNode;

import android.location.Location;
import android.os.AsyncTask;

import com.infoit.main.NearbyLocations;
import com.infoit.reader.record.GpsRecord;
import com.infoit.reader.service.GpsListAdapter;
import com.infoit.reader.service.WebServiceAdapter;

public class GetNearbyLocationsTask extends AsyncTask<Void, Void, JsonNode> {
	private Location mLocation;
	private NearbyLocations mActivity;
	
	public GetNearbyLocationsTask(NearbyLocations activity, Location location) {
		mLocation = location;
		mActivity = activity;
	}

	@Override
	protected JsonNode doInBackground(Void... arg0) {
		JsonNode webServiceResponse = WebServiceAdapter.getNearbyLocationsAsJson(mLocation);
		
		return webServiceResponse;
	}

	@Override
	protected void onPostExecute(JsonNode result) {
		super.onPostExecute(result);
		
		GpsListAdapter adapter = mActivity.getGpsListAdapter();
		adapter.clear();
		
		for (JsonNode node : result) {
			JsonNode location = node.path("entity");
			
			String name = location.path("name").getTextValue();
			int identifier = location.path("id").getIntValue();
			String distance = String.valueOf(location.path("distance").getDoubleValue());
			String entityType = location.path("entity_type").getTextValue();
			String entitySubType = location.path("entity_sub_type").getTextValue();
			
			GpsRecord nearbyLocation = new GpsRecord();
			nearbyLocation.setName(name);
			nearbyLocation.setIdentifier(identifier);
			nearbyLocation.setDistance(distance);
			nearbyLocation.setEntityType(entityType);
			nearbyLocation.setEntitySubType(entitySubType);
			
			adapter.add(nearbyLocation);
		}
		
		adapter.notifyDataSetChanged();
		mActivity.setContentView(mActivity.getApplicationContainer());
		
	}

	
}