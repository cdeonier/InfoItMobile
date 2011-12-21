package com.infoit.reader.activity;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.infoit.reader.activity.R;
import com.infoit.reader.record.RealEstateInformation;
import com.infoit.reader.service.TagsWebServiceAdapter;

public class RealEstateTag extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	android.os.Debug.waitForDebugger();
    	
        super.onCreate(savedInstanceState);
        setContentView(R.layout.real_estate_tag);
        
        //Lock to Portrait Mode
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        
        setupBasicInformation();
    }
    
    private void setupBasicInformation(){
    	new SetupBasicInfoTask().execute();
    }
	
	private class SetupBasicInfoTask extends AsyncTask<Void, Void, RealEstateInformation> {

		@Override
		protected RealEstateInformation doInBackground(Void... arg0) {
			RealEstateInformation info = TagsWebServiceAdapter.getBasicInfoRealEstate(100);
			return info;
		}

		@Override
		protected void onPostExecute(RealEstateInformation info) {	
	    	new GetBasicInfoThumbnail().execute(info.getThumbnailUrl());
	    	
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
	    	addressTwo.setText(info.getAddressTwo());
	    	TextView city = (TextView) findViewById(R.id.city);
	    	city.setText(info.getCity()+ ", ");
	    	TextView state = (TextView) findViewById(R.id.state);
	    	state.setText(info.getState()+" ");
	    	TextView zip = (TextView) findViewById(R.id.zip_code);
	    	zip.setText(String.valueOf(info.getZipCode()));
	    	
	    	RelativeLayout address_layout = (RelativeLayout) findViewById(R.id.address);
	    	address_layout.setOnClickListener(new OnClickListener(){

				@Override
				public void onClick(View v) {
					Intent googleMapsIntent = new Intent(android.content.Intent.ACTION_VIEW, 
														 Uri.parse("geo:0,0?q=615+South+Idaho+St+San+Mateo+CA"));
					startActivity(googleMapsIntent);
					
				}
	    	});
		}
	}
	
	private class GetBasicInfoThumbnail extends AsyncTask<String, Void, Drawable>{

		@Override
		protected Drawable doInBackground(String... urls) {
			Drawable image = getImage(urls[0]);
			return image;
		}
		
		@Override
		protected void onPostExecute(Drawable image) {
			ImageView imageView = (ImageView) findViewById(R.id.thumbnail);
	    	imageView.setImageDrawable(image);
		}
		
	    private Drawable getImage(String url) {
			try {
				InputStream is = (InputStream) this.fetch(url);
				Drawable d = Drawable.createFromStream(is, "src");
				return d;
			} catch (MalformedURLException e) {
				e.printStackTrace();
				return null;
			} catch (IOException e) {
				e.printStackTrace();
				return null;
			}
		}
	    
		private Object fetch(String address) throws MalformedURLException,IOException {
			URL url = new URL(address);
			Object content = url.getContent();
			return content;
		}
		
	}
}
