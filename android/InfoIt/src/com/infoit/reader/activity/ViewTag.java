/*package com.infoit.reader.activity;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.infoit.reader.activity.R;
import com.infoit.reader.record.RealEstateInformation;
import com.infoit.reader.service.TagsWebServiceAdapter;

public class ViewTag extends Activity {
	static final String TAG = "ViewTag";
	
    Called when the activity is first created. 
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	//android.os.Debug.waitForDebugger();
    	
        super.onCreate(savedInstanceState);
        setContentView(R.layout.view_tag);
        
        //Lock to Portrait Mode
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        
        //setupBasicInformation();
        
        
        //setupBasicInformation();
        //makeViews();
        //addWebView();
        //setupTiles();

    }
    
    private void setupBasicInformation(){
    	RealEstateInformation info = TagsWebServiceAdapter.getBasicInfoRealEstate(100);
    	
    	ImageView imageView = (ImageView) findViewById(R.id.thumbnail);
    	Drawable image = getImage(info.getThumbnailUrl());
    	imageView.setImageDrawable(image);
    	
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

	public Object fetch(String address) throws MalformedURLException,IOException {
		URL url = new URL(address);
		Object content = url.getContent();
		return content;
	}
    
    private void makeViews(){
    	for(int i = 1001; i < 1010; i++){
    		RelativeLayout layout = new RelativeLayout(this);
    		RelativeLayout.LayoutParams lp = 
        			new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT,
        											200);
    		RelativeLayout topView = (RelativeLayout) findViewById(i-1);
    		lp.addRule(RelativeLayout.BELOW, topView.getId());
    		layout.setLayoutParams(lp);
    		layout.setBackgroundColor(0xFFEE3333);
            
    		TextView tv = new TextView(this);
            tv.setText("Test");
            
            layout.addView(tv, lp);
            
            layout.setId(i);
            
            LinearLayout locationServices = (LinearLayout) findViewById(R.id.location_services);
            locationServices.addView(layout);
    	}
    }
    
    private void setupTiles(){
    	LinearLayout locationServices = (LinearLayout) findViewById(R.id.location_services);
 
    	RelativeLayout facebookTile = createServiceTile("http://192.223.254.41:3000/tile_context/facebook", 
    													"http://192.223.254.41:3000/tile_application/facebook");
    	RelativeLayout foursquareTile = createServiceTile("http://192.223.254.41:3000/tile_context/foursquare", 
														  "http://192.223.254.41:3000/tile_application/foursquare");
    	RelativeLayout twitterTile = createServiceTile("http://192.223.254.41:3000/tile_context/twitter", 
				  									   "http://192.223.254.41:3000/tile_application/twitter");
    	RelativeLayout yelpTile = createServiceTile("http://192.223.254.41:3000/tile_context/yelp", 
				  									"http://192.223.254.41:3000/tile_application/yelp");
    	
    	locationServices.addView(yelpTile);
    	locationServices.addView(foursquareTile);
    	locationServices.addView(facebookTile);
    	locationServices.addView(twitterTile);
    }
    
    private RelativeLayout createServiceTile(String contextUrl, String applicationUrl){
    	RelativeLayout tileContainer = new RelativeLayout(this);
    	RelativeLayout clickableLayout = new RelativeLayout(this);
    	WebView contextWebView = new WebView(this);
    	
    	final String serviceUrl = applicationUrl;
    	
    	contextWebView.getSettings().setJavaScriptEnabled(true);
    	
    	RelativeLayout.LayoutParams tileContainerParameters = 
    			new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT,
												200);
    	RelativeLayout.LayoutParams tileParameters = 
    			new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT,
    											RelativeLayout.LayoutParams.FILL_PARENT);
    	 	
    	tileContainer.setLayoutParams(tileContainerParameters);
    	clickableLayout.setLayoutParams(tileParameters);
    	contextWebView.setLayoutParams(tileParameters);
    	contextWebView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
    	
    	clickableLayout.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
			    Intent showContent = new Intent(getApplicationContext(),
			            TagApplication.class);
			    showContent.setData(Uri.parse(serviceUrl));
			    startActivity(showContent);
			}
    	});
    	clickableLayout.setBackgroundColor(Color.TRANSPARENT);
    	
    	tileContainer.addView(contextWebView);
    	tileContainer.addView(clickableLayout);
    	
    	clickableLayout.bringToFront();
    	contextWebView.loadUrl(contextUrl);
    	
    	return tileContainer;
    }
}*/