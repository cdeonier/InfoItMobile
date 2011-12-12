package com.infoit.nfc.service;

public class TagLocation {
	private String mLocationName;
	private String mLocationIdentifier;
	
	public TagLocation(String locationName, String locationIdentifier){
		this.mLocationName = locationName;
		this.mLocationIdentifier = locationIdentifier;
	}
	
	public String getLocationName() {
		return mLocationName;
	}
	public void setLocationName(String mLocationName) {
		this.mLocationName = mLocationName;
	}
	public String getLocationIdentifier() {
		return mLocationIdentifier;
	}
	public void setLocationIdentifier(String mLocationIdentifier) {
		this.mLocationIdentifier = mLocationIdentifier;
	}
	
	

}
