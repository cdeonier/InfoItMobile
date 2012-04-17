package com.infoit.widgets.listeners;

import com.infoit.widgets.UiShell;

import android.view.View;
import android.view.View.OnClickListener;

public class UiApplicationOnClickListener implements OnClickListener {
  private UiShell mParent;

  public UiApplicationOnClickListener(UiShell parent) {
    mParent = parent;
  }

  @Override
  public void onClick(View v) {
    mParent.scrollToApplicationView();
    v.setOnClickListener(null);
    v.setVisibility(View.GONE);
  }
}
