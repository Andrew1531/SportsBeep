package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.pool.Pool;
import com.sportsbeep.app.ui.view.FontTextView;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.List;

public class PoolAdapter extends ArrayAdapter<Pool> {

    public PoolAdapter(Context context, List<Pool> objects) {
        super(context, 0, objects);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        FontTextView view = (FontTextView) convertView;
        if (view == null) {
            view = (FontTextView) LayoutInflater.from(getContext())
                    .inflate(R.layout.item_simple, parent, false);
        }

        Pool pool = getItem(position);

        String poolText;
        if (pool.getEntryFee() == 0f && pool.getPrizePool() == 0f) {
            poolText = getContext().getString(R.string.play_for_free);
        } else {
            poolText = getContext()
                    .getString(R.string.pool_item, pool.getEntryFee(), pool.getPrizePool());
        }

        view.setText(poolText);

        return view;
    }
}
