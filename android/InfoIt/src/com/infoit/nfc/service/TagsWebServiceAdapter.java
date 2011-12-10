package com.infoit.nfc.service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigInteger;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import android.util.Log;

import com.infoit.nfc.record.InfoItServiceReturn;

public class TagsWebServiceAdapter {
	public static InfoItServiceReturn getLocationInformation(
			BigInteger identifier) {
		InfoItServiceReturn serviceReturn = new InfoItServiceReturn();

		// Web service call will go here, but dummy values for now
		if (identifier.equals(new BigInteger("100000000000"))) {
			serviceReturn.setmLocationName("Happy Cafe Restaurant");
			serviceReturn
					.setmLocationThumbnailUrl("http://s3-media4.ak.yelpcdn.com/bphoto/8xgOuq61aluI6zklXScwjg/ms.jpg");
			serviceReturn.setmLocationUrl("happycaferestaurant.blogspot.com/");
			serviceReturn.setmYelpIdentifier("happy-cafe-restaurant-san-mateo");
			serviceReturn.setmYelpRating("3.5");
			// lat: 37.565768, lng: -122.322751
			serviceReturn.setmFoursquareIdentifier("4b32ee1ef964a5201b1625e3");
		} else if (identifier.equals(new BigInteger("100000000001"))) {

		} else if (identifier.equals(new BigInteger("100000000002"))) {

		}

		return serviceReturn;
	}

	public static String getTagLocationsViaGPS(double latitude, double longitude) {
		StringBuilder builder = new StringBuilder();
		HttpClient client = new DefaultHttpClient();
		HttpGet httpGet = new HttpGet("http://www.getinfoit.com/tags?latitude=" + 
									  String.valueOf(latitude) + "&longitude=" + 
									  String.valueOf(longitude));
		
		try {
			HttpResponse response = client.execute(httpGet);
			StatusLine statusLine = response.getStatusLine();
			if(statusLine.getStatusCode() == 200) {
				HttpEntity entity = response.getEntity();
				InputStream content = entity.getContent();
				BufferedReader reader = new BufferedReader(new InputStreamReader(content));
				String line;
				while ((line = reader.readLine()) != null){
					builder.append(line);
				}
			}
			else{
				Log.e(TagsWebServiceAdapter.class.toString(), "Web Service did not return OK GPS tag locations");
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return builder.toString();
	}
	
	public static String getTagInformation(int tagId){
		StringBuilder builder = new StringBuilder();
		HttpClient client = new DefaultHttpClient();
		HttpGet httpGet = new HttpGet("http://infoit.heroku.com/services/696969");
		
		try {
			HttpResponse response = client.execute(httpGet);
			StatusLine statusLine = response.getStatusLine();
			if(statusLine.getStatusCode() == 200) {
				HttpEntity entity = response.getEntity();
				InputStream content = entity.getContent();
				BufferedReader reader = new BufferedReader(new InputStreamReader(content));
				String line;
				while ((line = reader.readLine()) != null){
					builder.append(line);
				}
			}
			else{
				Log.e(TagsWebServiceAdapter.class.toString(), "Web Service did not return OK GPS tag locations");
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return builder.toString();
	}
}
