/*package com.infoit.reader.activity;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.reader.record.RealEstateInformation;
import com.infoit.reader.service.TagsWebServiceAdapter;
import com.infoit.util.ImageUtil;

public class RealEstateTag extends Activity {
	private ProgressDialog progressDialog;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
		android.os.Debug.waitForDebugger();

		super.onCreate(savedInstanceState);
		
		// Lock to Portrait Mode
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		setContentView(R.layout.real_estate_tag);
		progressDialog = ProgressDialog.show(this, "", "Fetching Data...", true);
		
		setupMenuBar();
        
        setupBasicInformation();
        
        loadThumbnails();
    }
    
    private void setupBasicInformation(){
    	new SetupBasicInfoTask().execute();
    }
    
    private void loadThumbnails(){
    	new LoadThumbnails().execute(100);
    }
    
    private void setupMenuBar(){
    	ImageView listIcon = (ImageView) findViewById(R.id.list_icon);
    	listIcon.setOnClickListener(new OnClickListener(){

			@Override
			public void onClick(View v) {
				Intent listIntent = new Intent(v.getContext(), ListTags.class);
				startActivity(listIntent);
			}
    	});
    }
	
	private class SetupBasicInfoTask extends AsyncTask<Void, Void, RealEstateInformation> {

		@Override
		protected RealEstateInformation doInBackground(Void... arg0) {
			RealEstateInformation info = TagsWebServiceAdapter.getBasicInfoRealEstate(100);
			return info;
		}

		@Override
		protected void onPostExecute(RealEstateInformation info) {	
	    	assert info != null;
	    	
	    	TextView locationName = (TextView) findViewById(R.id.location_name);
	    	locationName.setText(info.getName());
	    	
	    	TextView locationPrice = (TextView) findViewById(R.id.location_price);
	    	locationPrice.setText("Price: $" + String.valueOf(info.getPrice()));
	    	
	    	TextView locationSpecs = (TextView) findViewById(R.id.location_specs);
	    	locationSpecs.setText(info.getSpecs());
	    	
	    	TextView locationSize = (TextView) findViewById(R.id.location_size);
	    	locationSize.setText(String.valueOf(info.getSize()) + " sq. ft");
	    	
	    	TextView addressOne = (TextView) findViewById(R.id.address_one);
	    	addressOne.setText(info.getAddressOne());
	    	
	    	TextView addressTwo = (TextView) findViewById(R.id.address_two);
	    	if("".equals(info.getAddressTwo())){
	    		LinearLayout address = (LinearLayout) findViewById(R.id.address);
	    		address.removeView(addressTwo);
	    	}
	    	else{
	    		addressTwo.setText(info.getAddressTwo());
	    	}
	    	
	    	
	    	TextView city = (TextView) findViewById(R.id.city);
	    	city.setText(info.getCity()+ ", ");
	    	TextView state = (TextView) findViewById(R.id.state);
	    	state.setText(info.getState()+" ");
	    	TextView zip = (TextView) findViewById(R.id.zip_code);
	    	zip.setText(String.valueOf(info.getZipCode()));
	    	
	    	LinearLayout address_layout = (LinearLayout) findViewById(R.id.address_layout);
	    	address_layout.setOnClickListener(new OnClickListener(){

				@Override
				public void onClick(View v) {
					Intent googleMapsIntent = new Intent(android.content.Intent.ACTION_VIEW, 
														 Uri.parse("geo:0,0?q=615+South+Idaho+St+San+Mateo+CA"));
					startActivity(googleMapsIntent);
					
				}
	    	});
	    	
	    	ImageView mapIcon = (ImageView) findViewById(R.id.map_icon);
	    	mapIcon.setLayoutParams(new LinearLayout.LayoutParams(mapIcon.getWidth(), mapIcon.getWidth()));
	    	
	    	new GetBasicInfoThumbnail().execute(info.getThumbnailUrl());

	    	LinearLayout splashScreen = (LinearLayout) findViewById(R.id.splash_screen);
	    	LinearLayout realEstateLayout = (LinearLayout) findViewById(R.id.real_estate_layout);
	    	
	    	splashScreen.setVisibility(View.INVISIBLE);
	    	realEstateLayout.setVisibility(View.VISIBLE);
	    	
	        progressDialog.dismiss();
		}
	}
	
	private class GetBasicInfoThumbnail extends AsyncTask<String, Void, Drawable>{

		@Override
		protected Drawable doInBackground(String... urls) {
			Drawable image = ImageUtil.getImage(urls[0]);
			return image;
		}
		
		@Override
		protected void onPostExecute(Drawable image) {
			ImageView imageView = (ImageView) findViewById(R.id.thumbnail);
	    	imageView.setImageDrawable(image);
	    	imageView.setLayoutParams(new LinearLayout.LayoutParams(imageView.getWidth(), imageView.getWidth()));
		}

		
	}
	
	private class LoadThumbnails extends AsyncTask<Integer, String[], String[]>{

		@Override
		protected String[] doInBackground(Integer... params) {
			String[] urls = TagsWebServiceAdapter.getThumbnailsOfTag(params[0]);
			return urls;
		}

		@Override
		protected void onPostExecute(String[] result) {
			new FetchThumbnails().execute(result);
		}
		
	}
	
	private class FetchThumbnails extends AsyncTask<String, Void, Drawable[]>{

		@Override
		protected Drawable[] doInBackground(String... urls) {
			
			Drawable[] thumbnails = new Drawable[urls.length];
			for(int i=0; i<urls.length; i++){
				thumbnails[i] = ImageUtil.getImage(urls[i]);
			}
			
			return thumbnails;
		}
		
		@Override
		protected void onPostExecute(Drawable[] thumbnails) {
			LinearLayout gallery = (LinearLayout) findViewById(R.id.gallery_container);
			
			for(int i=0; i < thumbnails.length; i++){
				ImageView newThumbnail = new ImageView(RealEstateTag.this);
				newThumbnail.setImageDrawable(thumbnails[i]);
				LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(100, 100);
				lp.setMargins(10, 0, 10, 0);
				newThumbnail.setLayoutParams(lp);
				gallery.addView(newThumbnail);
			}
		}
		
	}
}*/