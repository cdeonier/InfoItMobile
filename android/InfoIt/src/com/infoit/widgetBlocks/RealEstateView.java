package com.infoit.widgetBlocks;

import java.text.NumberFormat;
import java.util.Locale;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.main.R;
import com.infoit.reader.record.InformationRecord;
import com.infoit.reader.record.RealEstateInformation;

public class RealEstateView extends LinearLayout implements BaseInformationView {
  
  private RealEstateInformation mRealEstateInformation;

  public RealEstateView(Context context) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.block_real_estate, this);
  }
  
  public RealEstateView(Context context, AttributeSet attrs) {
    super(context, attrs);
    LayoutInflater.from(context).inflate(R.layout.block_real_estate, this);
  }
  
  public RealEstateView(Context context, AttributeSet attrs, int defStyle) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.block_real_estate, this);
  }

  @Override
  public void setInformation(InformationRecord information) {
    mRealEstateInformation = (RealEstateInformation) information;
    initView();
  }
  
  @Override
  public void setContentButtons(Activity activity) {
    
  }

  private void initView() {
    TextView price = (TextView) findViewById(R.id.price);
    TextView propertyType = (TextView) findViewById(R.id.property_type);
    TextView bedrooms = (TextView) findViewById(R.id.bedrooms);
    TextView bathrooms = (TextView) findViewById(R.id.bathrooms);
    TextView sqft = (TextView) findViewById(R.id.sqft);
    TextView lotSqft = (TextView) findViewById(R.id.lot_sqft);
    TextView year = (TextView) findViewById(R.id.year);
    
    String chompedPrice = mRealEstateInformation.getPrice().substring(0, mRealEstateInformation.getPrice().length() - 2);
    int priceAsInt = Integer.parseInt(chompedPrice);
    String priceWithCommas = NumberFormat.getNumberInstance(Locale.US).format(priceAsInt);
    
    price.setText("$"+priceWithCommas);
    propertyType.setText(mRealEstateInformation.getPropertyType());
    bedrooms.setText(mRealEstateInformation.getBedrooms());
    bathrooms.setText(mRealEstateInformation.getBathrooms());
    sqft.setText(mRealEstateInformation.getSize());
    lotSqft.setText(mRealEstateInformation.getLotSize());
    year.setText(mRealEstateInformation.getYearBuilt());
  }
}
