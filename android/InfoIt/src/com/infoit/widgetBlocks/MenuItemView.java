package com.infoit.widgetBlocks;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import com.infoit.main.R;
import com.infoit.record.InformationRecord;
import com.infoit.record.MenuItemInformation;

public class MenuItemView extends LinearLayout implements BaseInformationView {
	
	private MenuItemInformation mMenuItemInformation;
	
	public MenuItemView(Context context) {
		super(context);
		LayoutInflater.from(context).inflate(R.layout.block_menu_item, this);
	}

	public MenuItemView(Context context, AttributeSet attrs, int defStyle) {
		super(context);
		LayoutInflater.from(context).inflate(R.layout.block_menu_item, this);
	}

	public MenuItemView(Context context, AttributeSet attrs) {
		super(context, attrs);
		LayoutInflater.from(context).inflate(R.layout.block_menu_item, this);
	}

	@Override
	public void setInformation(InformationRecord information) {
		mMenuItemInformation = (MenuItemInformation) information;
	}

	@Override
	public void setContentButtons(Activity activity) {
		// TODO Auto-generated method stub
		
	}
	
	private void initView() {
		
	}
}
