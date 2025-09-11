package com.sportsbeep.app.ui.game.stats;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.task.HeadshotTask;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.AnimUtil;

import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TableLayout;
import android.widget.TableRow;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import butterknife.InjectView;

public class PlayerStatsFragment extends BaseFragment {

    public static final String EXTRA_PLAYER = "player";

    @Extra(key = EXTRA_PLAYER)
    Player mPlayer;

    @InjectView(R.id.playerPortrait_ImageView)
    ImageView mPlayerPortraitImageView;

    @InjectView(R.id.playerName_FontTextView)
    FontTextView mPlayerNameFontTextView;

    @InjectView(R.id.stats_HorizontalScrollView)
    HorizontalScrollView mStatsHorizontalScrollView;

    @InjectView(R.id.stats_TableLayout)
    TableLayout mStatsTableLayout;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    StatsTask mStatsTask;

    HeadshotTask mHeadshotTask;

    public static PlayerStatsFragment newInstance(Player player) {
        PlayerStatsFragment fragment = new PlayerStatsFragment();

        Bundle args = new Bundle();
        args.putParcelable(EXTRA_PLAYER, player);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_player_stats, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mPlayerNameFontTextView.setText(mPlayer.getName());
        colorPortrait();

        if (mPlayer.getHeadshotUrl() != null) {
            mHeadshotTask = new HeadshotTask(getActivity(), mPlayerPortraitImageView);
            mHeadshotTask.execute(mPlayer.getHeadshotUrl());
        }

        mStatsTask = new StatsTask();
        mStatsTask.execute(mPlayer);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (mHeadshotTask != null) {
            mHeadshotTask.cancel();
        }

        if (mStatsTask != null) {
            mStatsTask.cancel(false);
        }
    }

    private void colorPortrait() {
        LayerDrawable ld = (LayerDrawable) mPlayerPortraitImageView.getDrawable();
        GradientDrawable gd = (GradientDrawable) ld.findDrawableByLayerId(R.id.colorRing_Drawable);
        gd.setColor(mPlayer.getTeam().getPrimaryColor());
    }

    private void displayStatsTable(List<Stats.RecentStat> recentStats, List<Stats.SeasonStat> seasonStats) {
        LayoutInflater inflater = getActivity().getLayoutInflater();

        TableRow abbrRow = new TableRow(getActivity());
        abbrRow.setBackgroundResource(R.drawable.bottom_border);

        TableRow recentStatsRow = new TableRow(getActivity());
        TableRow seasonStatsRow = new TableRow(getActivity());

        FontTextView textView = (FontTextView) inflater.inflate(R.layout.cell_stat, abbrRow, false);
        textView.setText(getString(R.string.stats));
        abbrRow.addView(textView);

        textView = (FontTextView) inflater.inflate(R.layout.cell_stat, recentStatsRow, false);
        textView.setText(getString(R.string.last_ten_games));
        recentStatsRow.addView(textView);

        textView = (FontTextView) inflater.inflate(R.layout.cell_stat, seasonStatsRow, false);
        textView.setText(getString(R.string.season));
        seasonStatsRow.addView(textView);

        List<String> abbrList = new ArrayList<String>();
        if (recentStats != null) {
            for (Stats.Stat stat : recentStats) {
                if (!abbrList.contains(stat.getAbbr())) {
                    abbrList.add(stat.getAbbr());
                }
            }
        }

        if (seasonStats != null) {
            for (Stats.Stat stat : seasonStats) {
                if (!abbrList.contains(stat.getAbbr())) {
                    abbrList.add(stat.getAbbr());
                }
            }
        }

        for (String abbr : abbrList) {
            textView = (FontTextView) inflater.inflate(R.layout.cell_stat, abbrRow, false);
            textView.setText(abbr.toUpperCase(Locale.US));
            abbrRow.addView(textView);

            textView = (FontTextView) inflater.inflate(R.layout.cell_stat, recentStatsRow, false);
            textView.setTag(abbr);
            recentStatsRow.addView(textView);

            textView = (FontTextView) inflater.inflate(R.layout.cell_stat, seasonStatsRow, false);
            textView.setTag(abbr);
            seasonStatsRow.addView(textView);
        }

        if (recentStats != null) {
            for (Stats.Stat stat : recentStats) {
                textView = (FontTextView) recentStatsRow.findViewWithTag(stat.getAbbr());
                textView.setText(stat.getAmount());
            }
        }

        if (seasonStats != null) {
            for (Stats.Stat stat : seasonStats) {
                textView = (FontTextView) seasonStatsRow.findViewWithTag(stat.getAbbr());
                textView.setText(stat.getAmount());
            }
        }

        TableLayout.LayoutParams abbrLayoutParams = new TableLayout.LayoutParams(
                TableLayout.LayoutParams.MATCH_PARENT, TableLayout.LayoutParams.WRAP_CONTENT);
        abbrLayoutParams.bottomMargin = (int) TypedValue
                .applyDimension(TypedValue.COMPLEX_UNIT_DIP, 16f,
                        getResources().getDisplayMetrics());
        mStatsTableLayout.addView(abbrRow, abbrLayoutParams);

        mStatsTableLayout.addView(recentStatsRow);
        mStatsTableLayout.addView(seasonStatsRow);
    }

    public class StatsTask extends NetworkAsyncTask<Player, Void, Stats> {

        @Override
        protected Result<Stats> doInBackground(Player... params) {
            Player player = params[0];
            return getClient().getStatsForPlayers(getSport(), getLevel(), player);
        }

        @Override
        protected void onSuccess(Stats stats) {
            super.onSuccess(stats);
            AnimUtil.crossfade(mProgressBar, mStatsHorizontalScrollView);
            displayStatsTable(stats.getRecentStats(), stats.getSeasonStats());
        }
    }
}
