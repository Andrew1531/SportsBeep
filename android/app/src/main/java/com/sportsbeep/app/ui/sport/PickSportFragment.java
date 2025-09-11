package com.sportsbeep.app.ui.sport;

import com.metova.slim.annotation.Callback;
import com.sportsbeep.app.R;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.ui.base.BaseFragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.RadioGroup;

import butterknife.InjectView;
import butterknife.OnClick;

public class PickSportFragment extends BaseFragment {

    @InjectView(R.id.level_RadioGroup)
    RadioGroup mLevelRadioGroup;

    @InjectView(R.id.sport_RadioGroup)
    RadioGroup mSportRadioGroup;

    @Callback
    private PickSportCallback mCallback;

    private Level mSelectedLevel;

    private Sport mSelectedSport;

    public PickSportFragment() {
        //no-op
    }

    public static PickSportFragment newInstance() {
        return new PickSportFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_pick_sport, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mLevelRadioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                onLevelChecked(checkedId);
            }
        });

        mSportRadioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                onSportChecked(checkedId);
            }
        });
    }

    void onLevelChecked(int checkedId) {
        switch (checkedId) {
            case R.id.professional_FontRadioButton:
                mSelectedLevel = Level.PROFESSIONAL;
                break;
            case R.id.college_FontRadioButton:
                mSelectedLevel = Level.COLLEGE;
                break;
            case R.id.international_FontRadioButton:
                mSelectedLevel = Level.INTERNATIONAL;
                break;
            default:
                throw new IllegalArgumentException("Sport level is invalid");
        }

        setEnterEnabled(mSelectedSport != null && mSelectedLevel != null);
    }

    void onSportChecked(int checkedId) {
        switch (checkedId) {
            case R.id.baseball_FontRadioButton:
                mSelectedSport = Sport.BASEBALL;
                break;
            case R.id.football_FontRadioButton:
                mSelectedSport = Sport.FOOTBALL;
                break;
            case R.id.basketball_FontRadioButton:
                mSelectedSport = Sport.BASKETBALL;
                break;
            case R.id.hockey_FontRadioButton:
                mSelectedSport = Sport.HOCKEY;
                break;
            default:
                throw new IllegalArgumentException("Sport type is invalid");
        }

        setEnterEnabled(mSelectedSport != null && mSelectedLevel != null);
    }

    @OnClick(R.id.enter_Button)
    public void onEnterClick() {
        mCallback.onEnterClicked(mSelectedLevel, mSelectedSport);
    }

    private void setEnterEnabled(boolean enabled) {
        Button enterBtn = (Button) getView().findViewById(R.id.enter_Button);
        enterBtn.setEnabled(enabled);
    }

    public interface PickSportCallback {

        public void onEnterClicked(Level level, Sport sport);
    }
}
