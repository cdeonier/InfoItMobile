package com.infoit.nfc.animation;

import android.view.animation.Animation;
import android.widget.RelativeLayout;

public final class DisplayNextView implements Animation.AnimationListener {
	private boolean mCurrentView;
	RelativeLayout view1;
	RelativeLayout view2;

	public DisplayNextView(boolean currentView, RelativeLayout view1,
			RelativeLayout view2) {
		mCurrentView = currentView;
		this.view1 = view1;
		this.view2 = view2;
	}

	public void onAnimationStart(Animation animation) {
	}

	public void onAnimationEnd(Animation animation) {
		view1.post(new SwapViews(mCurrentView, view1, view2));
	}

	public void onAnimationRepeat(Animation animation) {
	}
}