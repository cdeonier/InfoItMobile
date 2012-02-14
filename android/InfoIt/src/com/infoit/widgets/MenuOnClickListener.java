package com.infoit.widgets;

import android.view.View;
import android.view.View.OnClickListener;

public class MenuOnClickListener implements OnClickListener {
  private MenuHorizontalScrollView scrollView;
  private View touchInterceptor;
  private View menu;
  private int viewIndex;

  public MenuOnClickListener(MenuHorizontalScrollView scrollView, View menu, View touchInterceptor,
      int viewIndex) {
    super();
    this.scrollView = scrollView;
    this.touchInterceptor = touchInterceptor;
    this.menu = menu;
    this.viewIndex = viewIndex;
  }

  @Override
  public void onClick(View view) {
    int menuWidth = menu.getMeasuredWidth();

    // Ensure menu is visible
    menu.setVisibility(View.VISIBLE);

    if (viewIndex < 1) {
      int left = 0;
      scrollView.smoothScrollTo(left, 0);
    } else {
      int right = scrollView.getMeasuredWidth() + menuWidth;
      scrollView.smoothScrollTo(right, 0);
    }
    
    touchInterceptor.setVisibility(View.VISIBLE);
    touchInterceptor.setOnClickListener(new ApplicationOnClickListener(scrollView));
  }
}
