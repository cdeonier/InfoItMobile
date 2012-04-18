package com.infoit.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.infoit.async.DownloadThumbnailTask;
import com.infoit.async.TaskTrackerRunnable;
import com.infoit.main.BaseApplication;
import com.infoit.main.R;

public class ImageUtil {
	public static Drawable getImage(String url) {
		try {
			Activity currentActivity = BaseApplication.getCurrentActivity();
			Drawable d;
			if (CacheUtil.imageExists(currentActivity, url)) {
				d = CacheUtil.getImage(currentActivity, url);
			} else {
				InputStream is = (InputStream) fetch(url);
				d = Drawable.createFromStream(is, "src");
				CacheUtil.saveImage(currentActivity, d, url);
			}
			return d;
		} catch (MalformedURLException e) {
			e.printStackTrace();
			return null;
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
	}

	public static Drawable getProfileImage(String url, View view) {
		if (url != null) {
			try {
				Drawable d = null;
				
				if (CacheUtil.imageExists((Activity) view.getContext(), url)) {
					d = CacheUtil.getImage((Activity) view.getContext(), url);
				} else {
					InputStream is = (InputStream) fetch(url);
					d = Drawable.createFromStream(is, "src");
					CacheUtil.saveImage((Activity) view.getContext(), d, url);
				}
				
				return d;
			} catch (MalformedURLException e) {
				e.printStackTrace();
				return null;
			} catch (IOException e) {
				e.printStackTrace();
				return null;
			}
		} else {
			return view.getResources().getDrawable(R.drawable.basic_no_image);
		}
	}

	public static Object fetch(String address) throws MalformedURLException, IOException {
		URL url = new URL(address);
		Object content = url.getContent();
		return content;
	}
	
	public static void downloadThumbnail(String url, ImageView imageView, ProgressBar progressBar, Drawable[] thumbnails, int position) {
		if (cancelPotentialThumbnailDownload(url, imageView)) {
			DownloadThumbnailTask thumbnailTask = 
					new DownloadThumbnailTask(imageView, progressBar, thumbnails, position);
			DownloadedThumbnailDrawable downloadedDrawable = new DownloadedThumbnailDrawable(thumbnailTask);
			imageView.setImageDrawable(downloadedDrawable);
			thumbnailTask.execute(url);
			Handler handler = new Handler();
	    handler.postDelayed(new TaskTrackerRunnable(thumbnailTask), 20000);
		}
	}
	
	private static boolean cancelPotentialThumbnailDownload(String url, ImageView imageView) {
		DownloadThumbnailTask thumbnailTask = getDownloadThumbnailTask(imageView);
		
		if (thumbnailTask != null) {
			String thumbnailUrl = thumbnailTask.getUrl();
			if (thumbnailUrl == null || !thumbnailUrl.equals(url)) {
				thumbnailTask.cancel(true);
			} else {
				return false;
			}
		}
		return true;
	}
	
	public static DownloadThumbnailTask getDownloadThumbnailTask(ImageView imageView) {
		if (imageView != null) {
			Drawable drawable = imageView.getDrawable();
			if (drawable instanceof DownloadedThumbnailDrawable) {
				DownloadedThumbnailDrawable downloadedDrawable = (DownloadedThumbnailDrawable) drawable;
				return downloadedDrawable.getDownloadThumbnailTask();
			}
		}
		return null;
	}
	
	private static class DownloadedThumbnailDrawable extends ColorDrawable {
		private final DownloadThumbnailTask mTask;

		public DownloadedThumbnailDrawable(DownloadThumbnailTask thumbnailTask) {
			super(Color.WHITE);
			mTask = thumbnailTask;
		}

		public DownloadThumbnailTask getDownloadThumbnailTask() {
			return mTask;
		}
	}
}
