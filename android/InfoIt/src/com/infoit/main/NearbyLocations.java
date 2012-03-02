package com.infoit.main;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.Display;
import android.widget.FrameLayout.LayoutParams;
import android.widget.LinearLayout;

import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class NearbyLocations extends Activity {
	private UiMenuHorizontalScrollView mApplicationContainer;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		
		setContentView(R.layout.gps_list);
	}

	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	protected void onResume() {
		super.onResume();

		mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
				R.layout.ui_navigation_menu, R.layout.ui_empty_action_menu,
				R.layout.gps_list);
		ShellUtil.clearActionMenuButton(mApplicationContainer);

		// 50 should work, but not displaying correctly, so nudging to 70
		int menuBarHeight = (int) (70 * getResources().getDisplayMetrics().density);
		Display display = getWindowManager().getDefaultDisplay();
		
		LinearLayout container = (LinearLayout) findViewById(R.id.container);
	    container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, display.getHeight() - menuBarHeight));
	}
	
	@Override
	public void onBackPressed() {
		super.onBackPressed();
	}

}
