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

import android.util.Log;

import com.infoit.reader.record.AgentInformation;
import com.infoit.reader.record.BasicInformation;
import com.infoit.reader.record.LocationInformation;
import com.infoit.reader.record.RealEstateInformation;

public class WebServiceAdapter {
  
  public static RealEstateInformation makeRealEstateInformationRecord(JsonNode rootNode) {
	  RealEstateInformation realEstateInformation = new RealEstateInformation();
    
    JsonNode realEstateDetailNode = rootNode.path("entity").path("place_details").path("real_estate_detail");
    realEstateInformation.setPrice(String.valueOf(realEstateDetailNode.path("price").getDoubleValue()));
    realEstateInformation.setPropertyType(realEstateDetailNode.path("property_type").getTextValue());
    realEstateInformation.setBedrooms(String.valueOf(realEstateDetailNode.path("bedrooms").getDoubleValue()));
    realEstateInformation.setBathrooms(String.valueOf(realEstateDetailNode.path("bathrooms").getDoubleValue()));
    realEstateInformation.setSize(String.valueOf(realEstateDetailNode.path("size").getDoubleValue()));
    realEstateInformation.setLotSize(String.valueOf(realEstateDetailNode.path("lot").getDoubleValue()));
    realEstateInformation.setYearBuilt(realEstateDetailNode.path("year_built").getBigIntegerValue().toString());
	  
	  return realEstateInformation;
	}
	
	public static BasicInformation makeBasicInformationRecord(JsonNode rootNode){
	  BasicInformation basicInformation = new BasicInformation();
	  
	  JsonNode entityNode = rootNode.path("entity");
	  basicInformation.setName(entityNode.path("name").getTextValue());
	  basicInformation.setDescription(entityNode.path("description").getTextValue());
	  basicInformation.setEntityType(entityNode.path("entity_type").getTextValue());
	  basicInformation.setThumbnailUrl(entityNode.path("thumbnail_url").getTextValue());
	  
	  JsonNode photosNode = rootNode.path("entity").path("photo");
	  for(JsonNode node : photosNode) {
	    basicInformation.getPhotoUrls().add(node.getTextValue());
	  }
	  
	  return basicInformation;
	}
	
	public static LocationInformation makeLocationInformationRecord(JsonNode rootNode){
	  LocationInformation locationInformation = new LocationInformation();
	  
	  JsonNode addressNode = rootNode.path("entity").path("place_details").path("address");
	  locationInformation.setAddressOne(addressNode.path("street_address_one").getTextValue());
	  locationInformation.setAddressTwo(addressNode.path("street_address_two").getTextValue());
	  locationInformation.setCity(addressNode.path("city").getTextValue());
	  locationInformation.setStateCode(addressNode.path("state").getTextValue());
	  locationInformation.setZip(addressNode.path("zip_code").getTextValue());
	  
	  return locationInformation;
	}
	
	public static AgentInformation makeAgentInformationRecord(JsonNode rootNode) {
	  AgentInformation agentInformation = new AgentInformation();
	  
	  JsonNode agentNode = rootNode.path("entity").path("place_details").path("real_estate_agent");
	  agentInformation.setName(agentNode.path("name").getTextValue());
	  agentInformation.setPhone(agentNode.path("phone").getTextValue());
	  agentInformation.setUrl(agentNode.path("website").getTextValue());
	  agentInformation.setPosition(agentNode.path("position").getTextValue());
	  agentInformation.setAgency(agentNode.path("agency").getTextValue());
	  agentInformation.setThumbnailUrl(agentNode.path("thumbnail_url").getTextValue());
	  
	  return agentInformation;
	}
	
	public static String getEntityType(JsonNode rootNode) {
	  return rootNode.path("entity").path("entity_type").getTextValue();
	}
	
	public static String getEntitySubType(JsonNode rootNode) {
	  return rootNode.path("entity").path("entity_sub_type").getTextValue();
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
