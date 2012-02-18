package com.infoit.reader.record;

import java.util.ArrayList;

public class BasicInformation implements InformationRecord {
  private String mThumbnailUrl;
  private String mName;
  private String mDescription;
  private String mEntityType;
  private ArrayList<String> mPhotoUrls;
  
  public BasicInformation() {
    mPhotoUrls = new ArrayList<String>();
  }
  
  public String getThumbnailUrl() {
    return mThumbnailUrl;
  }
  public void setThumbnailUrl(String thumbnailUrl) {
    this.mThumbnailUrl = thumbnailUrl;
  }
  public String getName() {
    return mName;
  }
  public void setName(String name) {
    this.mName = name;
  }
  public String getDescription() {
    return mDescription;
  }
  public void setDescription(String description) {
    this.mDescription = description;
  }
  public String getEntityType() {
    return mEntityType;
  }
  public void setEntityType(String entityType) {
    this.mEntityType = entityType;
  }
  public ArrayList<String> getPhotoUrls() {
    return mPhotoUrls;
  }
  public void setPhotoUrls(ArrayList<String> photoUrls) {
    this.mPhotoUrls = photoUrls;
  }

  
}
