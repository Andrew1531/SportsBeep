package com.sportsbeep.app.ui.tutorial;

import com.metova.slim.annotation.Callback;
import com.sportsbeep.app.FlavorConstants;
import com.sportsbeep.app.R;
import com.sportsbeep.app.ui.base.BaseFragment;
import com.sportsbeep.app.util.AnimUtil;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;

import butterknife.InjectView;
import butterknife.OnClick;

public class HowToPlayFragment extends BaseFragment {

    @InjectView(R.id.webView)
    WebView mWebView;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @Callback
    HowToPlayCallback mCallback;

    public static HowToPlayFragment newInstance() {
        return new HowToPlayFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_how_to_play, container, false);
    }

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
                mProgressBar.setVisibility(View.VISIBLE);
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                if (mWebView.getVisibility() == View.VISIBLE) {
                    AnimUtil.fadeOut(mProgressBar);
                } else {
                    AnimUtil.crossfade(mProgressBar, mWebView);
                }
            }
        });

        mWebView.loadUrl(FlavorConstants.ENDPOINT + "/mobile/pages/how_it_works");
        mWebView.setBackgroundColor(0xffffffff);
    }

    @OnClick(R.id.finish_FontTextView)
    public void onFinishClicked() {
        mCallback.onCloseClicked();
    }

    public boolean onBackPressed() {
        if (mWebView.canGoBack()) {
            mWebView.goBack();
            return true;
        }
        return false;
    }

    public interface HowToPlayCallback {

        public void onCloseClicked();
    }
}
