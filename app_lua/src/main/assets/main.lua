require "import"

import "android.net.Uri"
import "android.content.Intent"
import "android.widget.LinearLayout"
import "android.widget.Button"

local function startTestActivity(path)
    if not pcall(function()
        activity.startActivity(
            Intent().setClassName(activity, "com.agyer.playground.app.OnBackInvokedBaseLuaActivity")
                .setData(Uri.parse("file:///back_" .. path .. ".lua"))
    )
    end) then
        print("failed to start " .. name)
    end
end

activity.setContentView(loadlayout({
    LinearLayout,
    orientation = 1, --LinearLayout.VERTICAL
    gravity = 17, -- Gravity.CENTER
    fitsSystemWindows = true;
    {
        Button,
        text = "back callback",
        onClick = function()
            startTestActivity("callback")
        end
    },
    {
        Button,
        text = "back animation callback",
        onClick = function()
            startTestActivity("animation_callback")
        end
    },
    {
        Button,
        text = "WebView goBack",
        onClick = function()
            startTestActivity("callback_webview")
        end
    },
}))