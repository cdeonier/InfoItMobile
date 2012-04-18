package com.infoit.widgetBlocks;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.main.BaseApplication;
import com.infoit.main.PhotoGallery;
import com.infoit.main.R;
import com.infoit.record.BasicInformation;
import com.infoit.record.InformationRecord;
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
  
  @Override
  public void setContentButtons(Activity activity) {
    FrameLayout photosButton = (FrameLayout) findViewById(R.id.thumbnail_container);

    if (mBasicInformation.getThumbnailUrl() != null) {
	    photosButton.setOnClickListener(new OnClickListener() {
	
	      @Override
	      public void onClick(View v) {
	        Intent intent = new Intent(BaseApplication.getCurrentActivity(), PhotoGallery.class);
	        intent.putExtra("photoUrls", mBasicInformation.getPhotoUrls());
	        BaseApplication.getCurrentActivity().startActivity(intent);
	      }
	    });
    }
  }
  
  private void initView() {
    TextView name = (TextView) findViewById(R.id.basic_name);
    TextView description = (TextView) findViewById(R.id.basic_description);
    FrameLayout thumbnailContainer = (FrameLayout) findViewById(R.id.thumbnail_container);
    
    Drawable image = ImageUtil.getProfileImage(mBasicInformation.getThumbnailUrl(), this);
    
    ImageView thumbnail = new ImageView(this.getContext());
    thumbnail.setImageDrawable(image);

    DisplayMetrics dm = new DisplayMetrics();
    WindowManager wm = (WindowManager) this.getContext().getSystemService(Context.WINDOW_SERVICE);
    wm.getDefaultDisplay().getMetrics(dm);
    int width = dm.widthPixels;
    int height = width * image.getIntrinsicHeight() / image.getIntrinsicWidth();
    thumbnailContainer.addView(thumbnail, new FrameLayout.LayoutParams(width, height));
    
    if (mBasicInformation.getThumbnailUrl() != null) {
	    LinearLayout photoButton = (LinearLayout) View.inflate(this.getContext(), R.layout.ui_photos_button, null);
	    FrameLayout.LayoutParams photoButtonParams = new FrameLayout.LayoutParams(LayoutParams.WRAP_CONTENT, 
	    																																					LayoutParams.WRAP_CONTENT, 
	    																																					Gravity.RIGHT | Gravity.BOTTOM);
	    int photoButtonOffset = (int) (20 * getResources().getDisplayMetrics().density);
	    photoButtonParams.setMargins(0, 0, 0, photoButtonOffset);
	    thumbnailContainer.addView(photoButton, photoButtonParams);
    }

    name.setText(mBasicInformation.getName());
    description.setText(mBasicInformation.getDescription());
  }

}
