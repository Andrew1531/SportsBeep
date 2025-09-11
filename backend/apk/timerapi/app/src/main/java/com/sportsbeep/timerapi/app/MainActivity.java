package com.sportsbeep.timerapi.app;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

public class MainActivity extends Activity
{
    private TimerStateDecoder timerStateDecoder;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        timerStateDecoder = new TimerStateDecoder();

        findViewById(R.id.get_states).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                Url_TicketTimerStatesGet url = new Url_TicketTimerStatesGet(
                        getResources(),
                        new Integer(((EditText)findViewById(R.id.ticket_number)).getText().toString()),
                        new Integer(((EditText)findViewById(R.id.seconds)).getText().toString()),
                        new Integer(((EditText)findViewById(R.id.precision)).getText().toString()));

                new NetAsyncTaskTicketTimerStatesGet(url, view, timerStateDecoder).execute();
            }
        });

        findViewById(R.id.lookup_value).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                try
                {
                    String timerStateText = timerStateDecoder.findTimerStateText(
                            new Float(((EditText) findViewById(R.id.timer_value_lookup)).getText().toString())
                    );

                    if (timerStateText == null) timerStateText = getResources().getString(R.string.value_not_found);

                    ((TextView) findViewById(R.id.matching_state)).setText(timerStateText);
                }
                catch (Exception e)
                {
                    ((TextView) findViewById(R.id.matching_state)).setText(e.getMessage());
                }
            }
        });

        ((ListView)findViewById(R.id.state_list)).setOnItemClickListener(new AdapterView.OnItemClickListener()
        {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l)
            {
                try
                {
                    String timerStateText = adapterView.getItemAtPosition(i).toString();
                    Float timerValue = timerStateDecoder.findTimerStateValue(timerStateText);
                    String timerValueText = timerValue == null ? getResources().getString(R.string.value_not_found) : timerValue.toString();

                    ((TextView) findViewById(R.id.matching_state)).setText(timerStateText);
                    ((EditText) findViewById(R.id.timer_value_lookup)).setText(timerValueText);
                }
                catch (Exception e)
                {
                    ((TextView) findViewById(R.id.matching_state)).setText(e.getMessage());
                }
            }
        });

        ((Button) findViewById(R.id.report_answer)).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                Url_TicketQuestionAnswerSet url = new Url_TicketQuestionAnswerSet(
                        getResources(),
                        new Integer(((EditText)findViewById(R.id.ticket_number)).getText().toString()),
                        new Integer(((EditText)findViewById(R.id.question_number)).getText().toString()),
                        new Integer(((EditText)findViewById(R.id.answer)).getText().toString()),
                        ((TextView) findViewById(R.id.matching_state)).getText().toString()
                );

                new NetAsyncTaskTicketQuestionAnswerSet(url, view).execute();
            }
        });
    }
}
