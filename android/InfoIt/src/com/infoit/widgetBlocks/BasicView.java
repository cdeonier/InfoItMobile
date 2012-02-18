package com.infoit.widgetBlocks;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.main.R;
import com.infoit.reader.record.BasicInformation;
import com.infoit.reader.record.InformationRecord;
import com.infoit.util.ImageUtil;

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
    TextView name = (TextView) findViewById(R.id.basic_name);
    TextView description = (TextView) findViewById(R.id.basic_description);
    ImageView thumbnail = (ImageView) findViewById(R.id.basic_thumbnail);
    
    Drawable image = ImageUtil.getImage(mBasicInformation.getThumbnailUrl());
    
    thumbnail.setImageDrawable(image);
    WindowManager wm = (WindowManager) this.getContext().getSystemService(Context.WINDOW_SERVICE);
    Display display = wm.getDefaultDisplay();
    //display.getWidth is deprecated-- need to change to using Point later
    thumbnail.setLayoutParams(new FrameLayout.LayoutParams(display.getWidth(), display.getWidth() / 4 * 3));

    name.setText(mBasicInformation.getName());
    description.setText(mBasicInformation.getDescription());
  }

}
