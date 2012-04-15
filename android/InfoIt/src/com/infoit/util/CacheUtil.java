package com.infoit.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Arrays;
import java.util.Comparator;

import org.codehaus.jackson.JsonNode;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;

public class CacheUtil {
	
	public static void saveEntityJson(Activity activity, JsonNode jsonResponse, int identifier) {
		String jsonString = jsonResponse.toString();
		File cacheDir = activity.getCacheDir();
		
		manageCache(activity);
		
		File jsonFile = new File(cacheDir, "entityJson"+String.valueOf(identifier));
		
		if (jsonFile.exists()) {
			jsonFile.delete();
		}
		
		try {
			jsonFile.createNewFile();
			FileOutputStream fos = new FileOutputStream(jsonFile);
			fos.write(jsonString.getBytes());
			fos.flush();
			fos.close();
		} catch (Exception e) {
			Log.e("Error", "Error saving entity Json to cache.");
		}
	}
	
	public static boolean entityJsonExists(Activity activity, int identifier) {
		File cacheDir = activity.getCacheDir();
		File jsonFile = new File(cacheDir, "entityJson"+String.valueOf(identifier));
		
		if (jsonFile.exists()) {
			//If the file is older than an hour, consider dirty and just remove it here
			if (System.currentTimeMillis() - jsonFile.lastModified() < 3600000) {
				return true;
			} else {
				jsonFile.delete();
			}
		}

		return false;
	}
	
	public static String getEntityJsonString(Activity activity, int identifier) {
		File cacheDir = activity.getCacheDir();
		File jsonFile = new File(cacheDir, "entityJson"+String.valueOf(identifier));
		jsonFile.setLastModified(System.currentTimeMillis());
		
		String jsonString = null;
		try {
			FileInputStream fis = new FileInputStream(jsonFile);
			byte[] fileContent = new byte[(int)jsonFile.length()];
			fis.read(fileContent);
			jsonString = new String(fileContent);
		} catch (Exception e) {
			Log.e("Error", "Error reading entity Json from cache.");
		}
		
		return jsonString;
	}
	
	public static void manageCache(Activity activity) {
		File cacheDir = activity.getCacheDir();

		File[] files = cacheDir.listFiles();
		
		long cacheSize = 0;
		for (File file : files) {
			cacheSize += file.length();
		}

		//We'll allocate a 2MB cache
		if (cacheSize > 2000000) {
			Arrays.sort(files, new Comparator<File>() {
				public int compare(File f1, File f2) {
					return Long.valueOf(f1.lastModified()).compareTo(f2.lastModified());
				}
			});
			
			//Clear the cache until we remove half the contents
			long removedSize = 0;
			while (removedSize < 1000000) {
				removedSize += files[0].length();
				files[0].delete();
				files = Arrays.copyOfRange(files, 1, files.length);
			}
		}
	}
	
	public static void saveImage(Activity activity, Drawable image, String imageUrl) {
		File cacheDir = activity.getCacheDir();
		
		manageCache(activity);
		
		File imageFile = new File(cacheDir, "img"+imageUrl.hashCode());
		
		if (imageFile.exists()) {
			imageFile.delete();
		}
		
		try {
			imageFile.createNewFile();
			FileOutputStream fos = new FileOutputStream(imageFile);
			Bitmap bitmap = ((BitmapDrawable)image).getBitmap();
			bitmap.compress(Bitmap.CompressFormat.JPEG, 90, fos);
			fos.flush();
			fos.close();
		} catch (Exception e) {
			Log.e("Error", "Error saving entity Json to cache.");
		}
	}
	
	public static boolean imageExists(Activity activity, String imageUrl) {
		File cacheDir = activity.getCacheDir();
		File imageFile = new File(cacheDir, "img"+imageUrl.hashCode());
		
		if (imageFile.exists()) {
			//If the file is older than an hour, consider dirty and just remove it here
			if (System.currentTimeMillis() - imageFile.lastModified() < 3600000) {
				return true;
			} else {
				imageFile.delete();
			}
		}

		return false;
	}
	
	public static Drawable getImage(Activity activity, String imageUrl) {
		File cacheDir = activity.getCacheDir();
		File imageFile = new File(cacheDir, "img"+imageUrl.hashCode());
		//Touch the file, to attempt to keep it from being cleaned away by manageCache
		imageFile.setLastModified(System.currentTimeMillis());
		
		Drawable image = null;
		try {
			FileInputStream fis = new FileInputStream(imageFile);
			image = new BitmapDrawable(BitmapFactory.decodeStream(fis));
		} catch (Exception e) {
			Log.e("Error", "Error reading entity Json from cache.");
		}
		
		return image;
	}
}
