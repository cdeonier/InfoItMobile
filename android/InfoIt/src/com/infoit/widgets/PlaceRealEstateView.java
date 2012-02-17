package com.infoit.widgets;

import org.codehaus.jackson.JsonNode;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

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

  public PlaceRealEstateView(Context context) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.place_real_estate, this);
  }
  
  public PlaceRealEstateView(Context context, AttributeSet attrs, int defStyle) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.place_real_estate, this);
  }

  public PlaceRealEstateView(Context context, AttributeSet attrs) {
    super(context, attrs);
    LayoutInflater.from(context).inflate(R.layout.place_real_estate, this);
  }
  
  public void initializeView(JsonNode rootNode) {
    LinearLayout container = (LinearLayout) findViewById(R.id.real_estate_info_container);
    
    BasicInformation basicInfo = WebServiceAdapter.makeBasicInformationRecord(rootNode);
    RealEstateInformation realEstateInfo = WebServiceAdapter.makeRealEstateInformationRecord(rootNode);
    LocationInformation locInfo = WebServiceAdapter.makeLocationInformationRecord(rootNode);
    AgentInformation agentInfo = WebServiceAdapter.makeAgentInformationRecord(rootNode);
    
    BasicView basicView = new BasicView(this.getContext());
    RealEstateView reView = new RealEstateView(this.getContext());
    AddressView addressView = new AddressView(this.getContext());
    AgentView agentView = new AgentView(this.getContext());
    
    basicView.setInformation(basicInfo);
    reView.setInformation(realEstateInfo);
    addressView.setInformation(locInfo);
    agentView.setInformation(agentInfo);
    
    container.addView(basicView, container.getChildCount());
    container.addView(reView, container.getChildCount());
    container.addView(addressView, container.getChildCount());
    container.addView(agentView, container.getChildCount());
  }
  
}
