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

	public DownloadThumbnailTask(ImageView imageView, ProgressBar progressBar, Drawable[] thumbnails, int position) {
		mImageView = imageView;
		mProgressBar = progressBar;
		mThumbnails = thumbnails;
		thumbnailPosition = position;
	}

	@Override
	protected Drawable doInBackground(String... params) {
		Drawable image = null;
		image = ImageUtil.getImage(params[0]);
		mThumbnails[thumbnailPosition] = image;
		return image;
	}

	@Override
	protected void onPostExecute(Drawable result) {
		if (mImageView != null) {
			mProgressBar.setVisibility(View.INVISIBLE);
			
			//Check to see if there is already an existing drawable; Gingerbread bug seems
			//to overwrite image for row even if populated for no thumbnail case.
			if (mImageView != null && mImageView.getDrawable() == null) {
				mImageView.setImageDrawable(result);
			}
		}
	}

}
