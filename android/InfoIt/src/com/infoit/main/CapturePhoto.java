package com.infoit.main;

import java.io.File;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;
import android.widget.ImageView;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.infoit.ui.CapturePhotoView;

public class CapturePhoto extends TrackedActivity {
	private static final int CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE = 100;
	private Bitmap bitmap;
	private int mIdentifier;
	private CapturePhotoView cpv;

	@Override
	protected void onCreate(Bundle bundle) {
		super.onCreate(bundle);

		setContentView(R.layout.capture_photo);
		initializeButtons();
		
		final Object data = getLastNonConfigurationInstance();
		if (data == null) {
			mIdentifier = getIntent().getExtras().getInt("identifier");
			Intent cameraIntent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
			Uri fileUri = getFileUri();
			cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri);
			startActivityForResult(cameraIntent, CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE);
		} else {
			mIdentifier = (Integer) ((Object[]) data)[0];
			bitmap = (Bitmap) ((Object[])data)[1];
			ImageView imageView = (ImageView) findViewById(R.id.captured_photo);
			imageView.setImageBitmap(bitmap);
			addCapturePhotoView();
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onPause() {
		super.onPause();
		unbindDrawables(getWindow().getDecorView().findViewById(R.id.captured_photo));
		System.gc();
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
		System.gc();
	}

	@Override
	public Object onRetainNonConfigurationInstance() {
		final Object[] data = new Object[2];
		final Bitmap savedBitmap = bitmap;
		final int identifier = mIdentifier;
		data[0] = identifier;
		data[1] = savedBitmap;
		return data;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE) {
			if (resultCode == Activity.RESULT_OK) {
				Uri selectedImage = getFileUri();
				getContentResolver().notifyChange(selectedImage, null);

				ImageView imageView = (ImageView) findViewById(R.id.captured_photo);
				ContentResolver cr = getContentResolver();
				try {
					bitmap = android.provider.MediaStore.Images.Media.getBitmap(cr, selectedImage);
					imageView.setImageBitmap(bitmap);
					addCapturePhotoView();
				} catch (Exception e) {
					Log.e("Camera", e.toString());
				}

			}
		}
	}

	/** Create a file Uri for saving an image or video */
	private static Uri getFileUri() {
		return Uri.fromFile(getFile());
	}

	/** Create a File for saving an image or video */
	private static File getFile() {
		File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
				"InfoIt");

		// Create the storage directory if it does not exist
		if (!mediaStorageDir.exists()) {
			if (!mediaStorageDir.mkdirs()) {
				Log.d("InfoIt", "failed to create directory");
				return null;
			}
		}

		File mediaFile;
		mediaFile = new File(mediaStorageDir.getPath() + File.separator + "capturedImage" + ".jpg");

		return mediaFile;
	}

	private void unbindDrawables(View view) {
		if (view.getBackground() != null) {
			view.getBackground().setCallback(null);
		}
		if (view instanceof ViewGroup && !(view instanceof AdapterView)) {
			for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
				unbindDrawables(((ViewGroup) view).getChildAt(i));
			}
			((ViewGroup) view).removeAllViews();
		}
	}

	private void rotateBitmap() {
		Matrix matrix = new Matrix();
		matrix.postRotate(90);

		Bitmap rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
		ImageView imageView = (ImageView) findViewById(R.id.captured_photo);
		unbindDrawables(imageView);
		imageView.setImageBitmap(rotatedBitmap);
		bitmap.recycle();
		System.gc();
		bitmap = rotatedBitmap;

		FrameLayout container = (FrameLayout) findViewById(R.id.photo_capture_container);
		container.removeViewAt(1);
		addCapturePhotoView();
	}

	private void addCapturePhotoView() {
		FrameLayout container = (FrameLayout) findViewById(R.id.photo_capture_container);

		int bmHeight = bitmap.getHeight();
		int bmWidth = bitmap.getWidth();

		Display display = getWindowManager().getDefaultDisplay();
		int height = display.getHeight();
		int width = display.getWidth();

		int scaledHeight, scaledWidth;
		if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
			float ratio = (float) bmWidth / (float) bmHeight;
			scaledHeight = height;
			scaledWidth = (int) (ratio * height);
		} else {
			float ratio = (float) bmHeight / (float) bmWidth;
			scaledHeight = (int) (ratio * width);
			scaledWidth = width;
		}

		cpv = new CapturePhotoView(this, scaledWidth, scaledHeight);
		LayoutParams params = new LayoutParams(scaledWidth, scaledHeight);
		params.gravity = Gravity.CENTER;
		cpv.setLayoutParams(params);
		container.addView(cpv, 1);
	}
	
	private void cropPhoto() {
		int thumbnailWidth = (int) (cpv.getThumbnailRight() - cpv.getThumbnailLeft());
		int thumbnailHeight = (int) (cpv.getThumbnailBottom() - cpv.getThumbnailTop());
		int thumbnailLeft = (int) (cpv.getThumbnailLeft());
		int thumbnailTop = (int) (cpv.getThumbnailTop());
		
		float ratio = (float) thumbnailTop / (float) cpv.getHeight();
		int top = (int) (bitmap.getHeight() * ratio);
		ratio = (float) thumbnailLeft / (float) cpv.getWidth();
		int left = (int) (bitmap.getWidth() * ratio);
		ratio = (float) thumbnailHeight / (float) cpv.getHeight();
		int height = (int) (bitmap.getHeight() * ratio);
		ratio = (float) thumbnailWidth / (float) cpv.getWidth();
		int width = (int) (bitmap.getWidth() * ratio);
		
		Bitmap cropped = Bitmap.createBitmap(bitmap, left, top, width, height);
		
		ImageView imageView = (ImageView) findViewById(R.id.captured_photo);
		imageView.setImageBitmap(cropped);
	}
	
	private void initializeButtons() {
		Button rotateButton = (Button) findViewById(R.id.capture_rotate);
		rotateButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				rotateBitmap();
			}
		});
		
		Button saveButton = (Button) findViewById(R.id.capture_save);
		saveButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				cropPhoto();
			}
		});
	}
}
