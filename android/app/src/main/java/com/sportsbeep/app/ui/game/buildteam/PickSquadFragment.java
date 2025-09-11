package com.sportsbeep.app.ui.game.buildteam;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.ui.base.BaseFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.GameViewHelper;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import butterknife.ButterKnife;

public class PickSquadFragment extends BaseFragment implements GameViewHelper.OnTeamClickedListener {

    private static final String EXTRA_GAME = "game";

    private static final String EXTRA_GAME_POSITION = "game_position";

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Extra(key = EXTRA_GAME_POSITION)
    GamePosition mGamePosition;

    @Callback
    PickSquadCallback mCallback;

    public static PickSquadFragment newInstance(Game game, GamePosition gamePosition) {
        PickSquadFragment fragment = new PickSquadFragment();

        Bundle args = new Bundle();
        args.putParcelable(EXTRA_GAME, game);
        args.putSerializable(EXTRA_GAME_POSITION, gamePosition);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_pick_squad, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        FontTextView titleFontTextView = ButterKnife.findById(view, R.id.title_FontTextView);
        titleFontTextView.setText(getString(R.string.pick_your_position, mGamePosition.getTitle(getActivity())));

        View gameView = ButterKnife.findById(view, R.id.game_LinearLayout);
        GameViewHelper.populateWithGame(mGame, gameView, this);
    }

    @Override
    public void onTeamClicked(Team team) {
        mCallback.onTeamClicked(mGamePosition, team);
    }

    @Override
    public void onTeamLongClicked(Team team) {
        mCallback.onTeamLongClicked(mGamePosition, team);
    }

    public interface PickSquadCallback {

        public void onTeamClicked(GamePosition gamePosition, Team team);

        public void onTeamLongClicked(GamePosition gamePosition, Team team);
    }
}
