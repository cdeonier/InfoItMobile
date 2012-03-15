package com.infoit.record;

import org.codehaus.jackson.JsonNode;

public class AgentInformation implements InformationRecord {
  private String mName;
  private String mAgency;
  private String mPosition;
  private String mPhone;
  private String mUrl;
  private String mThumbnailUrl;
  
  public AgentInformation() {
  
  }
  
  public AgentInformation(JsonNode rootNode) {
    JsonNode agentNode = rootNode.path("entity").path("place_details").path("real_estate_agent");
    
    mName = agentNode.path("name").getTextValue();
    mAgency = agentNode.path("agency").getTextValue();
    mPosition = agentNode.path("position").getTextValue();
    mPhone = agentNode.path("phone").getTextValue();
    mUrl = agentNode.path("website").getTextValue();
    mThumbnailUrl = agentNode.path("thumbnail_url").getTextValue();
  }

  public String getName() {
    return mName;
  }

  public void setName(String name) {
    mName = name;
  }

  public String getAgency() {
    return mAgency;
  }

  public void setAgency(String agency) {
    mAgency = agency;
  }

  public String getPosition() {
    return mPosition;
  }

  public void setPosition(String position) {
    mPosition = position;
  }

  public String getPhone() {
    return mPhone;
  }

  public void setPhone(String phone) {
    mPhone = phone;
  }

  public String getUrl() {
    return mUrl;
  }

  public void setUrl(String url) {
    mUrl = url;
  }

  public String getThumbnailUrl() {
    return mThumbnailUrl;
  }

  public void setThumbnailUrl(String thumbnailUrl) {
    this.mThumbnailUrl = thumbnailUrl;
  }

}
