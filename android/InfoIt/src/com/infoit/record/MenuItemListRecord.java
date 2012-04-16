package com.infoit.record;

public class MenuItemListRecord {
	private String mName;
	private String mDescription;
	private String mPrice;
	private String mThumbnailUrl;
	private int mLikeCount;
	private String mCategory;
	private String mMenuType;
	private int mEntityId;

	public MenuItemListRecord() {
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

	public int getLikeCount() {
		return mLikeCount;
	}

	public void setLikeCount(int likeCount) {
		mLikeCount = likeCount;
	}

	public String getCategory() {
		return mCategory;
	}

	public void setCategory(String category) {
		mCategory = category;
	}

	public String getMenuType() {
		return mMenuType;
	}

	public void setMenuType(String menu) {
		mMenuType = menu;
	}

	public int getEntityId() {
		return mEntityId;
	}

	public void setEntityId(int entityId) {
		this.mEntityId = entityId;
	}

}
