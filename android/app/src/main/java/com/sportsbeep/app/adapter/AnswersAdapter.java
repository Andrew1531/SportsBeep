package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.question.Answer;
import com.sportsbeep.app.model.question.Question;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.ui.view.FontTextView;

import android.content.Context;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;

import java.util.List;

import javax.inject.Inject;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class AnswersAdapter extends ArrayAdapter<Answer> {

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    public AnswersAdapter(Context context, List<Answer> objects) {
        super(context, 0, objects);
        GraphHolder.getInstance().inject(this);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        if (view == null) {
            view = LayoutInflater.from(getContext()).inflate(R.layout.item_answer, parent, false);
            view.setTag(new Holder(view));
        }

        Answer answer = getItem(position);
        Holder holder = (Holder) view.getTag();

        holder.answerNumberFontTextView.setText(Integer.toString(position + 1));
        holder.questionTypeFontTextView.setText(Question.TYPE_BEST.equals(answer.getQuestion().getType()) ? R.string.best_question : R.string.bust_question);
        holder.questionFontTextView.setText(answer.getQuestion().getText());

        int correctTextResId;
        int correctColorResId;
        int imageResId;
        if (answer.isCorrect()) {
            correctTextResId = R.string.correct;
            correctColorResId = R.color.green;
            imageResId = R.drawable.green_check;
        } else {
            correctTextResId = R.string.incorrect;
            correctColorResId = R.color.red;
            imageResId = R.drawable.red_x;
        }
        holder.correctFontTextView.setText(correctTextResId);
        holder.correctFontTextView.setTextColor(getContext().getResources().getColor(correctColorResId));
        holder.markImageView.setImageResource(imageResId);

        Team team = mTeamDaoHelper.getTeam(answer.getTeam());
        if (team != null) {
            String teamName = team.toString();
            SpannableString ss = new SpannableString(getContext().getString(R.string.team_in_seconds, teamName, answer.getTime()));
            int startIndex = teamName.length();

            int color = getContext().getResources().getColor(R.color.lavender);
            ss.setSpan(new ForegroundColorSpan(color), startIndex, ss.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

            holder.teamTimeFontTextView.setText(ss);
        } else {
            holder.teamTimeFontTextView.setText(answer.getTime());
        }

        holder.pointsFontTextView.setText(answer.getScore());

        return view;
    }

    @Override
    public boolean isEnabled(int position) {
        return false;
    }

    public static class Holder {

        @InjectView(R.id.answerNumber_FontTextView)
        FontTextView answerNumberFontTextView;

        @InjectView(R.id.questionType_FontTextView)
        FontTextView questionTypeFontTextView;

        @InjectView(R.id.question_FontTextView)
        FontTextView questionFontTextView;

        @InjectView(R.id.mark_ImageView)
        ImageView markImageView;

        @InjectView(R.id.correct_FontTextView)
        FontTextView correctFontTextView;

        @InjectView(R.id.teamTime_FontTextView)
        FontTextView teamTimeFontTextView;

        @InjectView(R.id.points_FontTextView)
        FontTextView pointsFontTextView;

        public Holder(View v) {
            ButterKnife.inject(this, v);
        }
    }
}
