package com.infoit.adapters;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.SingleClientConnManager;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
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
		HttpGet httpGet = new HttpGet("http://www.getinfoit.com/services/"
				+ Integer.toString(locationIdentifier));
		String response = callWebService(httpGet);
		
		JsonNode rootNode = createJsonFromString(response);

		return rootNode;
	}
	
	public static JsonNode getMenuAsJson(int locationIdentifier) {
		HttpGet httpGet = new HttpGet("http://www.getinfoit.com/menus/"
				+ Integer.toString(locationIdentifier));
		String response = callWebService(httpGet);
		
		JsonNode rootNode = createJsonFromString(response);

		return rootNode;
	}
	
	public static JsonNode createJsonFromString(String jsonAsString) {
		ObjectMapper mapper = new ObjectMapper();
		JsonNode rootNode = null;

		try {
			rootNode = mapper.readValue(jsonAsString, JsonNode.class);
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
	
	public static boolean createAccount(String email, String password) throws WebServiceException {
		SchemeRegistry schemeRegistry = new SchemeRegistry();
		schemeRegistry.register(new Scheme("https", SSLSocketFactory.getSocketFactory(), 443));
		HttpParams params = new BasicHttpParams();
		SingleClientConnManager mgr = new SingleClientConnManager(params, schemeRegistry);
		HttpClient client = new DefaultHttpClient(mgr, params);	
		HttpPost httpPost = new HttpPost("https://infoit.heroku.com/users.json");
		
		List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
    nameValuePairs.add(new BasicNameValuePair("user[email]", email));
    nameValuePairs.add(new BasicNameValuePair("user[password]", password));
    nameValuePairs.add(new BasicNameValuePair("user[password_confirmation]", password));
		
    HttpResponse response = null;
    
    try {
			httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
			response = client.execute(httpPost);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
    
    if (response != null) {
    	StatusLine statusLine = response.getStatusLine();
    	if (statusLine.getStatusCode() == 200) {
				return true;
    	} else {
    		return false;
    	}
    } else {
    	throw new WebServiceException();
    }
	}
	
	public static boolean login(String email, String password) throws WebServiceException {
		SchemeRegistry schemeRegistry = new SchemeRegistry();
		schemeRegistry.register(new Scheme("https", SSLSocketFactory.getSocketFactory(), 443));
		HttpParams params = new BasicHttpParams();
		SingleClientConnManager mgr = new SingleClientConnManager(params, schemeRegistry);
		HttpClient client = new DefaultHttpClient(mgr, params);	
		HttpPost httpPost = new HttpPost("https://infoit.heroku.com/sessions");
		
		List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
    nameValuePairs.add(new BasicNameValuePair("user[email]", email));
    nameValuePairs.add(new BasicNameValuePair("user[password]", password));
		
    HttpResponse response = null;
    
    try {
			httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
			response = client.execute(httpPost);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
    
    if (response != null) {
    	StatusLine statusLine = response.getStatusLine();
    	if (statusLine.getStatusCode() == 200) {
    		return true;
    	} else {
    		return false;
    	}
    } else {
    	throw new WebServiceException();
    }
	}
}
