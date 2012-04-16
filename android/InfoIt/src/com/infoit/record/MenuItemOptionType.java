package com.infoit.record;

import java.util.ArrayList;

import org.codehaus.jackson.JsonNode;

public class MenuItemOptionType {
	private String mName;
	private String mDescription;
	private ArrayList<MenuItemOption> mOptions;
	
	public MenuItemOptionType(JsonNode optionTypeNode) {
		mName = optionTypeNode.path("name").getTextValue();
		mDescription = optionTypeNode.path("description").getTextValue();
		
    JsonNode optionsNode = optionTypeNode.path("entity").path("menu_item_options");
    mOptions = new ArrayList<MenuItemOption>();
    for(JsonNode node : optionsNode) {
    	mOptions.add(new MenuItemOption(node));
    }
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

	public ArrayList<MenuItemOption> getOptions() {
		return mOptions;
	}

	public void setOptions(ArrayList<MenuItemOption> options) {
		this.mOptions = options;
	}
}
