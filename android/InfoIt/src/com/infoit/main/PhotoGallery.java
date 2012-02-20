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
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.infoit.async.DownloadImageTask;
import com.infoit.main.R.layout;
import com.infoit.widget.listeners.PhotoGalleryGestureListener;

public class PhotoGallery extends Activity {
  private final GestureDetector mGestureDetector 
    = new GestureDetector(new PhotoGalleryGestureListener(this));
  private ProgressDialog mProgressDialog;
  private ArrayList<Drawable> mImages;
  private ArrayList<String> mImageUrls;
  private int mPosition;

  @SuppressWarnings("unchecked")
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(layout.photo_gallery);

    mPosition = 0;
    mImageUrls = (ArrayList<String>) getIntent().getExtras().get("photoUrls");
    mImages = new ArrayList<Drawable>();
  }
  
  @Override
  protected void onResume(){
    super.onResume();
    setDisplayImage();
  }

  @Override
  protected void onStop() {
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

  public void setDisplayImage() {
    ImageView displayImage = (ImageView) findViewById(R.id.photo);
    displayImage.setOnTouchListener(new OnTouchListener() {
      @Override
      public boolean onTouch(final View view, final MotionEvent event) {
        mGestureDetector.onTouchEvent(event);
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

  public int getPosition() {
    return mPosition;
  }

  public void setPosition(int mPosition) {
    this.mPosition = mPosition;
  }

  public ArrayList<Drawable> getImages() {
    return mImages;
  }

  public void setmImages(ArrayList<Drawable> images) {
    this.mImages = images;
  }

  public ArrayList<String> getImageUrls() {
    return mImageUrls;
  }

  public void setmImageUrls(ArrayList<String> imageUrls) {
    this.mImageUrls = imageUrls;
  }
  
  public ProgressDialog getProgressDialog() {
    return mProgressDialog;
  }
}
