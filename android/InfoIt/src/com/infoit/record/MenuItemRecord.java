package com.infoit.record;

public class MenuItemRecord {
	private String mName;
	private String mDescription;
	private String mPrice;
	private String mThumbnailUrl;
	
	public MenuItemRecord() {
		mName = "name";
		mDescription = "description";
		mPrice = "10";
		mThumbnailUrl = "http://s3-us-west-1.amazonaws.com/infoit-photos/places/piperade_thumbnail_1.jpg";
	}
	
	public String getName() {
		return mName;
	}
	public void setName(String name) {
		mName = name;
	}
	public String getDescription() {
		return mDescription;
	}
	public void setDescription(String description) {
		mDescription = description;
	}
	public String getPrice() {
		return mPrice;
	}
	public void setPrice(String price) {
		mPrice = price;
	}
	public String getThumbnailUrl() {
		return mThumbnailUrl;
	}
	public void setThumbnailUrl(String thumbnailUrl) {
		mThumbnailUrl = thumbnailUrl;
	}

}
