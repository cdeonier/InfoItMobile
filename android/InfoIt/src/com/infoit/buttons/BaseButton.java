package com.infoit.buttons;

import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.TextView;

public class BaseButton {
	private int mButtonIconId;
	private String mButtonText;
	private OnClickListener mOnClickListener;
	private ImageView mImageView;
	private TextView mTextView;
	private ImageView mActionImageView;
	private TextView mActionTextView;

	public BaseButton(int buttonIconId, String buttonText) {
		mButtonIconId = buttonIconId;
		mButtonText = buttonText;
	}

	public int getButtonIconId() {
		return mButtonIconId;
	}

	public void setButtonIconId(int buttonIconId) {
		mButtonIconId = buttonIconId;
	}

	public String getButtonText() {
		return mButtonText;
	}

	public void setButtonText(String buttonText) {
		mButtonText = buttonText;
	}

	public OnClickListener getOnClickListener() {
		return mOnClickListener;
	}

	public void setOnClickListener(OnClickListener clickListener) {
		mOnClickListener = clickListener;
	}

	public ImageView getActionImageView() {
		return mActionImageView;
	}

	public void setActionImageView(ImageView imageView) {
		mActionImageView = imageView;
	}

	public TextView getActionTextView() {
		return mActionTextView;
	}

	public void setActionTextView(TextView textView) {
		mActionTextView = textView;
	}
	
	public ImageView getImageView() {
		return mImageView;
	}

	public void setImageView(ImageView imageView) {
		mImageView = imageView;
	}

	public TextView getTextView() {
		return mTextView;
	}

	public void setTextView(TextView textView) {
		mTextView = textView;
	}
}
