package com.infoit.widgetBlocks;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import com.infoit.main.R;
import com.infoit.reader.record.InformationRecord;

public class MenuView extends LinearLayout implements BaseInformationView {
	
	public MenuView(Context context) {
		super(context);
		LayoutInflater.from(context).inflate(R.layout.block_menu_button, this);
	}

	public MenuView(Context context, AttributeSet attrs, int defStyle) {
		super(context);
		LayoutInflater.from(context).inflate(R.layout.block_menu_button, this);
	}

	public MenuView(Context context, AttributeSet attrs) {
		super(context, attrs);
		LayoutInflater.from(context).inflate(R.layout.block_menu_button, this);
	}

	@Override
	public void setInformation(InformationRecord information) {

	}

	@Override
	public void setContentButtons(Activity activity) {
		
	}
}
