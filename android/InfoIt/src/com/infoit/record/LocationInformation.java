package com.infoit.record;

import org.codehaus.jackson.JsonNode;

public class LocationInformation implements InformationRecord {
  private String mAddressOne;
  private String mAddressTwo;
  private String mCity;
  private String mStateCode;
  private String mZip;
  
  public LocationInformation() {
    mAddressOne = null;
    mAddressTwo = null;
    mCity = null;
    mStateCode = null;
    mZip = null;
  }
  
  public LocationInformation(JsonNode rootNode) {
    JsonNode addressNode = rootNode.path("entity").path("place_details").path("address");
    
    mAddressOne = addressNode.path("street_address_one").getTextValue();
    mAddressTwo = addressNode.path("street_address_two").getTextValue();
    mCity = addressNode.path("city").getTextValue();
    mStateCode = addressNode.path("state").getTextValue();
    mZip = addressNode.path("zip_code").getTextValue();
  }
  
  public String getAddressOne() {
    return mAddressOne;
  }
  public void setAddressOne(String addressOne) {
    this.mAddressOne = addressOne;
  }
  public String getAddressTwo() {
    return mAddressTwo;
  }
  public void setAddressTwo(String addressTwo) {
    this.mAddressTwo = addressTwo;
  }
  public String getCity() {
    return mCity;
  }
  public void setCity(String city) {
    this.mCity = city;
  }
  public String getStateCode() {
    return mStateCode;
  }
  public void setStateCode(String stateCode) {
    this.mStateCode = stateCode;
  }
  public String getZip() {
    return mZip;
  }
  public void setZip(String zip) {
    this.mZip = zip;
  }
  
  

}
