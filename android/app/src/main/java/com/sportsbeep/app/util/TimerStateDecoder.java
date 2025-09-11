package com.sportsbeep.app.util;

import android.util.Base64;

import java.security.spec.AlgorithmParameterSpec;
import java.util.ArrayList;
import java.util.TreeMap;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

class TimerStateDecoder {

    private static final String CIPHER_TRANSFORMATION = "AES/CBC/PKCS7Padding";

    private ArrayList<String> mTimerStateTextList;

    private TreeMap<Float, String> mTimerValueToTimerStateTextMap;

    private TreeMap<String, Float> mTimerStateTextToTimerValueMap;

    private int mContractVersion;

    private long mTicketId;

    private int mSeconds;

    private int mPrecision;

    public TimerStateDecoder() {
        this.reset(0, 0, 0, 0);
    }

    public void reset(int contractVersion, long ticketNumber, int seconds, int precision) {
        mTimerStateTextList = new ArrayList<String>();
        mTimerValueToTimerStateTextMap = new TreeMap<Float, String>();
        mTimerStateTextToTimerValueMap = new TreeMap<String, Float>();

        this.mContractVersion = contractVersion;
        this.mTicketId = ticketNumber;
        this.mSeconds = seconds;
        this.mPrecision = precision;
    }

    public void addTimerStateText(String timerStateText) {
        mTimerStateTextList.add(timerStateText);
    }

    public Float findTimerStateValue(String timerStateText) {
        if (!mTimerStateTextToTimerValueMap.containsKey(timerStateText)) {
            Cipher c = null;
            try {
                c = Cipher.getInstance(CIPHER_TRANSFORMATION);
            } catch (Exception e) {
                // do something intelligent
            }

            decodeOne(c, timerStateText);
        }

        return mTimerStateTextToTimerValueMap.get(timerStateText);
    }

    public String findTimerStateText(Float timerValue) {
        if (!mTimerValueToTimerStateTextMap.containsKey(timerValue)) {
            Cipher c = null;
            try {
                c = Cipher.getInstance(CIPHER_TRANSFORMATION);
            } catch (Exception e) {
                // do something intelligent
            }

            int s;
            int p;

            if (timerValue == Math.floor(timerValue) && timerValue > 0) {
                s = (int) Math.floor(timerValue) - 1;
            } else {
                s = (int) Math.floor(timerValue);
            }

            p = Math.round((timerValue - (float) s) * mPrecision);

            decodeOne(c, s, p);
        }

        return mTimerValueToTimerStateTextMap.get(timerValue);
    }

    public void decodeAll() {
        new DecoderThread().start();
    }

    private void decodeOne(Cipher c, String timerStateText) {
        String randomSalt = timerStateText.substring(0, 6);
        String cipherText = timerStateText.substring(6);

        boolean wasDecoded = false;

        for (int s = 0; s < mSeconds; s++) {
            if (wasDecoded) {
                break;
            }

            for (int p = 0; p <= mPrecision; p++) {
                if (s > 0 && p == 0) {
                    continue;
                }

                String positionalSalt = Integer.toString(s) + ":" + Integer.toString(p);

                String key = "";
                while (key.length() < 32) {
                    key += ":" + randomSalt + ":" + positionalSalt + ":" + Long.toString(mTicketId)
                            + ":" + randomSalt + ":";
                }
                if (key.length() > 32) {
                    key = key.substring(0, 32);
                }

                try {
                    AlgorithmParameterSpec iv = new IvParameterSpec(
                            key.substring(0, 16).getBytes("UTF-8"));
                    SecretKeySpec k = new SecretKeySpec(key.getBytes("UTF-8"), "AES");
                    c.init(Cipher.DECRYPT_MODE, k, iv);
                    byte[] cipherBytes = Base64.decode(cipherText, Base64.DEFAULT);
                    byte[] plainBytes = c.doFinal(cipherBytes);
                    String plainText = new String(plainBytes, "UTF-8");

                    if (plainText.startsWith(positionalSalt)) {
                        String value = plainText.substring(positionalSalt.length() + 1);
                        mTimerValueToTimerStateTextMap.put(Float.valueOf(value), timerStateText);
                        mTimerStateTextToTimerValueMap.put(timerStateText, Float.valueOf(value));

                        wasDecoded = true;
                        break;
                    }
                } catch (Exception e) {
                    // do something intelligent
                }
            }
        }
    }

    private void decodeOne(Cipher c, int s, int p) {
        for (String stateText : mTimerStateTextList) {
            String randomSalt = stateText.substring(0, 6);
            String cipherText = stateText.substring(6);

            String positionalSalt = Integer.toString(s) + ":" + Integer.toString(p);

            String key = "";
            while (key.length() < 32) {
                key += ":" + randomSalt + ":" + positionalSalt + ":" + Long.toString(mTicketId)
                        + ":" + randomSalt + ":";
            }
            if (key.length() > 32) {
                key = key.substring(0, 32);
            }

            try {
                AlgorithmParameterSpec iv = new IvParameterSpec(
                        key.substring(0, 16).getBytes("UTF-8"));
                SecretKeySpec k = new SecretKeySpec(key.getBytes("UTF-8"), "AES");
                c.init(Cipher.DECRYPT_MODE, k, iv);
                byte[] cipherBytes = Base64.decode(cipherText, Base64.DEFAULT);
                byte[] plainBytes = c.doFinal(cipherBytes);
                String plainText = new String(plainBytes, "UTF-8");

                if (plainText.startsWith(positionalSalt)) {
                    String value = plainText.substring(positionalSalt.length() + 1);
                    mTimerValueToTimerStateTextMap.put(Float.valueOf(value), stateText);
                    mTimerStateTextToTimerValueMap.put(stateText, Float.valueOf(value));
                    break;
                }
            } catch (Exception e) {
                // do something intelligent
            }
        }
    }

    private class DecoderThread extends Thread {

        public void run() {
            Cipher c = null;
            try {
                c = Cipher.getInstance(CIPHER_TRANSFORMATION);
            } catch (Exception e) {
                // do something intelligent
            }

            for (int s = 0; s < mSeconds; s++) {
                for (int p = 0; p <= mPrecision; p++) {
                    if (s > 0 && p == 0) {
                        continue;
                    }

                    decodeOne(c, s, p);
                }
            }
        }
    }
}
