package com.infoit.async;

import java.lang.ref.WeakReference;

import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

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
		//params[0] is the image url
	    Drawable image = ImageUtil.getImage(params[0]);
	    
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
