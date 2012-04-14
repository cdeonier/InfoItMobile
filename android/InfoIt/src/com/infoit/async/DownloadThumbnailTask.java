package com.infoit.async;

import java.lang.ref.WeakReference;

import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.infoit.main.R;
import com.infoit.util.ImageUtil;

public class DownloadThumbnailTask  extends AsyncTask<String, Void, Drawable> {
	private final WeakReference<ImageView> imageViewReference;
	private final WeakReference<ProgressBar> progressBarReference;
	
	public DownloadThumbnailTask(ImageView imageView, ProgressBar progressBar) {
		imageViewReference = new WeakReference<ImageView>(imageView);
		progressBarReference = new WeakReference<ProgressBar>(progressBar);
	}

	@Override
	protected Drawable doInBackground(String... params) { 
			Drawable image = null;
			if (params[0] != null && !params[0].equals("")) {
				image = ImageUtil.getImage(params[0]);
			} else {
				image = imageViewReference.get().getResources().getDrawable(R.drawable.basic_no_thumbnail);
			}

			return image;
	}

	@Override
	protected void onPostExecute(Drawable result) {
        if (imageViewReference != null) {
            ImageView imageView = imageViewReference.get();
            if (imageView != null) {
                imageView.setImageDrawable(result);
                ProgressBar progressBarView = progressBarReference.get();
                progressBarView.setVisibility(View.GONE);
            }
        }
	}

}
