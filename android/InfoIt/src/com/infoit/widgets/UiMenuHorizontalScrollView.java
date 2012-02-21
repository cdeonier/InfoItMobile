package com.infoit.widgets;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.widget.HorizontalScrollView;
import android.widget.RelativeLayout;

import com.infoit.main.R;
import com.infoit.widget.listeners.UiMenuOnGlobalLayoutListener;

public class UiMenuHorizontalScrollView extends HorizontalScrollView {
  private int mPosition;

  public UiMenuHorizontalScrollView(Context context, AttributeSet attrs,
      int defStyle) {
    super(context, attrs, defStyle);
    init(context);
  }

  public UiMenuHorizontalScrollView(Context context, AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public UiMenuHorizontalScrollView(Context context) {
    super(context);
    init(context);
  }

  void init(Context context) {
    // remove the fading as the HSV looks better without it
    setHorizontalFadingEdgeEnabled(false);
    setVerticalFadingEdgeEnabled(false);
  }

  /**
   * @param children
   *          The child Views to add to parent.
   * @param scrollToViewIdx
   *          The index of the View to scroll to after initialisation.
   * @param sizeCallback
   *          A SizeCallback to interact with the HSV.
   */
  public void initViews(View[] children, int scrollToViewIndex) {
    // A ViewGroup MUST be the only child of the HSV
    ViewGroup parent = (ViewGroup) getChildAt(0);

    // Add all the children, but add them invisible so that the layouts are
    // calculated, but you can't see the Views
    for (int i = 0; i < children.length; i++) {
      children[i].setVisibility(View.INVISIBLE);
      parent.addView(children[i]);
    }

    // Add a layout listener to this HSV
    // This listener is responsible for arranging the child views.
    OnGlobalLayoutListener listener = new UiMenuOnGlobalLayoutListener(parent,
        children, scrollToViewIndex, this);
    getViewTreeObserver().addOnGlobalLayoutListener(listener);
  }

  @Override
  public boolean onTouchEvent(MotionEvent ev) {

    //Uncomment for flinging -- Remember to set touch interceptor
    /*
    if (xDistance > 0) { //Scroll to left
      if(isApplicationView()){
        scrollToLeftMenu();
      } else if (isActionView()) {
        scrollToApplicationView();
      }
    } else { //Scroll to right
      if(isApplicationView()){
        scrollToRightMenu();
      } else if (isMenuView()) {
        scrollToApplicationView();
      }
    }*/

    
    // Do not allow touch events.
    return false;
  }

  @Override
  public boolean onInterceptTouchEvent(MotionEvent ev) {

    //Uncomment for flinging
    /*
    switch (ev.getAction()) {
      case MotionEvent.ACTION_DOWN:
        xDistance = yDistance = 0f;
        lastX = ev.getX();
        lastY = ev.getY();
        lastTime = ev.getEventTime();
        break;
      case MotionEvent.ACTION_MOVE:
        final float curX = ev.getX();
        final float curY = ev.getY();
        final long curTime = ev.getEventTime();
        xDistance += curX - lastX;
        yDistance += curY - lastY;
        time = curTime - lastTime;
        lastX = curX;
        lastY = curY;
        lastTime = curTime;
        if (Math.abs(xDistance) > Math.abs(yDistance)) {
          //We're scrolling left or right
          float velocity = Math.abs(xDistance) * 1000 / (float) time;
          if(velocity > SWIPE_THRESHOLD_VELOCITY && Math.abs(xDistance) > SWIPE_MIN_DISTANCE) {
            return true;
          } else {
            return false;
          }
        }
    }

    return false;
    */
    // Do not allow touch events.
    return false;
  }

  public void scrollToApplicationView() {
    //Leave this here to handle coming back to this activity from another activity
    RelativeLayout touchInterceptor = (RelativeLayout) this.findViewById(R.id.touch_interceptor);
    touchInterceptor.setVisibility(View.GONE);
    
    int width = this.getMeasuredWidth();
    int menuWidth = (width / 5) * 4;
    this.scrollTo(menuWidth, 0);
    mPosition = 1;
  }
  
  public void scrollToLeftMenu() {
    int left = 0;
    this.smoothScrollTo(left, 0);
    mPosition = 0;
  }
  
  public void scrollToRightMenu() {
    int width = this.getMeasuredWidth();
    int menuWidth = (width / 5) * 4;
    int right = this.getMeasuredWidth() + menuWidth;
    this.smoothScrollTo(right, 0);
    mPosition = 2;
  }
  
  public boolean isApplicationView() {
    return mPosition == 1;
  }
  
  public boolean isMenuView() {
    return mPosition == 0;
  }
  
  public boolean isActionView() {
    return mPosition == 2;
  }
  
}
