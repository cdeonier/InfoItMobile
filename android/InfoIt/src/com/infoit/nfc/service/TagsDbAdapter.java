package com.infoit.nfc.service;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class TagsDbAdapter {
	public static final String KEY_LOCATION_ID = "location_id";
	public static final String KEY_LOCATION_NAME = "location_name";
    public static final String KEY_ROWID = "_id";
    
    private static final String DATABASE_CREATE =
            "create table tags (_id integer primary key autoincrement, "
            				 + "location_id integer not null, "
            				 + "location_name string not null);";

    private static final String DATABASE_NAME = "data";
    private static final String DATABASE_TABLE = "tags";
    private static final int DATABASE_VERSION = 2;
    
    private static final String TAG = "TagsDbAdapter";
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
     * Constructor - takes the context to allow the database to be
     * opened/created
     * 
     * @param ctx the Context within which to work
     */
    public TagsDbAdapter(Context ctx) {
        this.mCtx = ctx;
    }
    
    /**
     * Open the notes database. If it cannot be opened, try to create a new
     * instance of the database. If it cannot be created, throw an exception to
     * signal the failure
     * 
     * @return this (self reference, allowing this to be chained in an
     *         initialization call)
     * @throws SQLException if the database could be neither opened or created
     */
    public TagsDbAdapter open() throws SQLException {
        mDbHelper = new DatabaseHelper(mCtx);
        mDb = mDbHelper.getWritableDatabase();
        return this;
    }

    public void close() {
        mDbHelper.close();
    }
    
    /**
     * Create a new tag using the title and body provided. If the tag is
     * successfully created return the new rowId for that tag, otherwise return
     * a -1 to indicate failure.
     * 
     * @param location_id the location identifier associate with the tag
     * @return rowId or -1 if failed
     */
    public long createTag(Integer location_id, String location_name) {
        ContentValues initialValues = new ContentValues();
        initialValues.put(KEY_LOCATION_ID, location_id);
        initialValues.put(KEY_LOCATION_NAME, location_name);

        return mDb.insert(DATABASE_TABLE, null, initialValues);
    }
    
    /**
     * Delete the tag with the given rowId
     * 
     * @param rowId id of tag to delete
     * @return true if deleted, false otherwise
     */
    public boolean deleteTag(long rowId) {

        return mDb.delete(DATABASE_TABLE, KEY_ROWID + "=" + rowId, null) > 0;
    }
    
    /**
     * Return a Cursor over the list of all tags in the database
     * 
     * @return Cursor over all tags
     */
    public Cursor fetchAllTags() {

        return mDb.query(DATABASE_TABLE, new String[] {KEY_ROWID, KEY_LOCATION_ID, KEY_LOCATION_NAME}, 
        				 null, null, null, null, null);
    }
    
    /**
     * Return a Cursor positioned at the tag that matches the given rowId
     * 
     * @param rowId id of tag to retrieve
     * @return Cursor positioned to matching tag, if found
     * @throws SQLException if tag could not be found/retrieved
     */
    public Cursor fetchTag(long rowId) throws SQLException {

        Cursor mCursor =

            mDb.query(true, DATABASE_TABLE, new String[] {KEY_ROWID,
                    KEY_LOCATION_ID, KEY_LOCATION_NAME}, KEY_ROWID + "=" + rowId, null,
                    null, null, null, null);
        if (mCursor != null) {
            mCursor.moveToFirst();
        }
        return mCursor;

    }
    
    /**
     * Seed data for some locations to populate TagsList.
     */
    public void seedDataShort(){
    	mDb.delete("TAGS", null, null);
    	this.createTag(1, "Happy Cafe");
    	this.createTag(2, "New York Pizza");
    }
    
    /**
     * Seed data for lots of locations to populate TagsList.
     */
    public void seedDataLong(){
    	mDb.delete("TAGS", null, null);
    	this.createTag(1, "Happy Cafe");
    	this.createTag(2, "New York Pizza");
    	this.createTag(3, "Sun's Kitchen");
    	this.createTag(4, "Himiwari");
    	this.createTag(5, "Santa Ramen");
    	this.createTag(6, "Ramen Dojo");
    	this.createTag(7, "Noah's Bagels");
    	this.createTag(8, "Debe's Salon");
    }
}
