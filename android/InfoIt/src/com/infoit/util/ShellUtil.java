package com.infoit.util;

import android.app.Activity;

import com.infoit.main.ListBookmarks;
import com.infoit.main.R;

public class ShellUtil {

  public static void initializeShellForActivity(Activity activity) {
    initializeListButton(activity);
    initializeTransitions(activity);
  }

  private static void initializeListButton(Activity activity) {
//    ImageView listButton = (ImageView) activity.findViewById(R.id.list_button);
//
//    if (activity instanceof ListBookmarks) {
//      ((LinearLayout) listButton.getParent()).removeView(listButton);
//    } else {
//      listButton.setOnClickListener(new OnClickListener() {
//        @Override
//        public void onClick(View v) {
//          Intent listIntent = new Intent(v.getContext(),
//              ListBookmarks.class);
//          v.getContext().startActivity(listIntent);
//        }
//      });
//    }
  }

  private static void initializeTransitions(Activity activity) {
    if (activity instanceof ListBookmarks) {
      activity.overridePendingTransition(R.anim.ui_left_to_right_transition,
          R.anim.ui_right_to_left_transition);
    } else {
      activity.overridePendingTransition(R.anim.ui_left_to_right_transition,
          R.anim.ui_right_to_left_transition);
    }
  }
}
