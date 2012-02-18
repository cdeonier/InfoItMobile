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
    final Drawable image = ImageUtil.getImage(mImageUrl);
    final ImageView displayImage = (ImageView) mActivity.findViewById(R.id.photo);
     
    mActivity.runOnUiThread(new Runnable() {    
      @Override
      public void run() {
        displayImage.setImageDrawable(image);
        PhotoGallery photoGallery = (PhotoGallery) mActivity;
        photoGallery.getProgressDialog().dismiss();
      }
    });
    
    return image;
  }

}
