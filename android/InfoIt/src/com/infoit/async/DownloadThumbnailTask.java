package com.infoit.async;

import java.lang.ref.WeakReference;

import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.infoit.util.ImageUtil;

public class DownloadThumbnailTask extends AsyncTask<String, Void, Drawable> {
	private final WeakReference<ImageView> imageViewReference;
	private final WeakReference<ProgressBar> progressBarReference;
	private final WeakReference<Drawable[]> thumbnailsReference;
	private final int thumbnailPosition;

	public DownloadThumbnailTask(ImageView imageView, ProgressBar progressBar, Drawable[] thumbnails, int position) {
		imageViewReference = new WeakReference<ImageView>(imageView);
		progressBarReference = new WeakReference<ProgressBar>(progressBar);
		thumbnailsReference = new WeakReference<Drawable[]>(thumbnails);
		thumbnailPosition = position;
	}

	@Override
	protected Drawable doInBackground(String... params) {
		Drawable image = null;
		image = ImageUtil.getImage(params[0]);
		Drawable[] thumbnails = thumbnailsReference.get();
		thumbnails[thumbnailPosition] = image;
		return image;
	}

	@Override
	protected void onPostExecute(Drawable result) {
		if (imageViewReference != null) {
			ProgressBar progressBarView = progressBarReference.get();
			progressBarView.setVisibility(View.GONE);

			ImageView imageView = imageViewReference.get();
			
			//Check to see if there is already an existing drawable; Gingerbread bug seems
			//to overwrite image for row even if populated for no thumbnail case.
			if (imageView != null && imageView.getDrawable() == null) {
				imageView.setImageDrawable(result);
			}
		}
	}

}
