--[[
Copyright (C) 2018-2022 The AGYS Windmill Open Source Project

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

--see OnBackInvokedCallback.lua also

require"import"

activity.setContentView(loadlayout{
  TextView,
  text="Click me.",
  onClick=function(view)
    view.setText("You can go back.")

    local screenWidth = luajava.bindClass"android.content.res.Resources".getSystem().getDisplayMetrics().widthPixels
    local maxXShift = screenWidth / 20

    --NOTICE
    --onBackStarted, onBackProgressed, onBackCancelled only available in Android 14 and later
    --if you pass these value below 14, they will be ignored

    require"backdispatcher".registerIfUnregistered(this,"back",{
      onBackInvoked=function(dispatcher, context, tag)
        view.setText("Click me.")
        dispatcher.unregister(context, tag)
      end,
      onBackStarted=function()
        --a back gesture started
      end,
      onBackProgressed=function(backEvent)
        local progress = backEvent.getProgress()
        local scale = 1 - progress * 0.1
        local translate = progress * maxXShift
        view.setTranslationX(backEvent.getSwipeEdge() == backEvent.EDGE_LEFT and translation or -translation)
          .setScaleX(scale).setScaleY(scale)
      end,
      onBackCancelled=function()
        --reset view appearence

        --TODO
        --animate
        view.setScaleX(1).setScaleY(1)
          .setTranslationX(0)
      end
    })

  end,
  gravity=17--Gravity.CENTER
})
