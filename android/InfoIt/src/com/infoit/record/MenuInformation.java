package com.infoit.record;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Set;

import org.codehaus.jackson.JsonNode;

public class MenuInformation {
	
	private LinkedHashMap<String, LinkedHashMap<String, ArrayList<MenuItemListRecord>>> mRestaurantMenus;
	@SuppressWarnings("unused")
	private int mRestaurantIdentifier;

	public MenuInformation(JsonNode rootNode) {
		mRestaurantMenus = 
				new LinkedHashMap<String, LinkedHashMap<String, ArrayList<MenuItemListRecord>>>();
		
		JsonNode menuItems = rootNode.path("menu_items");
		
		mRestaurantIdentifier = rootNode.path("restaurant_id").getIntValue();
		
		//State change variables
		String currentMenuType = null;
		String currentCategory = null;
		
		LinkedHashMap<String, ArrayList<MenuItemListRecord>> menu = null;
		ArrayList<MenuItemListRecord> categoryItems = null;
		
		
		for (JsonNode nodeItem : menuItems) {
			JsonNode item = nodeItem.path("menu_item");
			String itemMenuType = item.path("menu_type").getTextValue();
			String itemCategory = item.path("menu_category").getTextValue();
			
			if (!itemMenuType.equals(currentMenuType)) {
				//New menu, so by default we have new category
				currentMenuType = itemMenuType;
				currentCategory = itemCategory;
				
				//Create new empty sets to fill up
				menu = new LinkedHashMap<String, ArrayList<MenuItemListRecord>>();
				categoryItems = new ArrayList<MenuItemListRecord>();
				
				menu.put(currentCategory, categoryItems);
				mRestaurantMenus.put(currentMenuType, menu);
			}
			
			if(!itemCategory.equals(currentCategory)) {
				currentCategory = itemCategory;
				categoryItems = new ArrayList<MenuItemListRecord>();
				menu.put(currentCategory, categoryItems);
			}
			
			MenuItemListRecord menuItemRecord = new MenuItemListRecord();
			menuItemRecord.setName(item.path("name").getTextValue());
			menuItemRecord.setDescription(item.path("description").getTextValue());
			menuItemRecord.setCategory(item.path("menu_category").getTextValue());
			menuItemRecord.setPrice(item.path("price").getTextValue());
			menuItemRecord.setLikeCount(item.path("like_count").getIntValue());
			menuItemRecord.setMenuType(item.path("menu_type").getTextValue());
			menuItemRecord.setThumbnailUrl(item.path("profile_photo_thumbnail_url").getTextValue());
			menuItemRecord.setEntityId(item.path("entity_id").getIntValue());

			categoryItems.add(menuItemRecord);
		}
	}
	
	public Set<String> getMenuTypes() {
		return mRestaurantMenus.keySet();
	}
	
	public Set<String> getCategoriesForMenu(String menuType) {
		return mRestaurantMenus.get(menuType).keySet();
	}
	
	public ArrayList<MenuItemListRecord> getMenuItemsForCategory(String menuType, String category) {
		return mRestaurantMenus.get(menuType).get(category);
	}
	
	public ArrayList<MenuItemListRecord> getAllMenuItemsForMenuType(String menuType) {
		ArrayList<MenuItemListRecord> allMenuItemsForMenuType = new ArrayList<MenuItemListRecord>();
		
		for (String category : getCategoriesForMenu(menuType)) {
			allMenuItemsForMenuType.addAll(getMenuItemsForCategory(menuType, category));
		}
		
		return allMenuItemsForMenuType;
	}
}