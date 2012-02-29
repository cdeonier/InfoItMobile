package com.infoit.widgetBlocks;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.main.R;
import com.infoit.reader.record.AgentInformation;
import com.infoit.reader.record.InformationRecord;
import com.infoit.util.ImageUtil;

public class AgentView extends LinearLayout implements BaseInformationView {
  private AgentInformation mAgentInformation;

  public AgentView(Context context) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.block_agent, this);
  }
  
  public AgentView(Context context, AttributeSet attrs, int defStyle) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.block_agent, this);
  }

  public AgentView(Context context, AttributeSet attrs) {
    super(context, attrs);
    LayoutInflater.from(context).inflate(R.layout.block_agent, this);
  }

  @Override
  public void setInformation(InformationRecord information) {
    mAgentInformation = (AgentInformation) information;
    initView();
  }
  
  @Override
  public void setContentButtons(Activity activity) {
    
    ImageView contactAgentButton = (ImageView) findViewById(R.id.contact_agent_button);
    ImageView agentDetailsButton = (ImageView) findViewById(R.id.agent_details_button);
    
    contactAgentButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        String url = "tel:" + mAgentInformation.getPhone().replaceAll("[\\s\\-()]", "");
        Intent intent = new Intent(Intent.ACTION_CALL, Uri.parse(url));
        v.getContext().startActivity(intent);
      }
    });

    agentDetailsButton.setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        String url = mAgentInformation.getUrl();
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        v.getContext().startActivity(intent);
      }
    });
  }
  
  private void initView() {
    TextView agentName = (TextView) findViewById(R.id.agent_name);
    TextView agentPosition = (TextView) findViewById(R.id.agent_position);
    TextView agentPhone = (TextView) findViewById(R.id.agent_phone);
    ImageView agentThumbnail = (ImageView) findViewById(R.id.agent_thumbnail);
    
    agentName.setText(mAgentInformation.getName());
    if(mAgentInformation.getAgency().equals("")){
      agentPosition.setText(mAgentInformation.getPosition());
    } else {
      agentPosition.setText(mAgentInformation.getPosition() + " at " + mAgentInformation.getAgency());
    }
    
    agentPhone.setText(mAgentInformation.getPhone());
    
    Drawable image = ImageUtil.getImage(mAgentInformation.getThumbnailUrl());
    agentThumbnail.setImageDrawable(image);
    
  }
}
