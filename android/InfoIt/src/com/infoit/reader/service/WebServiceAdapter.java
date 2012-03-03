package com.infoit.reader.service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.codehaus.jackson.JsonNode;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;

import android.location.Location;
import android.util.Log;

public class WebServiceAdapter {
	
	public static String getEntityType(JsonNode rootNode) {
	  return rootNode.path("entity").path("entity_type").getTextValue();
	}
	
	public static String getEntitySubType(JsonNode rootNode) {
	  return rootNode.path("entity").path("entity_sub_type").getTextValue();
	}
	
	public static JsonNode getNearbyLocationsAsJson(Location location) {
		String latitude = String.valueOf(location.getLatitude());
		String longitude = String.valueOf(location.getLongitude());
		HttpGet httpGet = new HttpGet("http://getinfoit.com/services/geocode?latitude="+
									  latitude+"&longitude="+longitude+"&type=nearby");
		String response = callWebService(httpGet);
		
		ObjectMapper mapper = new ObjectMapper();
		JsonNode rootNode = null;
		
	    try {
	        rootNode = mapper.readValue(response, JsonNode.class);
	      } catch (JsonParseException e) {
	        e.printStackTrace();
	      } catch (JsonMappingException e) {
	        e.printStackTrace();
	      } catch (IOException e) {
	        e.printStackTrace();
	      }
	  	  
	  	  return rootNode;
	}
	
	public static JsonNode getInformationAsJson(int locationIdentifier) {
	  HttpGet httpGet = new HttpGet("http://www.getinfoit.com/services/"+Integer.toString(locationIdentifier));
	  String response = callWebService(httpGet);
	  
	  ObjectMapper mapper = new ObjectMapper();
	  JsonNode rootNode = null;
	  
    try {
      rootNode = mapper.readValue(response, JsonNode.class);
    } catch (JsonParseException e) {
      e.printStackTrace();
    } catch (JsonMappingException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }
	  
	  return rootNode;
	}
	
	/**
	 * Basic way to call a service.  Give it http request, it returns a JSON response.
	 * 
	 * @param serviceCall the service request
	 * @return JSON response in form of String
	 */
	private static String callWebService(HttpGet serviceCall){
		StringBuilder builder = new StringBuilder();
		HttpClient client = new DefaultHttpClient();
		
		try {
			HttpResponse response = client.execute(serviceCall);
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
				Log.e(WebServiceAdapter.class.toString(), "Web Service Error -- callWebService failed");
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return builder.toString();
	}
}
