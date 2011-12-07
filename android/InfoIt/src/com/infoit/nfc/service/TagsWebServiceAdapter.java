package com.infoit.nfc.service;

import java.math.BigInteger;

import com.infoit.nfc.record.InfoItServiceReturn;

public class TagsWebServiceAdapter {
	public static InfoItServiceReturn getLocationInformation(BigInteger identifier){
		InfoItServiceReturn serviceReturn = new InfoItServiceReturn();
		
		//Web service call will go here, but dummy values for now
		if(identifier.equals(new BigInteger("100000000000"))){
			serviceReturn.setmLocationName("Happy Cafe Restaurant");
			serviceReturn.setmLocationThumbnailUrl("http://s3-media4.ak.yelpcdn.com/bphoto/8xgOuq61aluI6zklXScwjg/ms.jpg");
			serviceReturn.setmLocationUrl("happycaferestaurant.blogspot.com/");
			serviceReturn.setmYelpIdentifier("happy-cafe-restaurant-san-mateo");
			serviceReturn.setmYelpRating("3.5");
			//lat: 37.565768, lng: -122.322751
			serviceReturn.setmFoursquareIdentifier("4b32ee1ef964a5201b1625e3");
		}
		else if(identifier.equals(new BigInteger("100000000001"))){
			
		}
		else if(identifier.equals(new BigInteger("100000000002"))){
			
		}
		
		return serviceReturn;
	}
}
