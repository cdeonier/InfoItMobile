package com.infoit.widgets;

import android.view.View;
import android.view.View.OnClickListener;

public class ApplicationOnClickListener implements OnClickListener {
  private MenuHorizontalScrollView mParent;

  public ApplicationOnClickListener(MenuHorizontalScrollView parent) {
    mParent = parent;
  }

  @Override
  public void onClick(View v) {
    mParent.scrollToApplicationView();
    v.setOnClickListener(null);
    v.setVisibility(View.GONE);
  }
}
