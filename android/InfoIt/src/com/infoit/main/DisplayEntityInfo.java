package com.infoit.main;

import com.infoit.reader.service.BookmarkDbAdapter;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

public class DisplayEntityInfo extends FragmentActivity {
  private BookmarkDbAdapter mDbHelper;
  
  @Override
  public void onCreate(Bundle savedInstanceState) {
    

    super.onCreate(savedInstanceState);

    // Lock to Portrait Mode
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    setContentView(R.layout.display_entity_info);
    
    mDbHelper = new BookmarkDbAdapter(this);
    mDbHelper.open();
    
    ImageView openMapButton = (ImageView) findViewById(R.id.open_map_button);
    ImageView getDirectionsButton = (ImageView) findViewById(R.id.get_directions_button);
    ImageView contactAgentButton = (ImageView) findViewById(R.id.contact_agent_button);
    ImageView agentDetailsButton = (ImageView) findViewById(R.id.agent_details_button);
    LinearLayout photosButton = (LinearLayout) findViewById(R.id.photos_button);
    RelativeLayout menuButton = (RelativeLayout) findViewById(R.id.menu_button);
    RelativeLayout actionButton = (RelativeLayout) findViewById(R.id.action_button);
    RelativeLayout infoItButton = (RelativeLayout) findViewById(R.id.infoit_button);
    
    openMapButton.setOnClickListener(new OnClickListener(){
      @Override
      public void onClick(View arg0) {
        String mapUrl = "http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=855+Spruance+Lane,+Foster+City,+CA&aq=0&oq=855+spruance&sll=37.568168,-122.312573&sspn=0.013368,0.032916&vpsrc=0&ie=UTF8&hq=&hnear=855+Spruance+Ln,+Foster+City,+California+94404&t=h&z=17&iwloc=A";
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(mapUrl));
        startActivity(intent);
      }
    });
    
    getDirectionsButton.setOnClickListener(new OnClickListener() {
      
      @Override
      public void onClick(View v) {
        String mapUrl = "http://maps.google.com/maps?f=d&source=s_d&saddr=615+South+Idaho+Street,+San+Mateo,+CA&daddr=855+Spruance+Ln,+Foster+City,+CA+94404";
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(mapUrl));
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
    
    menuButton.setOnClickListener(new OnClickListener() {
      
      @Override
      public void onClick(View v) {
        Intent intent = new Intent(v.getContext(), ListBookmarks.class);
        v.getContext().startActivity(intent);
      }
    });
    
    actionButton.setOnClickListener(new OnClickListener() {
      
      @Override
      public void onClick(View v) {
        Intent intent = new Intent(v.getContext(), ListBookmarks.class);
        v.getContext().startActivity(intent);
        mDbHelper.createLocationBookmark(1, "855 Spruance Lane");
        
      }
    });
    
    infoItButton.setOnClickListener(new OnClickListener() {
      
      @Override
      public void onClick(View v) {
        Intent intent = new Intent(v.getContext(), InfoChooser.class);
        v.getContext().startActivity(intent);
        
      }
    });
    
  }

}
