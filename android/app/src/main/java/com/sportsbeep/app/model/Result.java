package com.sportsbeep.app.model;

import retrofit.RetrofitError;

public class Result<T> {

    private T data;

    private RetrofitError exception;

    private String error;

    public Result(T data) {
        this.data = data;
    }

    public Result(RetrofitError e) {
        parseError(e);
    }

    public Result(String error) {
        this.error = error;
    }

    private void parseError(RetrofitError e) {
        setException(e);

        Error error;
        try {
            error = (Error) e.getBodyAs(Error.class);
            setError(error.error);
        } catch (Exception e2) {
            if (e.isNetworkError()) {
                setError("A network error has occurred.");
            } else {
                setError("An unexpected error has occurred.");
            }
        }
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public RetrofitError getException() {
        return exception;
    }

    void setException(RetrofitError exception) {
        this.exception = exception;
    }

    public String getError() {
        return error;
    }

    void setError(String error) {
        this.error = error;
    }

    private class Error {

        public String error;
    }
}
