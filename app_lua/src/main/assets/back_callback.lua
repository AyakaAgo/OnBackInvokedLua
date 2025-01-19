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
        textSize = "100sp",
        id = "countView",
        text = tostring(count),
    },
    {
        TextView,
        textSize = "18sp",
        text = "times left to go back",
        gravity = 17, -- Gravity.CENTER
    },
}))

local priority = activity.registerOnBackInvokedCallback(LuaOnBackInvokedCallback({
    onBackInvoked = function(callback)
        count = count - 1
        countView.setText(tostring(count))
        if count == 1 then
            -- convenience way for activity.unregisterOnBackInvokedCallback
            callback.remove()
        end
    end
}))

local ghostCallback = LuaOnBackInvokedCallback({
    onBackInvoked = function(callback)
        -- hell lol wow
    end
})

activity.registerOnBackInvokedCallback(
    -- specifying priority
    -- your priority should be or greater than 0 if is not one of the OnBackInvokedDispatcher constants
    OnBackInvokedDispatcher.PRIORITY_OVERLAY --[[equals to 1000000]], ghostCallback
)

-- remove by callback instance
activity.unregisterOnBackInvokedCallback(ghostCallback)

-- remove by callback priority
--activity.unregisterOnBackInvokedCallback(priority)
