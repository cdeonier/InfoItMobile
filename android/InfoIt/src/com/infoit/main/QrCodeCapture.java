package com.infoit.main;

import java.io.IOException;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.Window;
import android.view.WindowManager;

import com.google.zxing.Result;
import com.infoit.qrcode.BeepManager;
import com.infoit.qrcode.CameraManager;
import com.infoit.qrcode.QrCodeCaptureHandler;
import com.infoit.qrcode.ViewfinderView;

public final class QrCodeCapture extends Activity implements SurfaceHolder.Callback {
  
  private static final String TAG = QrCodeCapture.class.getSimpleName();
  
  private boolean hasSurface;
  private QrCodeCaptureHandler handler;
  private ViewfinderView viewfinderView;
  private BeepManager beepManager;
  @SuppressWarnings("unused")
  private Result lastResult;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    //android.os.Debug.waitForDebugger();
    
    super.onCreate(savedInstanceState);
    
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    
    Window window = getWindow();
    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    
    setContentView(R.layout.qr_code_capture);
    
    CameraManager.init(getApplication());
    
    viewfinderView = (ViewfinderView) findViewById(R.id.viewfinder_view);
    beepManager = new BeepManager(this);
  }

  @Override
  protected void onResume() {
    super.onResume();
    
    SurfaceView surfaceView = (SurfaceView) findViewById(R.id.preview_view);
    SurfaceHolder surfaceHolder = surfaceView.getHolder();

    surfaceHolder.addCallback(this);
    surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
  }
  
  @Override
  protected void onPause() {
    super.onPause();
    if (handler != null) {
      handler.quitSynchronously();
      handler = null;
    }
    CameraManager.get().closeDriver();
  }

  @Override
  public void surfaceCreated(SurfaceHolder holder) {
    if (!hasSurface) {
      hasSurface = true;
      initCamera(holder);
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
        /* InfoIt: This originally from ZXing; passing nulls checks all formats */
        //handler = new QrCodeCaptureHandler(this, decodeFormats, characterSet);
        handler = new QrCodeCaptureHandler(this, null, null);
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
   * A valid barcode has been found, so give an indication of success and show the results.
   *
   * @param rawResult The contents of the barcode.
   * @param barcode   A greyscale bitmap of the camera data which was decoded.
   */
  public void handleDecode(Result rawResult, Bitmap barcode) {
    Log.w("handleDecode", "start method");
    beepManager.playBeepSoundAndVibrate();
  }
}
