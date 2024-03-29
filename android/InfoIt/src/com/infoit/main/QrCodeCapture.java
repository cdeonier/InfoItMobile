package com.infoit.main;

import java.io.IOException;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.google.android.apps.analytics.easytracking.TrackedActivity;
import com.google.zxing.Result;
import com.infoit.constants.Constants;
import com.infoit.qrcode.BeepManager;
import com.infoit.qrcode.CameraManager;
import com.infoit.qrcode.QrCodeCaptureHandler;
import com.infoit.qrcode.ViewfinderView;

public final class QrCodeCapture extends TrackedActivity implements SurfaceHolder.Callback {
  
  private static final String TAG = QrCodeCapture.class.getSimpleName();
  
  private boolean hasSurface;
  private QrCodeCaptureHandler handler;
  private ViewfinderView viewfinderView;
  private BeepManager beepManager;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    
    super.onCreate(savedInstanceState);
    
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
    
    Window window = getWindow();
    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
  }

  @Override
  protected void onResume() {
    super.onResume();
    
    setContentView(R.layout.qr_code_capture);
    
    CameraManager.init(this);
    
    viewfinderView = (ViewfinderView) findViewById(R.id.viewfinder_view);
    
    SurfaceView surfaceView = (SurfaceView) findViewById(R.id.preview_view);
    SurfaceHolder surfaceHolder = surfaceView.getHolder();

    surfaceHolder.addCallback(this);
    surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
    
    beepManager = new BeepManager(this);
  }
  

  
  @Override
  protected void onPause() {
    super.onPause();
    if (handler != null) {
      handler.quitSynchronously();
      handler = null;
    }
    CameraManager.get().closeDriver();
    
    FrameLayout container = (FrameLayout) findViewById(R.id.qr_code_capture_container);
    unbindDrawables(container);
    System.gc();
  }

  @Override
  public void surfaceCreated(SurfaceHolder holder) {
    if (!hasSurface) {
      hasSurface = true;
      initCamera(holder);
    }
  }
  
  private void unbindDrawables(View view) {
    if (view.getBackground() != null) {
      view.getBackground().setCallback(null);
    }
    if (view instanceof ViewGroup) {
      for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
        unbindDrawables(((ViewGroup) view).getChildAt(i));
      }
      ((ViewGroup) view).removeAllViews();
    }
  }

  @Override
  public void surfaceDestroyed(SurfaceHolder holder) {
    hasSurface = false;
  }

  @Override
  public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

  }
  
  public ViewfinderView getViewfinderView() {
    return viewfinderView;
  }

  public Handler getHandler() {
    return handler;
  }
  
  private void initCamera(SurfaceHolder surfaceHolder) {
    try {
      CameraManager.get().openDriver(surfaceHolder);
      // Creating the handler starts the preview, which can also throw a RuntimeException.
      if (handler == null) {
        handler = new QrCodeCaptureHandler(this);
      }
    } catch (IOException ioe) {
      Log.w(TAG, ioe);
    } catch (RuntimeException e) {
      // Barcode Scanner has seen crashes in the wild of this variety:
      // java.?lang.?RuntimeException: Fail to connect to camera service
      Log.w(TAG, "Unexpected error initializating camera", e);
    }
  }

  public void drawViewfinder() {
    viewfinderView.drawViewfinder();
  }
  
  /**
   * A valid QR has been found, so give an indication of success and show the results.
   *
   * @param rawResult The contents of the barcode.
   * @param barcode   A greyscale bitmap of the camera data which was decoded.
   */
  public void handleDecode(Result rawResult) {
    Log.w("InfoIt", "Scanned QR Code");
    if (rawResult.getText().contains("www.getinfoit.com")) {
      if (rawResult.getText().contains("services")) {
	      int identifier = Integer.parseInt(rawResult.getText().split("/services/")[1]);
	      beepManager.playBeepSoundAndVibrate();
	      
	      Intent displayInfoIntent = new Intent(BaseApplication.getCurrentActivity(), DisplayInfo.class);
	      displayInfoIntent.setAction(Constants.QRCODE);
	      displayInfoIntent.putExtra("identifier", identifier);
	      BaseApplication.getCurrentActivity().startActivity(displayInfoIntent);
	      finish();
      } else if (rawResult.getText().contains("menus")) {
    	  int identifier = Integer.parseInt(rawResult.getText().split("/menus/")[1]);
	      Intent displayMenuIntent = new Intent(BaseApplication.getCurrentActivity(), DisplayMenu.class);
	      displayMenuIntent.setAction(Constants.QRCODE);
	      displayMenuIntent.putExtra("identifier", identifier);
	      BaseApplication.getCurrentActivity().startActivity(displayMenuIntent);
	      finish();
      }
    } else {
      String url = rawResult.getText();
      Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
      this.startActivity(intent);
    }
  }
}
