package com.infoit.reader.record;

public class RealEstateInformation implements InformationRecord {

  private String mPrice;
  private String mPropertyType;
  private String mBedrooms;
  private String mBathrooms;
  private String mSize;
  private String mLotSize;
  private String mYearBuilt;
  
  public String getPrice() {
    return mPrice;
  }

  public void setPrice(String price) {
    this.mPrice = price;
  }

  public String getPropertyType() {
    return mPropertyType;
  }

  public void setPropertyType(String propertyType) {
    this.mPropertyType = propertyType;
  }

  public String getBedrooms() {
    return mBedrooms;
  }

  public void setBedrooms(String bedrooms) {
    this.mBedrooms = bedrooms;
  }

  public String getBathrooms() {
    return mBathrooms;
  }

  public void setBathrooms(String bathrooms) {
    this.mBathrooms = bathrooms;
  }

  public String getSize() {
    return mSize;
  }

  public void setSize(String size) {
    this.mSize = size;
  }

  public String getLotSize() {
    return mLotSize;
  }

  public void setLotSize(String lotSize) {
    this.mLotSize = lotSize;
  }

  public String getYearBuilt() {
    return mYearBuilt;
  }

  public void setYearBuilt(String yearBuilt) {
    this.mYearBuilt = yearBuilt;
  }

}
