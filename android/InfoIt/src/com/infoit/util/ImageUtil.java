package com.infoit.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import android.graphics.drawable.Drawable;
import android.view.View;

import com.infoit.main.R;

public class ImageUtil {
	public static Drawable getImage(String url) {
		try {
			InputStream is = (InputStream) fetch(url);
			Drawable d = Drawable.createFromStream(is, "src");
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
				InputStream is = (InputStream) fetch(url);
				Drawable d = Drawable.createFromStream(is, "src");
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
}
