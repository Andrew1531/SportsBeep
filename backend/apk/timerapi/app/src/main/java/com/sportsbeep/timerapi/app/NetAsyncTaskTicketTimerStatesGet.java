package com.sportsbeep.timerapi.app;

import android.os.AsyncTask;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;

public class NetAsyncTaskTicketTimerStatesGet extends AsyncTask<Void, Void, String>
{
    private Url_TicketTimerStatesGet url;
    private View view;
    private TimerStateDecoder timerStateDecoder;

    public NetAsyncTaskTicketTimerStatesGet(Url_TicketTimerStatesGet url, View view, TimerStateDecoder timerStateDecoder)
    {
        this.url = url;
        this.view = view;
        this.timerStateDecoder = timerStateDecoder;
    }

    protected String doInBackground(Void... Params)
    {
        HttpClient c = new DefaultHttpClient();
        try
        {
            HttpResponse r = c.execute(new HttpGet(url.getUrl()));
            if (r.getStatusLine().getStatusCode() == HttpStatus.SC_OK)
            {
                ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                r.getEntity().writeTo(buffer);
                buffer.close();
                return buffer.toString();
            }
            else
            {
                return r.getStatusLine().getReasonPhrase();
            }
        }
        catch (Exception e)
        {
            return e.getClass().toString() + " : " + e.getMessage() == null ? "null" : e.getMessage();
        }
    }

    @Override
    protected void onPostExecute(String s)
    {
        super.onPostExecute(s);

        ListView lv = (ListView) ((ViewGroup)view.getRootView()).findViewById(R.id.state_list);

        try
        {
            JSONObject responseObject = new JSONObject(s);
            if (responseObject.getInt("error_number") == 0)
            {
                ArrayAdapter<String> aa = new ArrayAdapter<String>(view.getContext(), R.layout.list_layout);
                timerStateDecoder.reset(responseObject.getInt("contract_version"), url.getTicketNumber(), url.getSeconds(), url.getPrecision());

                JSONArray resultArray = responseObject.getJSONArray("result");
                for (int i = 0; i < resultArray.length(); i++)
                {
                    aa.add(resultArray.getJSONObject(i).getString("state_text"));
                    timerStateDecoder.addTimerStateText(resultArray.getJSONObject(i).getString("state_text"));
                }

                lv.setAdapter(aa);
                //timerStateDecoder.decodeAll();
            }
        }
        catch (Exception e)
        {
            e.getMessage();
        }
    }
}
