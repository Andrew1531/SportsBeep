package com.sportsbeep.timerapi.app;

import android.os.AsyncTask;
import android.view.View;
import android.widget.TextView;

import com.sportsbeep.timerapi.app.TimerStateDecoder;
import com.sportsbeep.timerapi.app.Url_TicketQuestionAnswerSet;
import com.sportsbeep.timerapi.app.Url_TicketTimerStatesGet;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;

public class NetAsyncTaskTicketQuestionAnswerSet extends AsyncTask<Void, Void, String>
{
    private Url_TicketQuestionAnswerSet url;
    private View view;

    public NetAsyncTaskTicketQuestionAnswerSet(Url_TicketQuestionAnswerSet url, View view)
    {
        this.url = url;
        this.view = view;
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
            return e.getClass().toString() + " : " + e.getMessage() == null ? "null exception" : e.getMessage();
        }
    }

    @Override
    protected void onPostExecute(String s)
    {
        super.onPostExecute(s);

        TextView reportStatusTextView = (TextView) view.getRootView().findViewById(R.id.report_status);

        try
        {
            JSONObject jo = new JSONObject(s);
            if (jo.getInt("error_number") == 0)
            {
                reportStatusTextView.setText(view.getResources().getString(R.string.report_successful));
            }
            else
            {
                reportStatusTextView.setText(jo.getString("error_text"));
            }
        }
        catch (Exception e)
        {
            reportStatusTextView.setText("Processing [" + s + "]: " + e.getClass().toString() + " : " + e.getMessage() == null ? "null exception" : e.getMessage());
        }
    }
}
