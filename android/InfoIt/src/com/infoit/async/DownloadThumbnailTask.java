package com.infoit.async;

import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.infoit.util.ImageUtil;

public class DownloadThumbnailTask extends AsyncTask<String, Void, Drawable> {
	private final ImageView mImageView;
	private final ProgressBar mProgressBar;
	private final Drawable[] mThumbnails;
	private final int thumbnailPosition;
	private String mUrl;

	public DownloadThumbnailTask(ImageView imageView, ProgressBar progressBar, Drawable[] thumbnails, int position) {
		mImageView = imageView;
		mProgressBar = progressBar;
		mThumbnails = thumbnails;
		thumbnailPosition = position;
	}

	@Override
	protected Drawable doInBackground(String... params) {
		mUrl = params[0];
		Drawable image = null;
		image = ImageUtil.getImage(params[0]);
		mThumbnails[thumbnailPosition] = image;
		return image;
	}

	@Override
	protected void onPostExecute(Drawable result) {
		if (mImageView != null) {
			mProgressBar.setVisibility(View.INVISIBLE);
			
			DownloadThumbnailTask thumbnailTask = ImageUtil.getDownloadThumbnailTask(mImageView);
			if (this == thumbnailTask) {
				mImageView.setImageDrawable(result);
			}
		}
	}

	public String getUrl() {
		return mUrl;
	}
}
