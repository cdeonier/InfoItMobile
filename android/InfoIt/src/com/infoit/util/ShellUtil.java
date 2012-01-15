package com.infoit.util;

import android.app.Activity;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.infoit.main.R;
import com.infoit.main.ListSavedEntities;

public class ShellUtil {

  public static void initializeShellForActivity(Activity activity) {
    initializeListButton(activity);
    initializeTransitions(activity);
  }

  private static void initializeListButton(Activity activity) {
    ImageView listButton = (ImageView) activity.findViewById(R.id.list_button);

    if (activity instanceof ListSavedEntities) {
      ((LinearLayout) listButton.getParent()).removeView(listButton);
    } else {
      listButton.setOnClickListener(new OnClickListener() {
        @Override
        public void onClick(View v) {
          Intent listIntent = new Intent(v.getContext(),
              ListSavedEntities.class);
          v.getContext().startActivity(listIntent);
        }
      });
    }
  }

  private static void initializeTransitions(Activity activity) {
    if (activity instanceof ListSavedEntities) {
      activity.overridePendingTransition(R.anim.ui_left_to_right_transition,
          R.anim.ui_right_to_left_transition);
    } else {
      activity.overridePendingTransition(R.anim.ui_left_to_right_transition,
          R.anim.ui_right_to_left_transition);
    }
  }
}
