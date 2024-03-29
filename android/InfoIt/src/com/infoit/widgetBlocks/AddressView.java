package com.infoit.widgetBlocks;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.android.apps.analytics.easytracking.EasyTracker;
import com.infoit.constants.Constants;
import com.infoit.main.R;
import com.infoit.record.InformationRecord;
import com.infoit.record.LocationInformation;

public class AddressView extends LinearLayout implements BaseInformationView {
  LocationInformation mLocationInformation;

  public AddressView(Context context) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.block_address, this);
  }

  public AddressView(Context context, AttributeSet attrs, int defStyle) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.block_address, this);
  }

  public AddressView(Context context, AttributeSet attrs) {
    super(context, attrs);
    LayoutInflater.from(context).inflate(R.layout.block_address, this);
  }
  
  public void setInformation(InformationRecord locationInformation){
    mLocationInformation = (LocationInformation) locationInformation;
    initView();
  }
  
  @Override
  public void setContentButtons(Activity activity) {
    
    ImageView openMapButton = (ImageView) findViewById(R.id.open_map_button);
    ImageView getDirectionsButton = (ImageView) findViewById(R.id.get_directions_button);
    
    openMapButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
      	EasyTracker.getTracker().trackEvent(Constants.ACTIVITY_CATEGORY, Constants.ACTIVITY_BUTTON, Constants.OPEN_MAP_BUTTON, 0);
        String mapUrl = "http://maps.google.com/maps?q="+
                        mLocationInformation.getAddressOne().replaceAll("\\s", "+")+"+"+
                        mLocationInformation.getCity().replaceAll("\\s", "+")+"+"+
                        mLocationInformation.getStateCode().replaceAll("\\s", "+");
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri
            .parse(mapUrl));
        v.getContext().startActivity(intent);
      }
    });

    getDirectionsButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
      	EasyTracker.getTracker().trackEvent(Constants.ACTIVITY_CATEGORY, Constants.ACTIVITY_BUTTON, Constants.GET_DIRECTIONS_BUTTON, 0);
        String mapUrl = "http://maps.google.com/maps?saddr=&daddr="+
                        mLocationInformation.getAddressOne().replaceAll("\\s", "+")+"+"+
                        mLocationInformation.getCity().replaceAll("\\s", "+")+"+"+
                        mLocationInformation.getStateCode().replaceAll("\\s", "+");
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri
            .parse(mapUrl));
        v.getContext().startActivity(intent);
      }
    });
    
    
  }
  
  private void initView() {
    TextView addressOne = (TextView) findViewById(R.id.address_one);
    TextView addressTwo = (TextView) findViewById(R.id.address_two);
    TextView city = (TextView) findViewById(R.id.city);
    TextView state = (TextView) findViewById(R.id.state);
    TextView zip = (TextView) findViewById(R.id.zip);
    
    addressOne.setText(mLocationInformation.getAddressOne());
    addressTwo.setText(mLocationInformation.getAddressTwo());
    city.setText(mLocationInformation.getCity() + ", ");
    state.setText(mLocationInformation.getStateCode() + " ");
    zip.setText(mLocationInformation.getZip());
    
    if(mLocationInformation.getAddressTwo() == null || mLocationInformation.getAddressTwo().equals("")) {
      addressTwo.setVisibility(View.GONE);
    }
  }
}
