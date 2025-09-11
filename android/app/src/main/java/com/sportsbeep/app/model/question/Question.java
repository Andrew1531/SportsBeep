package com.sportsbeep.app.model.question;

import android.os.Parcel;
import android.os.Parcelable;

public class Question implements Parcelable {

    public static final String TYPE_BEST = "best";

    public static final String TYPE_BUST = "bust";

    public static final Parcelable.Creator<Question> CREATOR
            = new Parcelable.Creator<Question>() {
        public Question createFromParcel(Parcel in) {
            return new Question(in);
        }

        public Question[] newArray(int size) {
            return new Question[size];
        }
    };

    private long id;

    private String text;

    private String type;

    public Question() {

    }

    private Question(Parcel in) {
        setId(in.readLong());
        setText(in.readString());
        setType(in.readString());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof Question)) {
            return false;
        }

        Question question = (Question) o;

        if (id != question.id) {
            return false;
        }
        if (text != null ? !text.equals(question.text) : question.text != null) {
            return false;
        }
        if (type != null ? !type.equals(question.type) : question.type != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = (int) (id ^ (id >>> 32));
        result = 31 * result + (text != null ? text.hashCode() : 0);
        result = 31 * result + (type != null ? type.hashCode() : 0);
        return result;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeString(getText());
        dest.writeString(getType());
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
