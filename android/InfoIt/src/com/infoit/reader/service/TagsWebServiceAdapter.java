package com.infoit.reader.service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.util.ArrayList;

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

import android.util.Log;

import com.infoit.reader.record.InfoItServiceReturn;
import com.infoit.reader.record.RealEstateInformation;

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
		HttpGet httpGet = new HttpGet("http://www.getinfoit.com/services/"+Integer.toString(tagId));
		
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
	
	//Test function
	public static ArrayList<TagLocation> generateNearbyLocations(){
		TagLocation l1 = new TagLocation("Happy Cafe", "1");
		TagLocation l2 = new TagLocation("New York Pizza", "2");
		TagLocation l3 = new TagLocation("Dominos", "3");
		
		ArrayList<TagLocation> al = new ArrayList<TagLocation>();
		al.add(l1);
		al.add(l2);
		al.add(l3);
		
		return al;
	}
	
	public static RealEstateInformation getBasicInfoRealEstate(int tagId){
		RealEstateInformation basicInfo = new RealEstateInformation();
		
		String response = getTagInformation(tagId);
		
		ObjectMapper m = new ObjectMapper();
		try {
			JsonNode rootNode = m.readValue(response, JsonNode.class);
			JsonNode widgetNode = rootNode.path("tag").path("widgets");
			for(JsonNode node : widgetNode){
				if(node.path("name").getTextValue().equals("Basic")){
					JsonNode basicWidgetParameters = node.path("widget_parameters");
					for(JsonNode parameter : basicWidgetParameters){
						String parameterName = parameter.path("name").getTextValue();
						String parameterValue = parameter.path("value").getTextValue();
						if("name".equals(parameterName)){
							basicInfo.setName(parameterValue);
						}
						else if("price".equals(parameterName)){
							basicInfo.setPrice(Integer.valueOf(parameterValue));
						}
						else if("specs".equals(parameterName)){
							basicInfo.setSpecs(parameterValue);
						}
						else if("size".equals(parameterName)){
							basicInfo.setSize(Integer.valueOf(parameterValue));
						}
						else if("address_one".equals(parameterName)){
							basicInfo.setAddressOne(parameterValue);
						}
						else if("address_two".equals(parameterName)){
							basicInfo.setAddressTwo(parameterValue);
						}
						else if("city".equals(parameterName)){
							basicInfo.setCity(parameterValue);
						}
						else if("state".equals(parameterName)){
							basicInfo.setState(parameterValue);
						}
						else if("zip_code".equals(parameterName)){
							basicInfo.setZipCode(Integer.valueOf(parameterValue));
						}
						else if("thumbnail_url".equals(parameterName)){
							basicInfo.setThumbnailUrl(parameterValue);
						}
					}
				}
			}
			
		} catch (JsonParseException e) {
			e.printStackTrace();
		} catch (JsonMappingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		
		return basicInfo;
	}
}
