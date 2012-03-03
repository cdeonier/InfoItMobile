package com.infoit.reader.service;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.infoit.main.R;
import com.infoit.reader.record.GpsRecord;

public class GpsListAdapter extends ArrayAdapter<GpsRecord> {
	ArrayList<GpsRecord> mGpsRecords;

	public GpsListAdapter(Context context, int resource, int textViewResourceId, 
			List<GpsRecord> objects) {
		super(context, textViewResourceId, objects);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View row = View.inflate(this.getContext(), R.layout.gps_list_item, null);
		
		TextView rowText = (TextView) row.findViewById(R.id.gps_text);
		rowText.setText(mGpsRecords.get(position).getName());
		
		return row;
		
	}
	
	

}
