package com.infoit.widgets;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.widget.HorizontalScrollView;

public class MenuHorizontalScrollView extends HorizontalScrollView {

  public MenuHorizontalScrollView(Context context, AttributeSet attrs,
      int defStyle) {
    super(context, attrs, defStyle);
    init(context);
  }

  public MenuHorizontalScrollView(Context context, AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public MenuHorizontalScrollView(Context context) {
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
    OnGlobalLayoutListener listener = new MenuOnGlobalLayoutListener(parent,
        children, scrollToViewIndex, this);
    getViewTreeObserver().addOnGlobalLayoutListener(listener);
  }

  @Override
  public boolean onTouchEvent(MotionEvent ev) {
    // Do not allow touch events.
    return false;
  }

  @Override
  public boolean onInterceptTouchEvent(MotionEvent ev) {
    // Do not allow touch events.
    return false;
  }

  public void scrollToApplicationView(){
    int width = this.getMeasuredWidth();
    int menuWidth = (width / 5) * 4;
    this.scrollTo(menuWidth, 0);
  }
}
