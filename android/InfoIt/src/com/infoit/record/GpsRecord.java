package com.infoit.record;

import org.codehaus.jackson.JsonNode;

public class GpsRecord {
	private String mName;
	private int mIdentifier;
	private String mDistance;
	private String mEntityType;
	private String mEntitySubType;
	
	public GpsRecord() {
		mName = null;
		mIdentifier = 0;
		mDistance = null;
		mEntityType = null;
		mEntitySubType = null;
	}
	
	public GpsRecord(JsonNode locationNode) {
		JsonNode entityNode = locationNode.path("entity");
		
		mName = entityNode.path("name").getTextValue();
		mIdentifier = entityNode.path("id").getIntValue();
		mDistance = String.valueOf(entityNode.path("distance").getIntValue());
		mEntityType = entityNode.path("entity_type").getTextValue();
		mEntitySubType = entityNode.path("entity_sub_type").getTextValue();
	}

	public String getName() {
		return mName;
	}

	public void setName(String name) {
		this.mName = name;
	}

	public int getIdentifier() {
		return mIdentifier;
	}

	public void setIdentifier(int identifier) {
		this.mIdentifier = identifier;
	}

	public String getDistance() {
		return mDistance;
	}

	public void setDistance(String distance) {
		this.mDistance = distance;
	}

	public String getEntityType() {
		return mEntityType;
	}

	public void setEntityType(String entityType) {
		this.mEntityType = entityType;
	}

	public String getEntitySubType() {
		return mEntitySubType;
	}

	public void setEntitySubType(String entitySubType) {
		this.mEntitySubType = entitySubType;
	}

	@Override
	public String toString() {
		return mName;
	}
	
}
