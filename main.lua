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

require"import"

activity.setContentView(loadlayout{
  TextView,
  text="Click me.",
  onClick=function(view)
    view.setText("You can go back.")
    --this method will not throw if tag or priority already exists, but will not replace
    require"backdispatcher".registerIfUnregistered(this,"back",function(dispatcher, context, tag)
      view.setText("Click me.")
      dispatcher.unregister(context, tag)
    end)
  end,
  gravity=Gravity.CENTER
})
