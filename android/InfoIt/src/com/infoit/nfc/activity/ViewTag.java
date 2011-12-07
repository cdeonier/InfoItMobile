package com.infoit.nfc.activity;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.animation.AccelerateInterpolator;
import android.widget.RelativeLayout;

import com.infoit.animation.DisplayNextView;
import com.infoit.animation.Flip3dAnimation;

public class ViewTag extends Activity {
	static final String TAG = "ViewTag";
	
	private RelativeLayout yelpFront;
	private RelativeLayout yelpBack;
	private RelativeLayout foursquareFront;
	private RelativeLayout foursquareBack;
	
	private boolean isYelpFrontUp = true;
	private boolean isFoursquareFrontUp = true;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.view_tag);
        setupYelpButton();
        setupFoursquareButton();
    }
    
    private void setupYelpButton(){
		yelpFront = (RelativeLayout) findViewById(R.id.yelp_front);
		yelpBack = (RelativeLayout) findViewById(R.id.yelp_back);
		yelpBack.setVisibility(View.GONE);

		yelpFront.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				if (isYelpFrontUp) {
					applyRotation(0, 90, isYelpFrontUp, yelpFront, yelpBack);
					isYelpFrontUp = !isYelpFrontUp;

				} else {
					applyRotation(0, -90, isYelpFrontUp, yelpFront, yelpBack);
					isYelpFrontUp = !isYelpFrontUp;
				}
			}
		});
    }
    
    private void setupFoursquareButton(){
    	foursquareFront = (RelativeLayout) findViewById(R.id.foursquare_front);
    	foursquareBack = (RelativeLayout) findViewById(R.id.foursquare_back);
    	foursquareBack.setVisibility(View.GONE);

		foursquareFront.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				if (isFoursquareFrontUp) {
					applyRotation(0, 90, isFoursquareFrontUp, foursquareFront, foursquareBack);
					isFoursquareFrontUp = !isFoursquareFrontUp;

				} else {
					applyRotation(0, -90, isFoursquareFrontUp, foursquareFront, foursquareBack);
					isFoursquareFrontUp = !isFoursquareFrontUp;
				}
			}
		});
    }
    
	private void applyRotation(float start, float end, boolean isFrontUp, RelativeLayout frontView, RelativeLayout backView) {
		// Find the center of image
		final float centerX = frontView.getWidth() / 2.0f;
		final float centerY = frontView.getHeight() / 2.0f;

		// Create a new 3D rotation with the supplied parameter
		// The animation listener is used to trigger the next animation
		final Flip3dAnimation rotation = new Flip3dAnimation(start, end,
				centerX, centerY);
		rotation.setDuration(500);
		rotation.setFillAfter(true);
		rotation.setInterpolator(new AccelerateInterpolator());
		rotation.setAnimationListener(new DisplayNextView(isFrontUp, frontView, backView));

		if (isFrontUp) {
			frontView.startAnimation(rotation);
		} else {
			backView.startAnimation(rotation);
		}

	}

//	@Override
//	protected void onResume() {
//		super.onResume();
//		
//		if (NfcAdapter.ACTION_NDEF_DISCOVERED.equals(getIntent().getAction())) {
//			Parcelable[] rawMsgs = getIntent().getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
//			if (rawMsgs != null) {
//				NdefMessage tagMsg = (NdefMessage) rawMsgs[0];
//				NdefRecord tagRecord = tagMsg.getRecords()[0];
//				InfoItTag tag = InfoItTag.parse(tagRecord);
//				BigInteger locationIdentifier = tag.getLocationIdentifier();
//				InfoItServiceReturn serviceReturn = TagsWebServiceAdapter.getLocationInformation(locationIdentifier);
//				
//				setupBasicArea(serviceReturn);
//				setupYelpButton(serviceReturn);
//			}
//		}
//	}
	
//	private void setupYelpButton(InfoItServiceReturn serviceReturn){
//		String yelpIdentifier = serviceReturn.getmYelpIdentifier(); 
//        RelativeLayout yelpLayout = (RelativeLayout)findViewById(R.id.yelp_layout);
//        final String yelpID = yelpIdentifier;
//        yelpLayout.setOnClickListener(new View.OnClickListener() {
//			
//			@Override
//			public void onClick(View v) {
//				Uri uri = Uri.parse("http://www.yelp.com/biz/"+yelpID);
//				startActivity(new Intent(Intent.ACTION_VIEW, uri));
//			}
//		});
//	}
//	
//	private void setupBasicArea(InfoItServiceReturn serviceReturn){
//		ImageView imgView = (ImageView)findViewById(R.id.location_icon);
//		TextView locationName = (TextView)findViewById(R.id.location_name);
//        TextView locationUrl = (TextView)findViewById(R.id.location_url);
//        
//        setImageView(imgView, serviceReturn.getmLocationThumbnailUrl());
//        locationName.setText(serviceReturn.getmLocationName());
//        locationUrl.setText(serviceReturn.getmLocationUrl());
//	}
//    
//	private void setImageView(ImageView imgView, String imageUrl){
//		try {
//			Bitmap bitmap = BitmapFactory.decodeStream((InputStream) new URL(imageUrl).openStream());
//			imgView.setImageBitmap(bitmap);
//		} catch (MalformedURLException e) {
//			e.printStackTrace();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}
}