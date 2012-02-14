package com.infoit.widgets;

import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.widget.HorizontalScrollView;

class MenuOnGlobalLayoutListener implements OnGlobalLayoutListener {
  ViewGroup parent;
  View[] children;
  int scrollToViewIndex;
  int scrollToViewPos = 0;
  MenuHorizontalScrollView scrollView;

  /**
   * @param parent
   *          The parent to which the child Views should be added.
   * @param children
   *          The child Views to add to parent.
   * @param scrollToViewIdx
   *          The index of the View to scroll to after initialisation.
   * @param sizeCallback
   *          A SizeCallback to interact with the HSV.
   */
  public MenuOnGlobalLayoutListener(ViewGroup parent, View[] children,
      int scrollToViewIndex, MenuHorizontalScrollView scrollView) {
    this.parent = parent;
    this.children = children;
    this.scrollToViewIndex = scrollToViewIndex;
    this.scrollView = scrollView;
  }

  @Override
  public void onGlobalLayout() {
    final HorizontalScrollView me = this.scrollView;

    // The listener will remove itself as a layout listener to the HSV
    me.getViewTreeObserver().removeGlobalOnLayoutListener(this);

    // Allow the SizeCallback to 'see' the Views before we remove them and
    // re-add them.
    // This lets the SizeCallback prepare View sizes, ahead of calls to
    // SizeCallback.getViewSize().
    // sizeCallback.onGlobalLayout();

    parent.removeViewsInLayout(0, children.length);

    final int w = me.getMeasuredWidth();
    final int h = me.getMeasuredHeight();

    scrollToViewPos = 0;
    for (int i = 0; i < children.length; i++) {
      int childWidth;
      if (i == 1) {
        childWidth = w;
      } else {
        childWidth = (w / 5) * 4;
      }

      parent.addView(children[i], childWidth, h);
      if (i < scrollToViewIndex) {
        scrollToViewPos += childWidth;
      }
    }

    // For some reason we need to post this action, rather than call
    // immediately.
    // If we try immediately, it will not scroll.
    new Handler().post(new Runnable() {
      @Override
      public void run() {
        // Set visibility here to prevent "jump" because of a delayed scroll
        for (View child : children) {
          child.setVisibility(View.VISIBLE);
        }
        me.scrollTo(scrollToViewPos, 0);
      }
    });
  }
  

}