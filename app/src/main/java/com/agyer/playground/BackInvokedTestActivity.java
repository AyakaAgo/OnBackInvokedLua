/*
 * Copyright 2025 The Windmill Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.agyer.playground;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.agyer.playground.app.OnBackInvokedBaseActivity;
import com.agyer.windmill.core.window.OnBackInvokedCallback;

import java.lang.ref.WeakReference;

public class BackInvokedTestActivity extends OnBackInvokedBaseActivity {
    private WeakReference<WebView> webViewWeakReference;
    private final OnBackInvokedCallback onBackInvokedCallback = new WebViewGoBackCallback(this);

    public BackInvokedTestActivity() {

    }

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout linearLayout = new LinearLayout(this);
        // WebView not support fit
        linearLayout.setFitsSystemWindows(true);
        WebView webView = new WebView(this);
        linearLayout.addView(webView, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        webViewWeakReference = new WeakReference<>(webView);

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptCanOpenWindowsAutomatically(false);
        settings.setJavaScriptEnabled(true);
        settings.setSupportZoom(true);
        settings.setBuiltInZoomControls(false);
        settings.setUseWideViewPort(true);
        settings.setLoadWithOverviewMode(true);
        settings.setDomStorageEnabled(true);
        settings.setLoadsImagesAutomatically(true);
        settings.setDatabaseEnabled(true);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        settings.setMediaPlaybackRequiresUserGesture(true);

        webView.setWebViewClient(new MyWebViewClient(this));
        webView.setWebChromeClient(new MyWebChromeClient(this));

        webView.loadUrl("https://www.bing.com");

        registerOnBackInvokedCallback(onBackInvokedCallback);

        setContentView(linearLayout);
    }

    @NonNull
    private WebView requireWebView() {
        WebView webView = webViewWeakReference.get();
        if (webView == null) throw new IllegalStateException("webview is null.");
        return webView;
    }

    private void checkGoBack() {
        onBackInvokedCallback.setEnabled(requireWebView().canGoBack());
    }

    private static class MyWebChromeClient extends WebChromeClient {
        private final WeakReference<BackInvokedTestActivity> activityWeakReference;

        MyWebChromeClient(BackInvokedTestActivity activity) {
            activityWeakReference = new WeakReference<>(activity);
        }

        @NonNull
        private BackInvokedTestActivity requireActivity() {
            BackInvokedTestActivity activity = activityWeakReference.get();
            if (activity == null) throw new IllegalStateException("activity is null");
            return activity;
        }

        private void checkGoBack() {
            requireActivity().checkGoBack();
        }

        @Override
        public void onReceivedTitle(WebView view, String title) {
            checkGoBack();
        }

    }

    private static class MyWebViewClient extends WebViewClient {
        private final WeakReference<BackInvokedTestActivity> activityWeakReference;

        MyWebViewClient(BackInvokedTestActivity activity) {
            activityWeakReference = new WeakReference<>(activity);
        }

        @NonNull
        private BackInvokedTestActivity requireActivity() {
            BackInvokedTestActivity activity = activityWeakReference.get();
            if (activity == null) throw new IllegalStateException("activity is null");
            return activity;
        }

        private void checkGoBack() {
            requireActivity().checkGoBack();
        }

        @Override
        public void onPageCommitVisible(@NonNull WebView view, @NonNull String url) {
            checkGoBack();
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            checkGoBack();
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            checkGoBack();
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            return super.shouldOverrideUrlLoading(view, request);
        }

        @Override
        public boolean shouldOverrideUrlLoading(@NonNull WebView view, @NonNull String url) {
            if (!url.startsWith("http")) {
                return true;
            }

            checkGoBack();
            return false;
        }

    }

    private static class WebViewGoBackCallback extends OnBackInvokedCallback {
        private final WeakReference<BackInvokedTestActivity> activityWeakReference;

        WebViewGoBackCallback(BackInvokedTestActivity activity) {
            // not enabled by default
            super(false);

            activityWeakReference = new WeakReference<>(activity);
        }

        @NonNull
        private BackInvokedTestActivity requireActivity() {
            BackInvokedTestActivity activity = activityWeakReference.get();
            if (activity == null) throw new IllegalStateException("activity is null");
            return activity;
        }

        /**
         * @see BackInvokedTestActivity#checkGoBack()
         */
        @Override
        public void onBackInvoked() {
            requireActivity().requireWebView().goBack();
        }

    }

}
