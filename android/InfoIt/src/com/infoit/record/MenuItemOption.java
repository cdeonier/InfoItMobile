package com.infoit.record;

import org.codehaus.jackson.JsonNode;

public class MenuItemOption {
	private String mName;
	private String mDescription;
	private String mPrice;
	
	public MenuItemOption(JsonNode optionNode) {
		mName = optionNode.path("name").getTextValue();
		mDescription = optionNode.path("description").getTextValue();
		mPrice = optionNode.path("price").getTextValue();
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

	public String getPrice() {
		return mPrice;
	}

	public void setPrice(String price) {
		this.mPrice = price;
	}
}
