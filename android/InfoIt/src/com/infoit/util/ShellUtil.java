package com.infoit.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.infoit.main.InfoChooser;
import com.infoit.main.ListBookmarks;
import com.infoit.main.R;
import com.infoit.main.RecentHistory;
import com.infoit.widgets.UiMenuHorizontalScrollView;
import com.infoit.widgets.listeners.UiMenuOnClickListener;
import com.infoit.widgets.listeners.UiNavigationItemOnClickListener;

public class ShellUtil {

  public static UiMenuHorizontalScrollView initializeApplicationContainer(Context context,
      int navigationMenuResource, int actionsMenuResource,
      int applicationResource) {
    LayoutInflater inflater = LayoutInflater.from(context);
    UiMenuHorizontalScrollView scrollView = (UiMenuHorizontalScrollView) inflater
        .inflate(R.layout.ui_application_container, null);
    ((Activity) context).setContentView(scrollView);

    View navigationMenu = inflater.inflate(navigationMenuResource, null);
    View actionsMenu = inflater.inflate(actionsMenuResource, null);
    View application = inflater.inflate(applicationResource, null);

    RelativeLayout navigationMenuButton = (RelativeLayout) application
        .findViewById(R.id.menu_button);
    navigationMenuButton.setOnClickListener(new UiMenuOnClickListener(scrollView,
        navigationMenu, application.findViewById(R.id.touch_interceptor), 0));
    
    RelativeLayout actionsMenuButton = (RelativeLayout) application
        .findViewById(R.id.action_button);
    actionsMenuButton.setOnClickListener(new UiMenuOnClickListener(scrollView,
        actionsMenu, application.findViewById(R.id.touch_interceptor), 2));
    
    RelativeLayout infoItButton = (RelativeLayout) application
        .findViewById(R.id.infoit_button);
    infoItButton.setOnClickListener(new OnClickListener() {
      @Override
      public void onClick(View v) {
        Intent intent = new Intent(v.getContext(), InfoChooser.class);
        v.getContext().startActivity(intent);

      }
    });

    final View[] children = new View[] { navigationMenu, application,
        actionsMenu };
    int scrollToViewIndex = 1;
    scrollView.initViews(children, scrollToViewIndex);

    initializeNavigationMenu(context, scrollView, navigationMenu);

    return scrollView;
  }
  
  public static void clearActionMenuButton(View applicationContainer) {
    RelativeLayout actionsMenuButton = (RelativeLayout) applicationContainer
        .findViewById(R.id.action_button);
    actionsMenuButton.setOnClickListener(null);
    actionsMenuButton.removeAllViews();
  }

  private static void initializeNavigationMenu(Context context, UiMenuHorizontalScrollView scrollView, View navigationMenu) {
    LinearLayout bookmarksListButton = (LinearLayout) navigationMenu
        .findViewById(R.id.nav_bookmarks_list_button);
    bookmarksListButton.setOnClickListener(new UiNavigationItemOnClickListener(scrollView, ListBookmarks.class));
    
    LinearLayout historyListButton = (LinearLayout) navigationMenu
        .findViewById(R.id.nav_recent_history_button);
    historyListButton.setOnClickListener(new UiNavigationItemOnClickListener(scrollView, RecentHistory.class));
  }

}
