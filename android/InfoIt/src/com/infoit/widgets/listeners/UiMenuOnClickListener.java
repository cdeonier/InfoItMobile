package com.infoit.widgets.listeners;

import com.infoit.widgets.UiMenuHorizontalScrollView;

import android.view.View;
import android.view.View.OnClickListener;

public class UiMenuOnClickListener implements OnClickListener {
  private UiMenuHorizontalScrollView mScrollView;
  private View mTouchInterceptor;
  private View mMenu;
  private int mViewIndex;

  public UiMenuOnClickListener(UiMenuHorizontalScrollView scrollView, View menu, View touchInterceptor,
      int viewIndex) {
    super();
    mScrollView = scrollView;
    mTouchInterceptor = touchInterceptor;
    mMenu = menu;
    mViewIndex = viewIndex;
  }

  @Override
  public void onClick(View view) {
    

    // Ensure menu is visible
    mMenu.setVisibility(View.VISIBLE);

    if (mViewIndex < 1) {
      mScrollView.scrollToLeftMenu();
    } else {
      mScrollView.scrollToRightMenu();
    }
    
    mTouchInterceptor.setVisibility(View.VISIBLE);
    mTouchInterceptor.setOnClickListener(new UiApplicationOnClickListener(mScrollView));
  }
}
