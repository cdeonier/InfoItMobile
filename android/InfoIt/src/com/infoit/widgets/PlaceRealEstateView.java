package com.infoit.widgets;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import com.infoit.main.R;
import com.infoit.record.AgentInformation;
import com.infoit.record.BasicInformation;
import com.infoit.record.LocationInformation;
import com.infoit.record.RealEstateInformation;
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
    
    mBasicInformation = new BasicInformation(rootNode);
    mRealEstateInformation = new RealEstateInformation(rootNode);
    mLocationInformation = new LocationInformation(rootNode);
    mAgentInformation = new AgentInformation(rootNode);
    
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
    
    basicView.setContentButtons(mActivity);
    reView.setContentButtons(mActivity);
    addressView.setContentButtons(mActivity);
    agentView.setContentButtons(mActivity);
  }
  
  public BasicInformation getBasicInformation() {
    return mBasicInformation;
  }
  
}
