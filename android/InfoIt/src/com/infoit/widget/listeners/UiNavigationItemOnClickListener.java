package com.infoit.widget.listeners;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.RelativeLayout;

import com.infoit.main.R;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class UiNavigationItemOnClickListener implements OnClickListener {
  private UiMenuHorizontalScrollView mParent;
  private Class<?> mTargetContext;
  
  public UiNavigationItemOnClickListener(UiMenuHorizontalScrollView parent, Class<?> currentContext) {
    mParent = parent;
    mTargetContext = currentContext;
  }

  @Override
  public void onClick(View v) {
    Context currentContext = v.getContext();
    if(currentContext.getClass().equals(mTargetContext)){
      Activity currentActivity = (Activity) currentContext;
      RelativeLayout touchInterceptor = (RelativeLayout) currentActivity.findViewById(R.id.touch_interceptor);
      touchInterceptor.setVisibility(View.GONE);
      mParent.scrollToApplicationView();
    } else {
      Intent intent = new Intent(v.getContext(), mTargetContext);
      v.getContext().startActivity(intent);
    }
  }
}
