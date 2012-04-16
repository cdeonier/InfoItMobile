package com.infoit.record;

import java.util.ArrayList;

import org.codehaus.jackson.JsonNode;

public class MenuItemInformation {
	private int mRestaurantId;
	private ArrayList<MenuItemOptionType> mOptionTypes;
	
	public MenuItemInformation(JsonNode rootNode) {
		JsonNode menuItemNode = rootNode.path("entity").path("things_details").path("menu_item");
		mRestaurantId = rootNode.path("entity").path("restaurant_id").getIntValue();
		
    JsonNode optionTypesNode = menuItemNode.path("menu_item_option_types");
    mOptionTypes = new ArrayList<MenuItemOptionType>();
    for(JsonNode node : optionTypesNode) {
    	mOptionTypes.add(new MenuItemOptionType(node));
    }
	}

	public int getRestaurantId() {
		return mRestaurantId;
	}

	public void setRestaurantId(int restaurantId) {
		this.mRestaurantId = restaurantId;
	}

	public ArrayList<MenuItemOptionType> getOptionTypes() {
		return mOptionTypes;
	}

	public void setOptionTypes(ArrayList<MenuItemOptionType> optionTypes) {
		this.mOptionTypes = optionTypes;
	}

}
