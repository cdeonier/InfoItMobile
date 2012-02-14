package com.infoit.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.infoit.main.InfoChooser;
import com.infoit.main.ListBookmarks;
import com.infoit.main.R;
import com.infoit.widgets.MenuHorizontalScrollView;
import com.infoit.widgets.MenuOnClickListener;
import com.infoit.widgets.NavigationItemOnClickListener;

public class ShellUtil {

  public static MenuHorizontalScrollView initializeApplicationContainer(Context context,
      int navigationMenuResource, int actionsMenuResource,
      int applicationResource) {
    LayoutInflater inflater = LayoutInflater.from(context);
    MenuHorizontalScrollView scrollView = (MenuHorizontalScrollView) inflater
        .inflate(R.layout.ui_application_container, null);
    ((Activity) context).setContentView(scrollView);

    View navigationMenu = inflater.inflate(navigationMenuResource, null);
    View actionsMenu = inflater.inflate(actionsMenuResource, null);
    View application = inflater.inflate(applicationResource, null);

    RelativeLayout navigationMenuButton = (RelativeLayout) application
        .findViewById(R.id.menu_button);
    navigationMenuButton.setOnClickListener(new MenuOnClickListener(scrollView,
        navigationMenu, application.findViewById(R.id.touch_interceptor), 0));
    
    RelativeLayout actionsMenuButton = (RelativeLayout) application
        .findViewById(R.id.action_button);
    actionsMenuButton.setOnClickListener(new MenuOnClickListener(scrollView,
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

  private static void initializeNavigationMenu(Context context, MenuHorizontalScrollView scrollView, View navigationMenu) {
    TextView bookmarksListButton = (TextView) navigationMenu
        .findViewById(R.id.nav_bookmarks_list_button);
    bookmarksListButton.setOnClickListener(new NavigationItemOnClickListener(scrollView, ListBookmarks.class));
  }

}