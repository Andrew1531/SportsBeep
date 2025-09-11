package com.sportsbeep.app.model.question;

import android.os.Parcel;
import android.os.Parcelable;

public class TimerState implements Parcelable {

    public static final Parcelable.Creator<TimerState> CREATOR
            = new Parcelable.Creator<TimerState>() {
        public TimerState createFromParcel(Parcel in) {
            return new TimerState(in);
        }

        public TimerState[] newArray(int size) {
            return new TimerState[size];
        }
    };

    private long id;

    private String encryptedText;

    private double value;

    public TimerState() {

    }

    private TimerState(Parcel in) {
        setId(in.readLong());
        setEncryptedText(in.readString());
        setValue(in.readDouble());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof TimerState)) {
            return false;
        }

        TimerState that = (TimerState) o;

        if (id != that.id) {
            return false;
        }
        if (Double.compare(that.value, value) != 0) {
            return false;
        }
        if (encryptedText != null ? !encryptedText.equals(that.encryptedText)
                : that.encryptedText != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result;
        long temp;
        result = (int) (id ^ (id >>> 32));
        result = 31 * result + (encryptedText != null ? encryptedText.hashCode() : 0);
        temp = Double.doubleToLongBits(value);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        return result;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeString(getEncryptedText());
        dest.writeDouble(getValue());
    }

    long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getEncryptedText() {
        return encryptedText;
    }

    public void setEncryptedText(String encryptedText) {
        this.encryptedText = encryptedText;
    }

    double getValue() {
        return value;
    }

    void setValue(double value) {
        this.value = value;
    }
}
