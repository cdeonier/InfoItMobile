package com.infoit.async;

import org.codehaus.jackson.JsonNode;

import android.os.AsyncTask;

import com.infoit.reader.service.WebServiceAdapter;

public class LoadInformation extends AsyncTask<Integer, Void, Void> {

  @Override
  protected Void doInBackground(Integer... params) {
    int locationIdentifier = params[0].intValue();
    
    JsonNode webServiceResponse = WebServiceAdapter.getInformationAsJson(locationIdentifier);
    
    if("place".equals(WebServiceAdapter.getEntityType(webServiceResponse))){
      if("Real Estate Property".equals(WebServiceAdapter.getEntitySubType(webServiceResponse))){
        
      }
    }
    
    return null;
  }

}
