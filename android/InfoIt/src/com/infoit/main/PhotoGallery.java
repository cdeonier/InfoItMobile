package com.infoit.main;

import java.util.ArrayList;
import java.util.concurrent.ExecutionException;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.res.Configuration;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.infoit.async.DownloadImageTask;
import com.infoit.main.R.layout;

public class PhotoGallery extends Activity {
  private final GestureDetector gdt = new GestureDetector(new GestureListener());
  private ProgressDialog mProgressDialog;

  private static final int SWIPE_MIN_DISTANCE = 120;
  private static final int SWIPE_THRESHOLD_VELOCITY = 200;

  private ArrayList<Drawable> mImages;
  private ArrayList<String> mImageUrls;
  private int mPosition;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(layout.photo_gallery);

    mPosition = 0;
    
    mImageUrls = new ArrayList<String>();
    mImageUrls.add("http://s3-us-west-1.amazonaws.com/infoit-photos/re/san_mateo/spruance/855/photo_1.jpg");
    mImageUrls.add("http://s3-us-west-1.amazonaws.com/infoit-photos/re/san_mateo/spruance/855/photo_2.jpg");
    mImageUrls.add("http://s3-us-west-1.amazonaws.com/infoit-photos/re/san_mateo/spruance/855/photo_3.jpg");
    mImageUrls.add("http://s3-us-west-1.amazonaws.com/infoit-photos/re/san_mateo/spruance/855/photo_4.jpg");
    
    mImages = new ArrayList<Drawable>();
  }
  
  @Override
  protected void onResume(){
    super.onResume();
    setDisplayImage();
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();

    unbindDrawables(findViewById(R.id.container));
    System.gc();
  }

  @Override
  public void onConfigurationChanged(Configuration newConfig) {
    super.onConfigurationChanged(newConfig);

    setContentView(R.layout.photo_gallery);

    setDisplayImage();
  }

  private void unbindDrawables(View view) {
    if (view.getBackground() != null) {
      view.getBackground().setCallback(null);
    }
    if (view instanceof ViewGroup) {
      for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
        unbindDrawables(((ViewGroup) view).getChildAt(i));
      }
      ((ViewGroup) view).removeAllViews();
    }
  }

  private void setDisplayImage() {
    ImageView displayImage = (ImageView) findViewById(R.id.photo);
    displayImage.setOnTouchListener(new OnTouchListener() {
      @Override
      public boolean onTouch(final View view, final MotionEvent event) {
        gdt.onTouchEvent(event);
        return true;
      }
    });
    
    if(mPosition >= mImages.size()) {
      Drawable image = null;
      try {
        mProgressDialog = ProgressDialog.show(this, "", "Downloading image...", true);
        image = new DownloadImageTask(this, mImageUrls.get(mPosition)).execute().get();
      } catch (InterruptedException e) {
        Log.d("PhotoGallery", "Error downloading image.");
      } catch (ExecutionException e) {
        Log.d("PhotoGallery", "Error downloading image.");
      }
      if(image != null) {
        mImages.add(image);
      }
    } else {
      displayImage.setImageDrawable(mImages.get(mPosition));
    } 
  }

  private class GestureListener extends SimpleOnGestureListener {
    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
        float velocityY) {

      if (e1.getX() - e2.getX() > SWIPE_MIN_DISTANCE
          && Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
        if (mPosition < mImageUrls.size() - 1) {
          mPosition = mPosition + 1;
          setDisplayImage();
        }
        return false; // Right to left
      } else if (e2.getX() - e1.getX() > SWIPE_MIN_DISTANCE
          && Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
        if (mPosition > 0) {
          mPosition = mPosition - 1;
          setDisplayImage();
        }
        return false; // Left to right
      }
      if (e1.getY() - e2.getY() > SWIPE_MIN_DISTANCE
          && Math.abs(velocityY) > SWIPE_THRESHOLD_VELOCITY) {
        return false; // Bottom to top
      } else if (e2.getY() - e1.getY() > SWIPE_MIN_DISTANCE
          && Math.abs(velocityY) > SWIPE_THRESHOLD_VELOCITY) {
        return false; // Top to bottom
      }
      return false;
    }

    @Override
    public boolean onSingleTapUp(MotionEvent e) {
      LinearLayout backToInfoButton = (LinearLayout) findViewById(R.id.back_to_info_button);

      if (View.GONE == (backToInfoButton.getVisibility())) {
        backToInfoButton.setVisibility(View.VISIBLE);
        backToInfoButton.setOnClickListener(new OnClickListener() {
          @Override
          public void onClick(View v) {
            finish();
          }
        });
      } else {
        backToInfoButton.setVisibility(View.GONE);
      }

      return super.onSingleTapConfirmed(e);
    }
  }
  
  public ProgressDialog getProgressDialog() {
    return mProgressDialog;
  }
}
