package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.NumberUtil;
import com.squareup.picasso.Picasso;

import android.content.Context;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.AbsoluteSizeSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;

import java.util.List;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class TicketsAdapter extends ArrayAdapter<Ticket> {

    public TicketsAdapter(Context context, List<Ticket> objects) {
        super(context, 0, objects);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        if (view == null) {
            view = LayoutInflater.from(getContext()).inflate(R.layout.item_ticket, parent, false);
            view.setTag(new Holder(view));
        }

        final Holder holder = (Holder) view.getTag();
        Ticket ticket = getItem(position);

        Picasso picasso = Picasso.with(getContext());
        picasso.cancelRequest(holder.userPhotoImageView);

        holder.userNameFontTextView.setText(ticket.getUser().getUsername());
        holder.placeFontTextView.setText(getPlaceText(ticket.getPlacing()));
        holder.pointsFontTextView.setText(ticket.getScore());

        String avatarUrl = ticket.getUser().getAvatarUrl();
        if (!TextUtils.isEmpty(avatarUrl)) {
            picasso.load(ticket.getUser().getAvatarUrl())
                    .resizeDimen(R.dimen.portrait_size, R.dimen.portrait_size)
                    .centerCrop()
                    .placeholder(R.drawable.player_silhouette)
                    .error(R.drawable.player_silhouette)
                    .into(holder.userPhotoImageView);
        } else {
            picasso.load(R.drawable.player_silhouette)
                    .into(holder.userPhotoImageView);
        }

        return view;
    }

    private CharSequence getPlaceText(int place) {
        String placeText = NumberUtil.decimalToOrdinal(place);
        SpannableString ss = new SpannableString(placeText);

        final int start = Integer.toString(place).length();
        final int end = placeText.length();
        ss.setSpan(new AbsoluteSizeSpan(18, true), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        return ss;
    }

    class Holder {

        @InjectView(R.id.userPhoto_ImageView)
        ImageView userPhotoImageView;

        @InjectView(R.id.place_FontTextView)
        FontTextView placeFontTextView;

        @InjectView(R.id.userName_FontTextView)
        FontTextView userNameFontTextView;

        @InjectView(R.id.points_FontTextView)
        FontTextView pointsFontTextView;

        public Holder(View view) {
            ButterKnife.inject(this, view);
        }
    }
}
