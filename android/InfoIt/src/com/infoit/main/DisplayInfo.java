package com.infoit.main;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.infoit.reader.service.BookmarkDbAdapter;
import com.infoit.reader.service.WebServiceAdapter;
import com.infoit.util.ShellUtil;
import com.infoit.widgets.PlaceRealEstateView;
import com.infoit.widgets.UiMenuHorizontalScrollView;

public class DisplayInfo extends Activity {
  private BookmarkDbAdapter mDbHelper;
  private UiMenuHorizontalScrollView applicationContainer;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    android.os.Debug.waitingForDebugger();

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

    applicationContainer = ShellUtil.initializeApplicationContainer(this,
        R.layout.ui_navigation_menu, R.layout.display_info_actions_menu,
        R.layout.display_info);

    mDbHelper = new BookmarkDbAdapter(this);

    LinearLayout content = (LinearLayout) findViewById(R.id.content);
    
    PlaceRealEstateView view = new PlaceRealEstateView(this);
    view.initializeView(WebServiceAdapter.getInformationAsJson(1));
    content.addView(view, content.getChildCount() - 1);
  }

  @Override
  protected void onResume() {
    super.onResume();
    mDbHelper.open();

    initializeContentButtons();
    initializeActionMenu();

    RelativeLayout touchInterceptor = (RelativeLayout) findViewById(R.id.touch_interceptor);
    touchInterceptor.setVisibility(View.GONE);
    applicationContainer.scrollToApplicationView();
  }

  @Override
  protected void onPause() {
    super.onPause();
    mDbHelper.close();
  }

  private void initializeContentButtons() {
    ImageView openMapButton = (ImageView) findViewById(R.id.open_map_button);
    ImageView getDirectionsButton = (ImageView) findViewById(R.id.get_directions_button);
    ImageView contactAgentButton = (ImageView) findViewById(R.id.contact_agent_button);
    ImageView agentDetailsButton = (ImageView) findViewById(R.id.agent_details_button);
    FrameLayout photosButton = (FrameLayout) findViewById(R.id.thumbnail_container);

    openMapButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View arg0) {
        String mapUrl = "http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=855+Spruance+Lane,+Foster+City,+CA&aq=0&oq=855+spruance&sll=37.568168,-122.312573&sspn=0.013368,0.032916&vpsrc=0&ie=UTF8&hq=&hnear=855+Spruance+Ln,+Foster+City,+California+94404&t=h&z=17&iwloc=A";
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri
            .parse(mapUrl));
        startActivity(intent);
      }
    });

    getDirectionsButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        String mapUrl = "http://maps.google.com/maps?f=d&source=s_d&saddr=615+South+Idaho+Street,+San+Mateo,+CA&daddr=855+Spruance+Ln,+Foster+City,+CA+94404";
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri
            .parse(mapUrl));
        startActivity(intent);
      }
    });

    contactAgentButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        String url = "tel:6175992159";
        Intent intent = new Intent(Intent.ACTION_CALL, Uri.parse(url));
        startActivity(intent);
      }
    });

    agentDetailsButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        String url = "http://tamichiu.com/";
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        startActivity(intent);
      }
    });

    photosButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        Intent intent = new Intent(v.getContext(), PhotoGallery.class);
        v.getContext().startActivity(intent);
      }
    });
  }

  private void initializeActionMenu() {

    TextView bookmarkButton = (TextView) applicationContainer
        .findViewById(R.id.action_display_info_bookmark_button);
    if (mDbHelper.doesBookmarkExist(1)) {
      bookmarkButton.setText("Remove Bookmark");
    }
    bookmarkButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        TextView bookmarkButton = (TextView) v;

        if (bookmarkButton.getText().toString().contains("Add")) {
          // Replace "1" with entityId
          mDbHelper.createLocationBookmark(1, "855 Spruance Lane");
          bookmarkButton.setText("Remove Bookmark");
        } else {
          // Replace "1" with entityId
          mDbHelper.deleteLocationBookmark(1);
          bookmarkButton.setText("Add Bookmark");
        }
      }
    });
  }
}
