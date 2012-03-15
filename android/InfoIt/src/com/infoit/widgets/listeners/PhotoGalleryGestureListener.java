package com.infoit.widgets.listeners;

import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;

import com.infoit.main.PhotoGallery;
import com.infoit.main.R;

public class PhotoGalleryGestureListener extends SimpleOnGestureListener {
  private PhotoGallery mActivity;
  
  private static final int SWIPE_MIN_DISTANCE = 80;
  private static final int SWIPE_THRESHOLD_VELOCITY = 200;
  
  public PhotoGalleryGestureListener(PhotoGallery activity) {
    mActivity = activity;
  }
  
  @Override
  public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
      float velocityY) {

    if (e1.getX() - e2.getX() > SWIPE_MIN_DISTANCE
        && Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
      if (mActivity.getPosition() < mActivity.getImageUrls().size() - 1) {
        mActivity.setPosition(mActivity.getPosition() + 1);
        mActivity.setDisplayImage();
      }
      return false; // Right to left
    } else if (e2.getX() - e1.getX() > SWIPE_MIN_DISTANCE
        && Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
      if (mActivity.getPosition() > 0) {
        mActivity.setPosition(mActivity.getPosition() - 1);
        mActivity.setDisplayImage();
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
    LinearLayout backToInfoButton = (LinearLayout) mActivity.findViewById(R.id.back_to_info_button);

    if (View.GONE == (backToInfoButton.getVisibility())) {
      backToInfoButton.setVisibility(View.VISIBLE);
      backToInfoButton.setOnClickListener(new OnClickListener() {
        @Override
        public void onClick(View v) {
          mActivity.finish();
        }
      });
    } else {
      backToInfoButton.setVisibility(View.GONE);
    }

    return super.onSingleTapConfirmed(e);
  }
}