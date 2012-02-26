package com.infoit.reader.record;

public class BookmarkRecord {
  private int mIdentifier;
  private String mName;
  
  public BookmarkRecord(int identifier, String name) {
    mIdentifier = identifier;
    mName = name;
  }
  
  public int getIdentifier() {
    return mIdentifier;
  }
  
  public void setIdentifier(int identifier) {
    mIdentifier = identifier;
  }
  
  public String getName() {
    return mName;
  }
  
  public void setName(String name) {
    mName = name;
  }
}
