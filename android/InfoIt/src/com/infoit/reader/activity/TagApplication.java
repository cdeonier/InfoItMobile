package com.infoit.reader.activity;

import com.infoit.reader.activity.R;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebView;

public class TagApplication extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
        setContentView(R.layout.tag_application);
        
        Intent launchingIntent = getIntent();
        String content = launchingIntent.getData().toString();
 
        WebView viewer = (WebView) findViewById(R.id.tag_app_webview);
        viewer.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
        viewer.loadUrl(content);
	}

}
