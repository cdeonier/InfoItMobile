package com.infoit.main;

import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.FrameLayout.LayoutParams;

public class NfcInstructions extends Activity {
	private UiMenuHorizontalScrollView mApplicationContainer;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
	}

	@Override
	protected void onResume() {
		super.onResume();
		
	    mApplicationContainer = ShellUtil.initializeApplicationContainer(this,
	            R.layout.ui_navigation_menu, R.layout.ui_empty_action_menu,
	            R.layout.nfc_instructions);
	    ShellUtil.clearActionMenuButton(mApplicationContainer);
	    
	    //50 should work, but not displaying correctly, so nudging to 70
	    int menuBarHeight = (int) (70 * getResources().getDisplayMetrics().density);
	    Display display = getWindowManager().getDefaultDisplay();

	    LinearLayout container = (LinearLayout) findViewById(R.id.container);
	    container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, display.getHeight() - menuBarHeight));
	    
	    mApplicationContainer.scrollToApplicationView();
	}

	@Override
	protected void onPause() {
		super.onPause();
		
		unbindDrawables(mApplicationContainer);
		mApplicationContainer = null;
	}

	@Override
	public void onBackPressed() {
		if (mApplicationContainer.isApplicationView()) {
			finish();
		} else {
			mApplicationContainer.scrollToApplicationView();
		}
		return;
	}
	
	private void unbindDrawables(View view) {
		if (view.getBackground() != null) {
			view.getBackground().setCallback(null);
		}
		if (view instanceof ViewGroup) {
			for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
				unbindDrawables(((ViewGroup) view).getChildAt(i));
			}
			((ViewGroup) view).removeAllViews();
		}
	}
}
