package com.infoit.widgets;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.infoit.main.PhotoGallery;
import com.infoit.main.R;
import com.infoit.reader.record.AgentInformation;
import com.infoit.reader.record.BasicInformation;
import com.infoit.reader.record.LocationInformation;
import com.infoit.reader.record.RealEstateInformation;
import com.infoit.reader.service.WebServiceAdapter;
import com.infoit.widgetBlocks.AddressView;
import com.infoit.widgetBlocks.AgentView;
import com.infoit.widgetBlocks.BasicView;
import com.infoit.widgetBlocks.RealEstateView;

public class PlaceRealEstateView extends LinearLayout {
  private Activity mActivity;
  
  private BasicInformation mBasicInformation;
  private RealEstateInformation mRealEstateInformation;
  private LocationInformation mLocationInformation;
  private AgentInformation mAgentInformation;

  public PlaceRealEstateView(Context context) {
    super(context);
    mActivity = (Activity) context;
    LayoutInflater.from(context).inflate(R.layout.place_real_estate, this);
  }
  
  public PlaceRealEstateView(Context context, AttributeSet attrs, int defStyle) {
    super(context);
    mActivity = (Activity) context;
    LayoutInflater.from(context).inflate(R.layout.place_real_estate, this);
  }

  public PlaceRealEstateView(Context context, AttributeSet attrs) {
    super(context, attrs);
    mActivity = (Activity) context;
    LayoutInflater.from(context).inflate(R.layout.place_real_estate, this);
  }
  
  public void initializeView(JsonNode rootNode) {
    LinearLayout container = (LinearLayout) findViewById(R.id.real_estate_info_container);
    
    mBasicInformation = WebServiceAdapter.makeBasicInformationRecord(rootNode);
    mRealEstateInformation = WebServiceAdapter.makeRealEstateInformationRecord(rootNode);
    mLocationInformation = WebServiceAdapter.makeLocationInformationRecord(rootNode);
    mAgentInformation = WebServiceAdapter.makeAgentInformationRecord(rootNode);
    
    BasicView basicView = new BasicView(this.getContext());
    RealEstateView reView = new RealEstateView(this.getContext());
    AddressView addressView = new AddressView(this.getContext());
    AgentView agentView = new AgentView(this.getContext());
    
    basicView.setInformation(mBasicInformation);
    reView.setInformation(mRealEstateInformation);
    addressView.setInformation(mLocationInformation);
    agentView.setInformation(mAgentInformation);
    
    container.addView(basicView, container.getChildCount());
    container.addView(reView, container.getChildCount());
    container.addView(addressView, container.getChildCount());
    container.addView(agentView, container.getChildCount());
    
    initializeContentButtons();
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
        String mapUrl = "http://maps.google.com/maps?q="+
                        mLocationInformation.getAddressOne().replaceAll("\\s", "+")+"+"+
                        mLocationInformation.getCity().replaceAll("\\s", "+")+"+"+
                        mLocationInformation.getStateCode().replaceAll("\\s", "+");
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri
            .parse(mapUrl));
        mActivity.startActivity(intent);
      }
    });

    getDirectionsButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        String mapUrl = "http://maps.google.com/maps?saddr=&daddr="+
                        mLocationInformation.getAddressOne().replaceAll("\\s", "+")+"+"+
                        mLocationInformation.getCity().replaceAll("\\s", "+")+"+"+
                        mLocationInformation.getStateCode().replaceAll("\\s", "+");
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri
            .parse(mapUrl));
        mActivity.startActivity(intent);
      }
    });

    contactAgentButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        String url = "tel:" + mAgentInformation.getPhone().replaceAll("[\\s\\-()]", "");
        Intent intent = new Intent(Intent.ACTION_CALL, Uri.parse(url));
        mActivity.startActivity(intent);
      }
    });

    agentDetailsButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        String url = mAgentInformation.getUrl();
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        mActivity.startActivity(intent);
      }
    });

    photosButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        Intent intent = new Intent(v.getContext(), PhotoGallery.class);
        intent.putExtra("photoUrls", mBasicInformation.getPhotoUrls());
        v.getContext().startActivity(intent);
      }
    });
  }
  
}
