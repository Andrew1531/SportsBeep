package com.sportsbeep.app.ui.contest.scoring;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.PlayerScoringAdapter;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.Scoresheet;
import com.sportsbeep.app.model.ticket.TicketPlayer;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.task.HeadshotTask;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.AnimUtil;
import com.sportsbeep.app.util.GameViewHelper;

import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;

import javax.inject.Inject;

import butterknife.InjectView;

public class PlayerScoringFragment extends BaseListFragment {

    public static final String EXTRA_TICKET_ID = "ticket_id";

    public static final String EXTRA_TICKET_PLAYER = "ticket_player";

    public static final String EXTRA_GAME = "game";

    @Extra(key = EXTRA_TICKET_ID)
    long mTicketId;

    @Extra(key = EXTRA_TICKET_PLAYER)
    TicketPlayer mTicketPlayer;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @InjectView(R.id.game_LinearLayout)
    View mGameView;

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    ScoresheetTask mScoresheetTask;

    HeadshotTask mHeadshotTask;

    public static PlayerScoringFragment newInstance(long ticketId, TicketPlayer ticketPlayer, Game game) {
        PlayerScoringFragment fragment = new PlayerScoringFragment();

        Bundle args = new Bundle();
        args.putLong(EXTRA_TICKET_ID, ticketId);
        args.putParcelable(EXTRA_TICKET_PLAYER, ticketPlayer);
        args.putParcelable(EXTRA_GAME, game);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_player_scoring, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        GameViewHelper.populateWithGame(mGame, new GameViewHelper.Holder(mGameView));

        LayoutInflater inflater = LayoutInflater.from(getActivity());

        View playerPortraitView = inflater.inflate(R.layout.player_portrait, getListView(), false);
        FontTextView playerNameFontTextView = (FontTextView) playerPortraitView.findViewById(R.id.playerName_FontTextView);
        playerNameFontTextView.setText(mTicketPlayer.getName());

        ImageView playerPortraitImageView = (ImageView) playerPortraitView.findViewById(R.id.playerPortrait_ImageView);
        colorPortrait(playerPortraitImageView);

        if (!TextUtils.isEmpty(mTicketPlayer.getHeadshotUrl())) {
            mHeadshotTask = new HeadshotTask(getActivity(), playerPortraitImageView);
            mHeadshotTask.execute(mTicketPlayer.getHeadshotUrl());
        }

        getListView().addHeaderView(playerPortraitView, null, false);

        View headerView = inflater.inflate(R.layout.item_score_stat_header, getListView(), false);
        getListView().addHeaderView(headerView);

        mScoresheetTask = new ScoresheetTask();
        mScoresheetTask.execute();
    }

    @Override
    public void onDestroyView() {
        if (mHeadshotTask != null) {
            mHeadshotTask.cancel();
        }

        if (mScoresheetTask != null) {
            mScoresheetTask.cancel(true);
        }
        super.onDestroyView();
    }

    private void colorPortrait(ImageView imageView) {
        Team team = mTeamDaoHelper.getTeam(mTicketPlayer.getTeam());

        LayerDrawable ld = (LayerDrawable) imageView.getDrawable();
        GradientDrawable gd = (GradientDrawable) ld.findDrawableByLayerId(R.id.colorRing_Drawable);
        gd.setColor(team.getPrimaryColor());
    }

    public class ScoresheetTask extends NetworkAsyncTask<Void, Void, Scoresheet> {

        @Override
        protected Result<Scoresheet> doInBackground(Void... params) {
            return getClient().getPlayerScoresheet(getSport(), getLevel(), mTicketId, mTicketPlayer.getPlayerId());
        }

        @Override
        protected void onSuccess(Scoresheet scoresheet) {
            super.onSuccess(scoresheet);
            View footerView = LayoutInflater.from(getActivity()).inflate(R.layout.item_score_stat_footer, getListView(), false);
            FontTextView totalFontTextView = (FontTextView) footerView.findViewById(R.id.total_FontTextView);
            totalFontTextView.setText(scoresheet.getScore());
            getListView().addFooterView(footerView);

            setListAdapter(new PlayerScoringAdapter(getActivity(), scoresheet.getStats()));

            AnimUtil.crossfade(mProgressBar, getListView());
        }
    }
}
