package com.infoit.reader.service;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class BookmarkDbAdapter {
  public static final String KEY_ROWID = "_id";
  public static final String KEY_ENTITY_ID = "entity_id";
  public static final String KEY_BOOKMARK_TYPE = "bookmark_type";
  public static final String KEY_BOOKMARK_NAME = "bookmark_name";

  private static final String DATABASE_CREATE = "create table bookmarks (_id integer primary key autoincrement, "
      + "entity_id integer not null, "
      + "bookmark_type string not null, "
      + "bookmark_name string not null);";

  private static final String DATABASE_NAME = "infoit_data";
  private static final String DATABASE_TABLE = "bookmarks";
  private static final int DATABASE_VERSION = 1;

  private static final String TAG = "BookmarkDbAdapter";
  private DatabaseHelper mDbHelper;
  private SQLiteDatabase mDb;
  private final Context mCtx;

  private static class DatabaseHelper extends SQLiteOpenHelper {

    DatabaseHelper(Context context) {
      super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
      db.execSQL(DATABASE_CREATE);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
      Log.w(TAG, "Upgrading database from version " + oldVersion + " to "
          + newVersion + ", which will destroy all old data");
      db.execSQL("DROP TABLE IF EXISTS tags");
      onCreate(db);
    }
  }

  /**
   * Constructor - takes the context to allow the database to be opened/created
   * 
   * @param ctx
   *          the Context within which to work
   */
  public BookmarkDbAdapter(Context ctx) {
    this.mCtx = ctx;
  }

  /**
   * Open the notes database. If it cannot be opened, try to create a new
   * instance of the database. If it cannot be created, throw an exception to
   * signal the failure
   * 
   * @return this (self reference, allowing this to be chained in an
   *         initialization call)
   * @throws SQLException
   *           if the database could be neither opened or created
   */
  public BookmarkDbAdapter open() throws SQLException {
    mDbHelper = new DatabaseHelper(mCtx);
    mDb = mDbHelper.getWritableDatabase();
    return this;
  }

  public void close() {
    mDbHelper.close();
  }

  /**
   * Create a new location bookmark using the id and name provided. If the
   * bookmark is successfully created return the new rowId for that bookmark,
   * otherwise return a -1 to indicate failure.
   * 
   * @param entity_id
   *          the entity identifier associated with the tag
   * @return rowId or -1 if failed
   */
  public long createLocationBookmark(Integer entityId, String bookmarkName) {
    ContentValues initialValues = new ContentValues();
    initialValues.put(KEY_ENTITY_ID, entityId);
    initialValues.put(KEY_BOOKMARK_NAME, bookmarkName);
    initialValues.put(KEY_BOOKMARK_TYPE, "LOCATION");
    
    //Get rid of old values in case location has been updated.
    mDb.delete("bookmarks", KEY_ENTITY_ID + "=" + String.valueOf(entityId), null);
    
    return mDb.insert(DATABASE_TABLE, null, initialValues);
  }

  /**
   * Delete the bookmark with the given rowId
   * 
   * @param rowId
   *          id of bookmark to delete
   * @return true if deleted, false otherwise
   */
  public boolean deleteBookmark(long rowId) {

    return mDb.delete(DATABASE_TABLE, KEY_ROWID + "=" + rowId, null) > 0;
  }

  /**
   * Return a Cursor over the list of all bookmarks in the database
   * 
   * @return Cursor over all bookmarks
   */
  public Cursor fetchAllBookmarks() {

    return mDb.query(DATABASE_TABLE, new String[] { KEY_ROWID, KEY_ENTITY_ID,
        KEY_BOOKMARK_NAME }, null, null, null, null, null);
  }

  /**
   * Return a Cursor over the list of all location bookmarks in the database
   * 
   * @return Cursor over all bookmarks
   */
  public Cursor fetchAllLocationBookmarks() {

    return mDb.query(DATABASE_TABLE, new String[] { KEY_ROWID, KEY_ENTITY_ID,
        KEY_BOOKMARK_NAME }, KEY_BOOKMARK_TYPE + "= 'LOCATION'", null, null,
        null, null);
  }

  /**
   * Return a Cursor positioned at the bookmark that matches the given rowId
   * 
   * @param entityId
   *          entityId of bookmark to retrieve
   * @return Cursor positioned to matching bookmark, if found
   * @throws SQLException
   *           if bookmark could not be found/retrieved
   */
  public Cursor fetchBookmark(long entityId) throws SQLException {

    Cursor mCursor =

    mDb.query(true, DATABASE_TABLE, new String[] { KEY_ROWID, KEY_ENTITY_ID,
        KEY_BOOKMARK_NAME }, KEY_ENTITY_ID + "=" + entityId, null, null, null,
        null, null);
    if (mCursor != null) {
      mCursor.moveToFirst();
    }
    return mCursor;

  }
}
