package com.infoit.nfc.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class ViewTag extends Activity {
	static final String TAG = "ViewTag";
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.view_tag);
        
        //Lock to Portrait Mode
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        
        //setupBasicInformation();
        //makeViews();
        //addWebView();
        setupTiles();

    }
    
    private void setupBasicInformation(){
    	RelativeLayout basicInformationTile = new RelativeLayout(this);
    	RelativeLayout.LayoutParams lp = 
    			new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT,
    											200);
    	basicInformationTile.setLayoutParams(lp);
    
        basicInformationTile.setBackgroundColor(0xFFEE3333);
        
        TextView tv = new TextView(this);
        tv.setText("Test");
        
        basicInformationTile.addView(tv);
        
        basicInformationTile.setId(1000);
        
        LinearLayout locationServices = (LinearLayout) findViewById(R.id.location_services);
        locationServices.addView(basicInformationTile);
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
 
    	RelativeLayout googleTile = createServiceTile("http://www.google.com", "http://www.google.com");
    	RelativeLayout facebookTile = createServiceTile("http://m.facebook.com", "http://m.facebook.com");
    	
    	googleTile.setId(1000);
    	facebookTile.setId(1001);
    	locationServices.addView(googleTile);
    	locationServices.addView(facebookTile);
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
}