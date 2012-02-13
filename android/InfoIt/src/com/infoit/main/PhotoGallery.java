package com.infoit.main;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.infoit.main.R.layout;

public class PhotoGallery extends Activity {
  private final GestureDetector gdt = new GestureDetector(new GestureListener());

  private static final int SWIPE_MIN_DISTANCE = 120;
  private static final int SWIPE_THRESHOLD_VELOCITY = 200;

  private ArrayList<Drawable> images;
  private int position;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(layout.photo_gallery);

    position = 0;

    setupTestImages();
    setDisplayImage();
  }

  @Override
  public void onConfigurationChanged(Configuration newConfig) {
    super.onConfigurationChanged(newConfig);

    setContentView(R.layout.photo_gallery);

    setDisplayImage();
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
    displayImage.setImageDrawable(images.get(position));
  }

  private void setupTestImages() {
    images = new ArrayList<Drawable>();
    images.add(getResources().getDrawable(R.drawable.house_1));
    images.add(getResources().getDrawable(R.drawable.house_2));
    images.add(getResources().getDrawable(R.drawable.house_3));
    images.add(getResources().getDrawable(R.drawable.house_4));
  }

  private class GestureListener extends SimpleOnGestureListener {
    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
        float velocityY) {
      ImageView displayImage = (ImageView) findViewById(R.id.photo);

      if (e1.getX() - e2.getX() > SWIPE_MIN_DISTANCE
          && Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
        if (position < images.size() - 1) {
          position = position + 1;
          displayImage.setImageDrawable(images.get(position));
        }
        return false; // Right to left
      } else if (e2.getX() - e1.getX() > SWIPE_MIN_DISTANCE
          && Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
        if (position > 0) {
          position = position - 1;
          displayImage.setImageDrawable(images.get(position));
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
            Intent listIntent = new Intent(v.getContext(),
                DisplayInfo.class);
            v.getContext().startActivity(listIntent);
          }
        });
      } else {
        backToInfoButton.setVisibility(View.GONE);
      }

      return super.onSingleTapConfirmed(e);
    }
  }
}
