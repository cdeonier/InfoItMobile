package com.infoit.widgets.listeners;

import android.app.Activity;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.RelativeLayout;

import com.infoit.main.R;
import com.infoit.ui.UiShell;

public class UiNavigationItemOnClickListener implements OnClickListener {
  private UiShell mParent;
  private Class<?> mTargetContext;
  private Activity mCurrentActivity;
  
  public UiNavigationItemOnClickListener(UiShell parent, Class<?> targetContext, Activity activity) {
    mParent = parent;
    mTargetContext = targetContext;
    mCurrentActivity = activity;
  }

  @Override
  public void onClick(View v) {
    if(mCurrentActivity.getClass().equals(mTargetContext)){
      RelativeLayout touchInterceptor = (RelativeLayout) mCurrentActivity.findViewById(R.id.touch_interceptor);
      touchInterceptor.setVisibility(View.GONE);
      mParent.scrollToApplicationView();
    } else {
      Intent intent = new Intent(mCurrentActivity, mTargetContext);
      mCurrentActivity.startActivity(intent);
    }
  }
}
