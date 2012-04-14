package com.infoit.async;

import android.app.Activity;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.widget.ImageView;

import com.infoit.main.PhotoGallery;
import com.infoit.main.R;
import com.infoit.util.ImageUtil;

public class DownloadImageTask extends AsyncTask<Void, Void, Drawable> {
	private String mImageUrl;
	private Activity mActivity;

	public DownloadImageTask(Activity activity, String imageUrl) {
		mImageUrl = imageUrl;
		mActivity = activity;
	}

	@Override
	protected Drawable doInBackground(Void... params) {
		Drawable image = null;
		if (mImageUrl != null && !mImageUrl.equals("")) {
			image = ImageUtil.getImage(mImageUrl);
		} else {
			image = mActivity.getResources().getDrawable(R.drawable.basic_no_image);
		}

		return image;
	}

	@Override
	protected void onPostExecute(Drawable result) {
		// TODO Auto-generated method stub
		super.onPostExecute(result);
		final ImageView displayImage = (ImageView) mActivity.findViewById(R.id.photo);
		displayImage.setImageDrawable(result);
		PhotoGallery photoGallery = (PhotoGallery) mActivity;
		photoGallery.getImages().add(result);
		photoGallery.getProgressDialog().dismiss();

	}

}
