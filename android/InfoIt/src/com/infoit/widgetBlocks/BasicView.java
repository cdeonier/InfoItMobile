package com.infoit.widgetBlocks;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import com.infoit.main.R;
import com.infoit.reader.record.BasicInformation;
import com.infoit.reader.record.InformationRecord;

public class BasicView extends LinearLayout implements BaseInformationView {
  private BasicInformation mBasicInformation;

  public BasicView(Context context) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.block_basic, this);
  }
  
  public BasicView(Context context, AttributeSet attrs, int defStyle) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.block_basic, this);
  }

  public BasicView(Context context, AttributeSet attrs) {
    super(context, attrs);
    LayoutInflater.from(context).inflate(R.layout.block_basic, this);
  }

  @Override
  public void setInformation(InformationRecord information) {
    mBasicInformation = (BasicInformation) information;
    initView();
  }
  
  private void initView() {
    
  }

}
