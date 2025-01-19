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

import "android.widget.LinearLayout"
import "android.widget.TextView"
import "com.agyer.windmill.core.window.lua.LuaOnBackInvokedCallback"
import "com.agyer.windmill.core.window.OnBackInvokedDispatcher"
import "com.agyer.windmill.core.window.CompatBackEvent"

-- assume we have something to interrupt with
local count = 5

activity.setContentView(loadlayout({
    LinearLayout,
    layout_height = -1, -- LayoutParams.MATCH_PARENT
    layout_width = -1, -- LayoutParams.MATCH_PARENT
    gravity = 17, -- Gravity.CENTER
    orientation = 1, -- LinearLayout.VERTICAL
    {
        TextView,
        textSize = "150sp",
        id = "countView",
        text = tostring(count),
    },
    {
        TextView,
        textSize = "18sp",
        text = "times left to go back",
        id = "descriptionView",
        gravity = 17, -- Gravity.CENTER
    },
}))

-- animation callback supports with api 34
if not OnBackInvokedDispatcher.isAnimationCallbackSupported() then
    countView.setVisibility(8) -- View.VISIBILITY_GONE
    descriptionView.setText("animation callback not supported")
    return
end

local startTouchY, startTouchX

local priority = activity.registerOnBackInvokedCallback(LuaOnBackInvokedCallback({
    onBackStarted = function(event)
        startTouchY = event.getTouchY()
        startTouchX = event.getTouchX()
    end,
    onBackProgressed = function(event)
        local edge = event.getSwipeEdge()

        local scale
        local pivotX, pivotY;
        if edge == CompatBackEvent.EDGE_NONE --[[equals to 2]] then
            scale = 1 - event.getProgress() * 0.075
            pivotY = 0
            pivotX = 0
        else
            local touchY = event.getTouchY()
            local touchX = event.getTouchX()
            local viewHeight = countView.getHeight();
            local viewWidth = countView.getWidth();
            local pivotYAdjust = (startTouchY - touchY) / viewHeight / 4
            local pivotXAdjust = (startTouchX - touchX) / viewWidth / 4

            scale = 1 - (math.abs((swipeEdge == CompatBackEvent.EDGE_RIGHT --[[equals to 1]] and math.max(startTouchX, touchX) or math.min(startTouchY, touchX)) - touchX) / viewWidth) * 0.1
                - event.getProgress() * 0.1;

            pivotX = viewWidth * (0.5- pivotXAdjust)
            pivotY = viewHeight * (0.5 - pivotYAdjust)
        end

        countView.setPivotX(pivotX).setPivotY(pivotY)
            .setScaleX(scale).setScaleY(scale);
    end,
    onBackInvoked = function(callback)
        count = count - 1
        countView.setText(tostring(count))
        if count == 1 then
            -- convenience way for activity.unregisterOnBackInvokedCallback
            callback.remove()
        end

        countView.animate().scaleX(1).scaleY(1).setDuration(200).start();
    end,
    onBackCancelled = function()
        countView.animate().scaleX(1).scaleY(1).setDuration(200).start();
    end
}))
