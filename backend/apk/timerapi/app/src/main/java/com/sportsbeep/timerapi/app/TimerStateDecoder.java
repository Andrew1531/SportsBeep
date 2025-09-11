package com.sportsbeep.timerapi.app;

import android.util.Base64;

import java.security.spec.AlgorithmParameterSpec;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.TreeMap;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class TimerStateDecoder
{
    ArrayList<String> timerStateTextList;
    TreeMap<Float, String> timerValueToTimerStateTextMap;
    TreeMap<String, Float> timerStateTextToTimerValueMap;
    int contractVersion;
    int ticketNumber;
    int seconds;
    int precision;

    public TimerStateDecoder()
    {
        this.reset(0, 0, 0, 0);
    }

    public void reset(int contractVersion, int ticketNumber, int seconds, int precision)
    {
        timerStateTextList = new ArrayList<String>();
        timerValueToTimerStateTextMap = new TreeMap<Float, String>();
        timerStateTextToTimerValueMap = new TreeMap<String, Float>();

        this.contractVersion = contractVersion;
        this.ticketNumber = ticketNumber;
        this.seconds = seconds;
        this.precision = precision;
    }

    public void addTimerStateText(String timerStateText)
    {
        timerStateTextList.add(timerStateText);
    }

    public Float findTimerStateValue(String timerStateText)
    {
        if (!timerStateTextToTimerValueMap.containsKey(timerStateText))
        {
            Cipher c = null;
            try
            {
                c = Cipher.getInstance("AES/CBC/PKCS7Padding");
            }
            catch (Exception e)
            {
                // do something intelligent
            }

            decodeOne(c, timerStateText);
        }

        return timerStateTextToTimerValueMap.get(timerStateText);
    }

    public String findTimerStateText(Float timerValue)
    {
        if (!timerValueToTimerStateTextMap.containsKey(timerValue))
        {
            Cipher c = null;
            try
            {
                c = Cipher.getInstance("AES/CBC/PKCS7Padding");
            }
            catch (Exception e)
            {
                // do something intelligent
            }

            int s = 0;
            int p = 0;

            if (timerValue == Math.floor(timerValue) && timerValue > 0)
            {
                s = (int) Math.floor(timerValue) - 1;
            }
            else
            {
                s = (int) Math.floor(timerValue);
            }

            p = (int) Math.round((timerValue - (float) s) * precision);

            decodeOne(c, s, p);
        }

        return timerValueToTimerStateTextMap.get(timerValue);
    }

    public void decodeAll()
    {
        new decoderThread().start();
    }

    private void decodeOne(Cipher c, String timerStateText)
    {
        String randomSalt = timerStateText.substring(0, 6);
        String cipherText = timerStateText.substring(6);

        boolean wasDecoded = false;

        for (int s = 0; s < seconds; s++)
        {
            if (wasDecoded) break;

            for (int p = 0; p <= precision; p++)
            {
                if (s > 0 && p == 0) continue;

                String positionalSalt = Integer.toString(s) + ":" + Integer.toString(p);

                String key = "";
                while (key.length() < 32)
                {
                    key += ":" + randomSalt + ":" + positionalSalt + ":" + Integer.toString(ticketNumber) + ":" + randomSalt + ":";
                }
                if (key.length() > 32) { key = key.substring(0, 32); }

                try
                {
                    AlgorithmParameterSpec iv = new IvParameterSpec(key.substring(0, 16).getBytes("UTF-8"));
                    SecretKeySpec k = new SecretKeySpec(key.getBytes("UTF-8"), "AES");
                    c.init(Cipher.DECRYPT_MODE, k, iv);
                    byte[] cipherBytes = Base64.decode(cipherText, Base64.DEFAULT);
                    byte[] plainBytes = c.doFinal(cipherBytes);
                    String plainText = new String(plainBytes, "UTF-8");

                    if (plainText.startsWith(positionalSalt))
                    {
                        String value = plainText.substring(positionalSalt.length() + 1);
                        timerValueToTimerStateTextMap.put(new Float(value), timerStateText);
                        timerStateTextToTimerValueMap.put(timerStateText, new Float(value));

                        wasDecoded = true;
                        break;
                    }
                }
                catch (Exception e)
                {
                    // do something intelligent
                }
            }
        }
    }

    private void decodeOne(Cipher c, int s, int p)
    {
        for (int i = 0; i < timerStateTextList.size(); i++)
        {
            String stateText = timerStateTextList.get(i);

            String randomSalt = stateText.substring(0, 6);
            String cipherText = stateText.substring(6);

            String positionalSalt = Integer.toString(s) + ":" + Integer.toString(p);

            String key = "";
            while (key.length() < 32)
            {
                key += ":" + randomSalt + ":" + positionalSalt + ":" + Integer.toString(ticketNumber) + ":" + randomSalt + ":";
            }
            if (key.length() > 32) { key = key.substring(0, 32); }

            try
            {
                AlgorithmParameterSpec iv = new IvParameterSpec(key.substring(0, 16).getBytes("UTF-8"));
                SecretKeySpec k = new SecretKeySpec(key.getBytes("UTF-8"), "AES");
                c.init(Cipher.DECRYPT_MODE, k, iv);
                byte[] cipherBytes = Base64.decode(cipherText, Base64.DEFAULT);
                byte[] plainBytes = c.doFinal(cipherBytes);
                String plainText = new String(plainBytes, "UTF-8");

                if (plainText.startsWith(positionalSalt))
                {
                    String value = plainText.substring(positionalSalt.length() + 1);
                    timerValueToTimerStateTextMap.put(new Float(value), stateText);
                    timerStateTextToTimerValueMap.put(stateText, new Float(value));
                    break;
                }
            }
            catch (Exception e)
            {
                // do something intelligent
            }
        }
    }

    private class decoderThread extends Thread
    {
        public void run()
        {
            System.out.println("decoderThread start");

            Cipher c = null;
            try
            {
                c = Cipher.getInstance("AES/CBC/PKCS7Padding");
            }
            catch (Exception e)
            {
                // do something intelligent
            }

            for (int s = 0; s < seconds; s++)
            {
                for (int p = 0; p <= precision; p++)
                {
                    if (s > 0 && p == 0) continue;

                    decodeOne(c, s, p);
                }
            }

            System.out.println("decoderThread end");

            for (Iterator<String> i = timerStateTextToTimerValueMap.keySet().iterator(); i.hasNext(); )
            {
                String text = i.next();
                Float value = timerStateTextToTimerValueMap.get(text);
                System.out.println(text + ":" + Float.toString(value));
            }
        }
    }
}
