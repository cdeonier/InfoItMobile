package com.infoit.widgetBlocks;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.infoit.main.R;
import com.infoit.reader.record.InformationRecord;
import com.infoit.reader.record.AgentInformation;

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
  
  private void initView() {
    TextView agentName = (TextView) findViewById(R.id.agent_name);
    TextView agentPosition = (TextView) findViewById(R.id.agent_position);
    TextView agentPhone = (TextView) findViewById(R.id.agent_phone);
    
    agentName.setText(mAgentInformation.getName());
    if(mAgentInformation.getAgency().equals("")){
      agentPosition.setText(mAgentInformation.getPosition());
    } else {
      agentPosition.setText(mAgentInformation.getPosition() + " at " + mAgentInformation.getAgency());
    }
    
    agentPhone.setText(mAgentInformation.getPhone());
  }
}
