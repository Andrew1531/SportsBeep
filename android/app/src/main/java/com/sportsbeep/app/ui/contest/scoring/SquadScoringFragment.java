package com.sportsbeep.app.ui.contest.scoring;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.PlayerScoringAdapter;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.Scoresheet;
import com.sportsbeep.app.model.ticket.TicketSquad;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.AnimUtil;
import com.sportsbeep.app.util.GameViewHelper;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import javax.inject.Inject;

import butterknife.InjectView;

public class SquadScoringFragment extends BaseListFragment {

    public static final String EXTRA_TICKET_ID = "ticket_id";

    public static final String EXTRA_TICKET_SQUAD = "ticket_squad";

    public static final String EXTRA_GAME = "game";

    public static final String EXTRA_GAME_POSITION = "game_position";

    @Extra(key = EXTRA_TICKET_ID)
    long mTicketId;

    @Extra(key = EXTRA_TICKET_SQUAD)
    TicketSquad mTicketSquad;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Extra(key = EXTRA_GAME_POSITION)
    GamePosition mGamePosition;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @InjectView(R.id.game_LinearLayout)
    View mGameView;

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    ScoresheetTask mScoresheetTask;

    public static SquadScoringFragment newInstance(long ticketId, TicketSquad ticketSquad, Game game, GamePosition gamePosition) {
        SquadScoringFragment fragment = new SquadScoringFragment();

        Bundle args = new Bundle();
        args.putLong(EXTRA_TICKET_ID, ticketId);
        args.putParcelable(EXTRA_TICKET_SQUAD, ticketSquad);
        args.putParcelable(EXTRA_GAME, game);
        args.putParcelable(EXTRA_GAME_POSITION, gamePosition);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_squad_scoring, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        GameViewHelper.populateWithGame(mGame, new GameViewHelper.Holder(mGameView));

        LayoutInflater inflater = LayoutInflater.from(getActivity());

        FontTextView nameFontTextView = (FontTextView) inflater.inflate(R.layout.header_name, getListView(), false);
        Team team = mTeamDaoHelper.getTeam(mTicketSquad.getTeamId());
        nameFontTextView.setText(team.getName() + " " + mGamePosition.getTitle(getActivity()));
        getListView().addHeaderView(nameFontTextView);

        View headerView = inflater.inflate(R.layout.item_score_stat_header, getListView(), false);
        getListView().addHeaderView(headerView);

        mScoresheetTask = new ScoresheetTask();
        mScoresheetTask.execute();
    }

    @Override
    public void onDestroyView() {
        if (mScoresheetTask != null) {
            mScoresheetTask.cancel(true);
        }
        super.onDestroyView();
    }

    public class ScoresheetTask extends NetworkAsyncTask<Void, Void, Scoresheet> {

        @Override
        protected Result<Scoresheet> doInBackground(Void... params) {
            return getClient().getSquadScoresheet(getSport(), getLevel(), mTicketId, mTicketSquad.getGamePosition());
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
