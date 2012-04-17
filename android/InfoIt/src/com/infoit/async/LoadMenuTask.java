package com.infoit.async;

import java.util.Set;

import org.codehaus.jackson.JsonNode;

import android.os.AsyncTask;

import com.infoit.adapters.WebServiceAdapter;
import com.infoit.main.BaseApplication;
import com.infoit.main.DisplayMenu;
import com.infoit.record.MenuInformation;

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

		mActivity.setMenuInformation(menuInformation);
		mActivity.setCurrentMenuType(currentMenuType);
		mActivity.initializeMenuTypeSelector();
		mActivity.initializeList();
		mActivity.initializeAdapters();
		
		BaseApplication.removeSplashScreen();
	}

}
