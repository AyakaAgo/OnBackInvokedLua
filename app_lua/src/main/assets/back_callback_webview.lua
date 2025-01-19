--[[
Copyright 2025 The Windmill Open Source Project

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]
require "import"

import "android.webkit.*"
import "android.widget.LinearLayout"
import "com.agyer.windmill.core.window.lua.LuaOnBackInvokedCallback"

activity.setContentView(loadlayout({
    LinearLayout,
    layout_height = -1, -- LayoutParams.MATCH_PARENT
    layout_width = -1, -- LayoutParams.MATCH_PARENT
    fitsSystemWindows = true, -- WebView not supports paddings
    {
        WebView,
        layout_height = -1, -- LayoutParams.MATCH_PARENT
        layout_width = -1, -- LayoutParams.MATCH_PARENT
        id = "webview",
    }
}))

local webViewGoBackCallback = LuaOnBackInvokedCallback({
    onBackInvoked = function(callback)
        webview.goBack()
    end
-- as setEnabled(false)
}, false)

activity.registerOnBackInvokedCallback(webViewGoBackCallback)

local function checkCanGoBack()
    webViewGoBackCallback.setEnabled(webview.canGoBack())
end

-- can check goBack in these cases
webview.setWebViewClient(luajava.override(WebViewClient,{
    onPageCommitVisible = function()
        checkCanGoBack()
    end,
    onPageFinished = function()
        checkCanGoBack()
    end,
    onPageStarted = function()
        checkCanGoBack()
    end,
    shouldOverrideUrlLoading = function(_, _, url)
        if not (type(url) == "string" and url or url.getUrl().toString()):find("^http") then
            return true
        end

        checkCanGoBack()
        return false
    end
}))
.setWebChromeClient(luajava.override(WebChromeClient,{
    onReceivedTitle = function()
        checkCanGoBack()
    end
}))
.loadUrl("https://www.bing.com");

function onDestroy()
    -- convenience way for activity.unregisterOnBackInvokedCallback
    -- its a good practice to always remove when unneeded, don't just rely on setEnabled
    webViewGoBackCallback.remove()

    --activity.unregisterOnBackInvokedCallback(webViewGoBackCallback)
end

local settings = webview.getSettings();
settings.setJavaScriptCanOpenWindowsAutomatically(false);
settings.setJavaScriptEnabled(true);
settings.setSupportZoom(true);
settings.setBuiltInZoomControls(false);
settings.setUseWideViewPort(true);
settings.setLoadWithOverviewMode(true);
settings.setDomStorageEnabled(true);
settings.setLoadsImagesAutomatically(true);
settings.setDatabaseEnabled(true);
settings.setMixedContentMode(0); -- WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
settings.setMediaPlaybackRequiresUserGesture(true);
