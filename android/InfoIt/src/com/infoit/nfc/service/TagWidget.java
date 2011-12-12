package com.infoit.nfc.service;

public class TagWidget {
	private String mContextUrl;
	private String mApplicationUrl;
	
	public TagWidget(String contextUrl, String applicationUrl){
		this.mContextUrl = contextUrl;
		this.mApplicationUrl = applicationUrl;
	}
	
	public String getmContextUrl() {
		return mContextUrl;
	}
	public void setmContextUrl(String mContextUrl) {
		this.mContextUrl = mContextUrl;
	}
	public String getmApplicationUrl() {
		return mApplicationUrl;
	}
	public void setmApplicationUrl(String mApplicationUrl) {
		this.mApplicationUrl = mApplicationUrl;
	}
	
	
}
