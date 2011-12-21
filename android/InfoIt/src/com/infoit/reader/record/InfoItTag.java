package com.infoit.reader.record;

import java.math.BigInteger;
import java.nio.charset.Charset;

import android.net.Uri;
import android.nfc.NdefRecord;

public class InfoItTag {
    private final Uri mUri;
    
    private InfoItTag(Uri uri) {
        this.mUri = uri;
    }
    
    public Uri getUri() {
		return mUri;
	}

    public BigInteger getLocationIdentifier(){
    	return new BigInteger(mUri.getPath().split("/")[2]);
    }

	public static InfoItTag parse(NdefRecord record) {
        short tnf = record.getTnf();
        if (tnf == NdefRecord.TNF_WELL_KNOWN) {
            return parseWellKnown(record);
        } else if (tnf == NdefRecord.TNF_ABSOLUTE_URI) {
            return parseAbsolute(record);
        }
        throw new IllegalArgumentException("Unknown TNF " + tnf);
    }
    
    /** Parse and absolute URI record */
    private static InfoItTag parseAbsolute(NdefRecord record) {
        byte[] payload = record.getPayload();
        Uri uri = Uri.parse(new String(payload, Charset.forName("UTF-8")));
        return new InfoItTag(uri);
    }

    /** Parse an well known URI record */
    private static InfoItTag parseWellKnown(NdefRecord record) {
        byte[] payload = record.getPayload();
        /*
         * payload[0] contains the URI Identifier Code, per the
         * NFC Forum "URI Record Type Definition" section 3.2.2.
         *
         * payload[1]...payload[payload.length - 1] contains the rest of
         * the URI.
         */
        String prefix = "http://www.";
        byte[] fullUri = new byte[prefix.getBytes(Charset.forName("UTF-8")).length + payload.length-1];
        System.arraycopy(prefix.getBytes(Charset.forName("UTF-8")), 0, fullUri, 0, prefix.getBytes(Charset.forName("UTF-8")).length);
        System.arraycopy(payload, 0, fullUri, prefix.getBytes(Charset.forName("UTF-8")).length, payload.length-1);
        Uri uri = Uri.parse(new String(fullUri, Charset.forName("UTF-8")));
        return new InfoItTag(uri);
    }

    public static boolean isText(NdefRecord record) {
        try {
            parse(record);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
