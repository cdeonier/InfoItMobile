package com.infoit.ui;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.view.MotionEvent;
import android.view.View;

import com.infoit.main.R;

public class CapturePhotoView extends View {
	private Paint mPaint;
	private int mMaskColor;
	private int mFrameColor;
	private float mDensity;
	private int mWidth, mHeight;
	private Drawable mResizeIcon;
	
	private final int THUMBNAIL_SIZE = 200;
	
	private float left, top, right, bottom;
	private int iconLeft, iconTop, iconRight, iconBottom;
	
	private boolean boxInteraction, resizeInteraction;
	private float lastTouchX, lastTouchY;
	
	public CapturePhotoView(Context context, int width, int height) {
		super(context);
		
		Resources resources = getResources();
//		mWidth = resources.getDisplayMetrics().widthPixels;
//		mHeight = resources.getDisplayMetrics().heightPixels;
		
		mWidth = width;
		mHeight = height;
		
		mPaint = new Paint();
		mMaskColor = resources.getColor(R.color.mask);
		mFrameColor = resources.getColor(R.color.frame);
		mDensity = resources.getDisplayMetrics().density;
		
		left = mWidth / 2 - THUMBNAIL_SIZE / 2 * mDensity;
		top = mHeight / 2 - THUMBNAIL_SIZE / 2 * mDensity;
		right = mWidth / 2 + THUMBNAIL_SIZE / 2 * mDensity;
		bottom = mHeight / 2 + THUMBNAIL_SIZE / 2 * mDensity;
		
		mResizeIcon = resources.getDrawable(R.drawable.photo_capture_expand_icon);
		iconLeft = (int) right - mResizeIcon.getIntrinsicWidth();
		iconTop = (int) bottom - mResizeIcon.getIntrinsicHeight();
		iconRight = (int) right;
		iconBottom = (int) bottom;
		mResizeIcon.setBounds(iconLeft, iconTop, iconRight, iconBottom);
		
		boxInteraction = false;
		resizeInteraction = false;
	}
	
	@Override
	public void onDraw(Canvas canvas) {
		int width = canvas.getWidth();
		int height = canvas.getHeight();
		
		//View port
		mPaint.setColor(mMaskColor);
    canvas.drawRect(0, 0, (int) width, (int) top, mPaint);
    canvas.drawRect(0, (int) bottom, width, (int) height, mPaint);
    canvas.drawRect(0, (int) top, (int) left, (int) bottom, mPaint);
    canvas.drawRect((int) right, (int) top, (int) width, (int) bottom, mPaint);
    
    //Frame
    mPaint.setColor(mFrameColor);
    canvas.drawRect((int) (left-2), (int) (top-2), (int) (right+2), (int) top, mPaint);
    canvas.drawRect((int) (left-2), (int) (bottom+2), (int) (right+2), (int) (bottom), mPaint);
    canvas.drawRect((int) (left-2), (int) top, (int) left, (int) bottom, mPaint);
    canvas.drawRect((int) right, (int) top, (int) (right+2), (int) bottom, mPaint);
    
		iconLeft = (int) right - mResizeIcon.getIntrinsicWidth();
		iconTop = (int) bottom - mResizeIcon.getIntrinsicHeight();
		iconRight = (int) right;
		iconBottom = (int) bottom;
    mResizeIcon.setBounds(iconLeft, iconTop, iconRight, iconBottom);
    mResizeIcon.draw(canvas);
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		final float x = event.getX();
		final float y = event.getY();
		
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			if (x < right && x > left && y < bottom && y > top) {
				boxInteraction = true;
				lastTouchX = x;
				lastTouchY = y;
			}
			
			if (x < right && x > right - mResizeIcon.getIntrinsicWidth() &&
					y < bottom && y > bottom - mResizeIcon.getIntrinsicHeight()) {
				boxInteraction = false;
				resizeInteraction = true;
				lastTouchX = x;
				lastTouchY = y;
			}
			break;
		case MotionEvent.ACTION_UP:
			boxInteraction = false;
			resizeInteraction = false;
			break;
		case MotionEvent.ACTION_MOVE:
			if (boxInteraction) {
				final float dx = x - lastTouchX;
				final float dy = y - lastTouchY;
				
				if (left + dx < 0) {
					right = right - left;
					left = 0;
				} else if (right + dx > mWidth) {
					left = left + (mWidth - right);
					right = mWidth;
				} else {
					left += dx;
					right += dx;
				}
				
				if (top + dy < 0) {
					bottom = bottom - top;
					top = 0;
				} else if (bottom + dy > mHeight) {
					top = top + (mHeight - bottom);
					bottom = mHeight;
				} else {
					top += dy;
					bottom += dy;
				}
				
				lastTouchX = x;
				lastTouchY = y;
				
				invalidate();
			} else if (resizeInteraction) {
			//Divide by two since box seems to float ahead if we don't
				final float dx = x - lastTouchX;
				final float dy = y - lastTouchY;
				
				float dxy = Math.max(dx, dy);
				
				if ((right - left) + dxy > THUMBNAIL_SIZE && right + dxy < mWidth && bottom + dxy < mHeight) {
					right += dxy;
					bottom += dxy;
				} 
				
				lastTouchX = x;
				lastTouchY = y;
				
				invalidate();
			}
			
			
			break;
		}

		return true;
	}

	public float getThumbnailLeft() {
		return left;
	}
	
	public float getThumbnailRight() {
		return right;
	}
	
	public float getThumbnailTop() {
		return top;
	}
	
	public float getThumbnailBottom() {
		return bottom;
	}
}
