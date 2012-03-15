package com.infoit.service;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.infoit.constants.Constants;
import com.infoit.main.DisplayInfo;
import com.infoit.main.R;
import com.infoit.record.GpsRecord;

public class GpsListAdapter extends ArrayAdapter<GpsRecord> {
	ArrayList<GpsRecord> mGpsRecords;

	public GpsListAdapter(Context context, int resource, int textViewResourceId, 
			List<GpsRecord> objects) {
		super(context, textViewResourceId, objects);
		mGpsRecords = new ArrayList<GpsRecord>();
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View row = View.inflate(this.getContext(), R.layout.gps_list_item, null);
		
	    int rowHeight = (int) (50 * this.getContext().getResources().getDisplayMetrics().density);
	    row.setLayoutParams(new ListView.LayoutParams(ListView.LayoutParams.MATCH_PARENT, rowHeight));
		
		TextView rowText = (TextView) row.findViewById(R.id.gps_text);
		rowText.setText(mGpsRecords.get(position).getName());
		
		TextView rowDistance = (TextView) row.findViewById(R.id.gps_distance);
		rowDistance.setText(mGpsRecords.get(position).getDistance() + " miles");
		
		GpsOnClickListener gpsListener = new GpsOnClickListener(mGpsRecords.get(position).getIdentifier());
		row.setOnClickListener(gpsListener);
		
		return row;
		
	}

	@Override
	public int getCount() {
		return mGpsRecords.size();
	}

	@Override
	public GpsRecord getItem(int position) {
		return mGpsRecords.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public void add(GpsRecord record) {
		mGpsRecords.add(record);
	}

	@Override
	public void clear() {
		mGpsRecords.clear();
	}
	
	private class GpsOnClickListener implements OnClickListener {
		private int mIdentifier;
		
		public GpsOnClickListener(int identifier) {
			mIdentifier = identifier;
		}

		@Override
		public void onClick(View view) {
		      Intent displayInfoIntent = new Intent(view.getContext(), DisplayInfo.class);
		      displayInfoIntent.setAction(Constants.BOOKMARK);
		      displayInfoIntent.putExtra("identifier", mIdentifier);
		      view.getContext().startActivity(displayInfoIntent);	
		}
		
	}
}
