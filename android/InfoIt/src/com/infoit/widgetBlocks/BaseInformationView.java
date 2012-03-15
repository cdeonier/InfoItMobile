package com.infoit.widgetBlocks;

import android.app.Activity;

import com.infoit.record.InformationRecord;

public interface BaseInformationView {
  public void setInformation(InformationRecord information);
  public void setContentButtons(Activity activity);
}
