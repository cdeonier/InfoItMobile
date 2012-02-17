package com.infoit.widgetBlocks;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.main.R;
import com.infoit.reader.record.InformationRecord;
import com.infoit.reader.record.LocationInformation;

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
