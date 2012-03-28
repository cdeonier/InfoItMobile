package com.infoit.async;

import java.util.Set;

import org.codehaus.jackson.JsonNode;

import android.os.AsyncTask;
import android.view.Display;
import android.widget.FrameLayout.LayoutParams;
import android.widget.LinearLayout;

import com.infoit.adapters.WebServiceAdapter;
import com.infoit.main.DisplayMenu;
import com.infoit.main.R;
import com.infoit.record.MenuInformation;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class LoadMenuTask  extends AsyncTask<Void, Void, JsonNode> {
	final private DisplayMenu mActivity;
	final private int mIdentifier;
	
	public LoadMenuTask(DisplayMenu activity, int identifier) {
		mActivity = activity;
		mIdentifier = identifier;
	}

	@Override
	protected JsonNode doInBackground(Void... arg0) {
		JsonNode webServiceResponse = WebServiceAdapter.getMenuAsJson(mIdentifier);
		
		return webServiceResponse;
	}
	
	@Override
	protected void onPostExecute(JsonNode rootNode) {
		MenuInformation menuInformation = new MenuInformation(rootNode.path("entity"));
	    String currentMenuType = (String) ((Set<String>) menuInformation.getMenuTypes()).iterator().next();
	    
	    UiMenuHorizontalScrollView applicationContainer = ShellUtil.initializeApplicationContainer(mActivity,
	            R.layout.ui_navigation_menu, R.layout.ui_empty_action_menu,
	            R.layout.menu);
	    ShellUtil.clearActionMenuButton(applicationContainer);
	    
	    //50 should work, but not displaying correctly, so nudging to 70
	    int menuBarHeight = (int) (75 * mActivity.getResources().getDisplayMetrics().density);
	    Display display = mActivity.getWindowManager().getDefaultDisplay();

	    LinearLayout container = (LinearLayout) applicationContainer.findViewById(R.id.container);
	    container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, display.getHeight() - menuBarHeight));
	    
	    mActivity.setApplicationContainer(applicationContainer);
		
		mActivity.setMenuInformation(menuInformation);
		mActivity.setCurrentMenuType(currentMenuType);
		mActivity.initializeMenuTypeSelector();
		mActivity.initializeAdapters();
	}

}
