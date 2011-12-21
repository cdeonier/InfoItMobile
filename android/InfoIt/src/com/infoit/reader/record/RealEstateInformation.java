package com.infoit.reader.record;

public class RealEstateInformation {
	private String mName;
	private Integer mPrice;
	private String mSpecs;
	private Integer mSize;
	private String mAddressOne;
	private String mAddressTwo;
	private String mCity;
	private String mState;
	private Integer mZipCode;
	private String mThumbnailUrl;
	
	public String getThumbnailUrl() {
		return mThumbnailUrl;
	}
	public void setThumbnailUrl(String mThumbnailUrl) {
		this.mThumbnailUrl = mThumbnailUrl;
	}
	public String getName() {
		return mName;
	}
	public void setName(String mName) {
		this.mName = mName;
	}
	public Integer getPrice() {
		return mPrice;
	}
	public void setPrice(Integer mPrice) {
		this.mPrice = mPrice;
	}
	public String getSpecs() {
		return mSpecs;
	}
	public void setSpecs(String mSpecs) {
		this.mSpecs = mSpecs;
	}
	public Integer getSize() {
		return mSize;
	}
	public void setSize(Integer mSpace) {
		this.mSize = mSpace;
	}
	public String getAddressOne() {
		return mAddressOne;
	}
	public void setAddressOne(String mAddressOne) {
		this.mAddressOne = mAddressOne;
	}
	public String getAddressTwo() {
		return mAddressTwo;
	}
	public void setAddressTwo(String mAddressTwo) {
		this.mAddressTwo = mAddressTwo;
	}
	public String getCity() {
		return mCity;
	}
	public void setCity(String mCity) {
		this.mCity = mCity;
	}
	public String getState() {
		return mState;
	}
	public void setState(String mState) {
		this.mState = mState;
	}
	public Integer getZipCode() {
		return mZipCode;
	}
	public void setZipCode(Integer mZipCode) {
		this.mZipCode = mZipCode;
	}
}
