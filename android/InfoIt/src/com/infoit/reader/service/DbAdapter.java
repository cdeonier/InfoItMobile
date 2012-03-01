package com.infoit.reader.service;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class DbAdapter {
  public static final String KEY_ROWID = "_id";
  public static final String KEY_ENTITY_ID = "entity_id";
  public static final String KEY_BOOKMARK_TYPE = "bookmark_type";
  public static final String KEY_BOOKMARK_NAME = "bookmark_name";
  public static final String KEY_HISTORY_ITEM_TYPE = "history_item_type";
  public static final String KEY_HISTORY_ITEM_NAME = "history_item_name";
  
  private static final String TAG = "DbAdapter";
  private static final String DATABASE_NAME = "infoit_data";
  private static final int DATABASE_VERSION = 1;
  
  private static final String BOOKMARKS_TABLE = "bookmarks";
  private static final String HISTORY_TABLE = "history";

  private static final String DATABASE_CREATE_BOOKMARKS = 
      "create table bookmarks (_id integer primary key autoincrement, "
      + "entity_id integer not null, "
      + "bookmark_type string not null, "
      + "bookmark_name string not null);";
  
  private static final String DATABASE_CREATE_HISTORY = 
      "create table history (_id integer primary key autoincrement, "
      + "entity_id integer not null, "
      + "history_item_type string not null, "
      + "history_item_name string not null);";


  private DatabaseHelper mDbHelper;
  private SQLiteDatabase mDb;
  private final Context mContext;

  private static class DatabaseHelper extends SQLiteOpenHelper {

    DatabaseHelper(Context context) {
      super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
      db.execSQL(DATABASE_CREATE_BOOKMARKS);
      db.execSQL(DATABASE_CREATE_HISTORY);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
      Log.w(TAG, "Upgrading database from version " + oldVersion + " to "
          + newVersion + ", which will destroy all old data");
      db.execSQL("DROP TABLE IF EXISTS bookmarks");
      db.execSQL("DROP TABLE IF EXISTS history");
      onCreate(db);
    }
  }

  /**
   * Constructor - takes the context to allow the database to be opened/created
   * 
   * @param ctx the Context within which to work
   * 
   */
  public DbAdapter(Context ctx) {
    this.mContext = ctx;
  }

  /**
   * Open the database. If it cannot be opened, try to create a new
   * instance of the database. If it cannot be created, throw an exception to
   * signal the failure
   * 
   * @return this (self reference, allowing this to be chained in an
   *         initialization call)
   * @throws SQLException
   *           if the database could be neither opened or created
   */
  public DbAdapter open() throws SQLException {
    mDbHelper = new DatabaseHelper(mContext);
    mDb = mDbHelper.getWritableDatabase();
    return this;
  }

  public void close() {
    mDbHelper.close();
  }
  
  
  /**
   * Fetch all items stored in the history table, representing everything the user
   * has viewed before.
   * 
   * @return Cursor over all past items viewed
   */
  public Cursor fetchRecentHistory() {
    return mDb.query(HISTORY_TABLE, new String[] { KEY_ROWID, KEY_ENTITY_ID,
        KEY_HISTORY_ITEM_NAME }, null, null, null, null, KEY_ROWID + " DESC");
  }
  
  public void createHistoryItem(long entityId, String historyItemName, String historyItemType) {
    ContentValues initialValues = new ContentValues();
    initialValues.put(KEY_ENTITY_ID, entityId);
    initialValues.put(KEY_HISTORY_ITEM_NAME, historyItemName);
    initialValues.put(KEY_HISTORY_ITEM_TYPE, historyItemType);
    
 // Get rid of old values in case location has been updated.
    mDb.delete(HISTORY_TABLE, KEY_ENTITY_ID + "= " + String.valueOf(entityId), null);
    mDb.insert(HISTORY_TABLE, null, initialValues);
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
  public void createLocationBookmark(long entityId, String bookmarkName) {
    ContentValues initialValues = new ContentValues();
    initialValues.put(KEY_ENTITY_ID, entityId);
    initialValues.put(KEY_BOOKMARK_NAME, bookmarkName);
    initialValues.put(KEY_BOOKMARK_TYPE, "PLACE");

      // Get rid of old values in case location has been updated.
      mDb.delete("bookmarks", KEY_ENTITY_ID + "=" + String.valueOf(entityId), null);
      mDb.insert(BOOKMARKS_TABLE, null, initialValues);

  }

  public void deleteLocationBookmark(long entityId) {

      ContentValues initialValues = new ContentValues();
      initialValues.put(KEY_ENTITY_ID, entityId);
      mDb.delete("bookmarks", KEY_ENTITY_ID + "=" + String.valueOf(entityId),
          null);
  }

  /**
   * Return a Cursor over the list of all bookmarks in the database
   * 
   * @return Cursor over all bookmarks
   */
  public Cursor fetchAllBookmarks() {

    return mDb.query(BOOKMARKS_TABLE, new String[] { KEY_ROWID, KEY_ENTITY_ID,
        KEY_BOOKMARK_NAME }, null, null, null, null, KEY_BOOKMARK_NAME+" ASC");
  }

  /**
   * Return a Cursor over the list of all location bookmarks in the database
   * 
   * @return Cursor over all bookmarks
   */
  public Cursor fetchAllLocationBookmarks() {

    return mDb.query(BOOKMARKS_TABLE, new String[] { KEY_ROWID, KEY_ENTITY_ID,
        KEY_BOOKMARK_NAME }, KEY_BOOKMARK_TYPE + "= 'PLACE'", null, null,
        null, KEY_BOOKMARK_NAME+" ASC");
  }

  /**
   * Return a Cursor positioned at the bookmark that matches the given rowId
   * 
   * @param entityId
   *          entityId of bookmark to retrieve
   * @return Cursor positioned to matching bookmark, if found if bookmark could
   *         not be found/retrieved
   */
  public Cursor fetchBookmark(long entityId) {

    Cursor mCursor =

    mDb.query(true, BOOKMARKS_TABLE, new String[] { KEY_ROWID, KEY_ENTITY_ID,
        KEY_BOOKMARK_NAME }, KEY_ENTITY_ID + "=" + entityId, null, null, null,
        null, null);
    if (mCursor != null) {
      mCursor.moveToFirst();
    }
    return mCursor;

  }

  public boolean doesBookmarkExist(long entityId) {
    boolean doesBookmarkExist = false;
    if(mDb.isOpen()) {
      Cursor cursor = mDb.query(BOOKMARKS_TABLE, new String[] { KEY_ROWID,
          KEY_ENTITY_ID, KEY_BOOKMARK_NAME }, KEY_ENTITY_ID + "=" + entityId,
          null, null, null, null, null);
      doesBookmarkExist = cursor.getCount() > 0;
      cursor.close();
    } else{
      this.open();
      Cursor cursor = mDb.query(BOOKMARKS_TABLE, new String[] { KEY_ROWID,
          KEY_ENTITY_ID, KEY_BOOKMARK_NAME }, KEY_ENTITY_ID + "=" + entityId,
          null, null, null, null, null);
      doesBookmarkExist = cursor.getCount() > 0;
      cursor.close();
      this.close();
    }
    return doesBookmarkExist;
  }
}
