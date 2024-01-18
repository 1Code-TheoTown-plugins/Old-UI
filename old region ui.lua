local saveDrawing=function()
	local a,r,g,b=Drawing.getAlpha(),Drawing.getColor()
	local sx,sy=Drawing.getScale()
	return function(aa)
		aa=tonumber(aa) or 0
		return Drawing.setAlpha(a*aa)
	end,
	function(rr,gg,bb)
		rr,gg,bb=tonumber(rr) or 255,tonumber(gg) or 255,tonumber(bb) or 255
		return Drawing.setColor(rr*(r/255),gg*(g/255),bb*(b/255))
	end,
	function(x,y)
		x,y=tonumber(x) or 0,tonumber(y) or 0
		return Drawing.setScale(x*sx,y*sy)
	end
end
local function isGUIValid(self,...)
	if not istable(self) then return end
	local arg
	pcall(function(...) arg={GUI.isValid(self,...)} end,...)
	if istable(arg) then return table.unpack(arg) end
end
local GUI1C=setmetatable({},{
	__index=function(_,k) local t=GUI1C if istable(t) then return t[k] end return GUI[k] end,
	__newindex=function(_,k,v) local t=GUI1C if istable(t) then t[k]=v end GUI[k]=v end,
	__call=function(_,...) local t=GUI1C if istable(t) then return t(...) end return (...) end,
})
local function silentClick(...)
	local c=... if not istable(c) then return end
	local f=c.click if not isfunction(f) then return end
	local s,k=TheoTown.SETTINGS,"soundUILevel"
	local n,a=s[k] s[k]=0 a,s[k]={pcall(f,...)},n
	if not a[1] then return error(a[2]) end
	return select(2,table.unpack(a))
end

local settings
function script:lateInit()
	settings=Util.optStorage(TheoTown.getStorage(),draft:getId()..":settings")
	settings.ena=settings.ena or settings.ena==nil
end
function script:settings()
	return {{
		name="Enabled (region UI)",
		value=not not settings.ena,
		onChange=function(v) settings.ena=v end
	}}
end
local itr=function(self,f)
	local aa
	local el={}
	local function itr(self)
		for i=1,self:countChildren() do
			local c=self:getChild(i)
			local v
			if isfunction(f) then
				local e,em=pcall(function() v=f(c) end)
				if not e then el[#el+1]=tostring(em) end
			end
			if v~=nil and not v then aa=c return false end
			itr(c)
		end
	end
	for i=1,#el do error(el[i]) end
	itr(self)
	return aa
end
local itr2=function(...)
	local tbl={...}
	local e
	local ob={}
	itr(GUI.getRoot(),function(self)
		local icon
		if isfunction(self.getIcon) then pcall(function()
			icon=self:getIcon()
		end) end
		icon=tonumber(icon)
		local text=""
		if isfunction(self.getText) then pcall(function()
			text=self:getText()
		end) end
		text=tostring(text or text==nil and "")
		for _,v in pairs(tbl) do
			if isfunction(v) and v(self) then
				table.insert(ob,self)
			else
				if icon==v or text==TheoTown.translate(v) then table.insert(ob,self) end
			end
		end
	end)
	return table.unpack(ob)
end
function script:enterStage(s)
	if s~="RegionStage" or not settings.ena then return end
	local rt=GUI.getRoot()
	do
		local ob
		ob=itr2(Icon.MENU)
		if isGUIValid(ob) then
			GUI1C.addButton(rt,{
				icon=ob:getIcon(),
				onInit=function(self)
					self:setPosition(ob:getX(),ob:getY())
					self:setSize(ob:getWidth(),ob:getHeight())
					local id=ob:getId()
					ob:setId() self:setId(id)
				end,
				onClick=function() silentClick(ob) end,
				frameDefault=Draft.getDraft("$old_ui_if00"):getFrame(1),
				frameDown=Draft.getDraft("$old_ui_if00"):getFrame(1),
			})
			ob:setText("")
			ob:setIcon(0)
			ob:setSize(0,0)
			ob:setPosition(0,0)
			ob:setVisible(false)
		end
	end
	do
		local ob
		ob=itr2(Icon.HAMBURGER)
		if isGUIValid(ob) then
			GUI1C.addButton(rt,{
				icon=ob:getIcon(),
				onInit=function(self)
					self:setPosition(ob:getX(),ob:getY())
					self:setSize(ob:getWidth(),ob:getHeight())
					local id=ob:getId()
					ob:setId() self:setId(id)
				end,
				onUpdate=function(self) if isGUIValid(ob) then
					ob:setVisible(false)
					ob:setEnabled(false)
				end end,
				onClick=function(self) if isGUIValid(ob) then
					ob:setIcon(GUI1C(self):getIcon())
					ob:setText(GUI1C(self):getText())
					ob:setPosition(self:getX(),self:getY())
					ob:setSize(self:getWidth(),self:getHeight())
					ob:setVisible(true)
					ob:setEnabled(true)
					silentClick(ob)
					ob:setText("")
					ob:setIcon(0)
					ob:setPosition(0,0)
					ob:setSize(0,0)
					ob:setVisible(false)
					ob:setEnabled(false)
				end end,
				frameDefault=Draft.getDraft("$old_ui_if00"):getFrame(1),
				frameDown=Draft.getDraft("$old_ui_if00"):getFrame(1),
			})
			ob:setText("")
			ob:setPosition(0,0)
			ob:setSize(0,0)
			ob:setVisible(false)
			ob:setIcon(0)
		end
	end
	do
		do
			local ob
			do
				for i=1,rt:countChildren() do
					local c=rt:getChild(i)
					if c:getAbsoluteX()==0 and c:getAbsoluteY()==0
					and c:getWidth()>=20 and c:getHeight()>=20
					and c:getWidth()==c:getHeight() then
						ob=c
						break
					end
				end
			end
			if isGUIValid(ob) then
				GUI1C.addButton(rt,{
					w=30,h=30,x=-30,
					icon=Icon.CLOSE_BUTTON,
					onClick=function() silentClick(ob) end,
					frameDefault=Draft.getDraft("$old_ui_if00"):getFrame(1),
					frameDown=Draft.getDraft("$old_ui_if00"):getFrame(1),
				})
				ob:setText("")
				ob:setSize(0,0)
			end
		end
		if false then
			local ob
			ob=itr2("stage_region_online")
			if isGUIValid(ob) then
				GUI1C.addButton(rt,{
					w=30,h=30,x=-30,y=31,
					icon=ob:getIcon(),
					onClick=function() silentClick(ob) end,
					frameDefault=Draft.getDraft("$old_ui_if00"):getFrame(1),
					frameDown=Draft.getDraft("$old_ui_if00"):getFrame(1),
				})
				ob:setText("")
				ob:setSize(0,0)
			end
		end
		do
			local ob
			ob=itr2("stage_account_title","dialog_onlinenotifications_title")
			if isGUIValid(ob) then
				ob:setText("")
				ob:setSize(0,0)
				ob:setPosition(0,0)
				ob:setVisible(false)
				ob:setEnabled(false)
				ob:getParent():setSize(0,0)
				ob:getParent():setPosition(0,0)
				ob:getParent():setVisible(false)
				GUI1C.addButton(rt,{
					w=30,h=30,x=-30,y=31,
					icon=ob:getIcon(),
					onInit=function(self) if isGUIValid(ob) then self:setChildIndex(ob:getChildIndex()+2) end end,
					onUpdate=function(self) if isGUIValid(ob) then
						ob:setChildIndex(self:getChildIndex())
						ob:setVisible(false) ob:setEnabled(false)
					else self:delete() end end,
					onClick=function() if isGUIValid(ob) then ob:setEnabled(true) silentClick(ob) ob:setEnabled(false) end end,
					frameDefault=Draft.getDraft("$old_ui_if00"):getFrame(1),
					frameDown=Draft.getDraft("$old_ui_if00"):getFrame(1),
				})
			end
		end
	end
	
	local oaa,aa
	do
		local ob
		ob=itr2("createregion_title","stage_region_online","region_individualcities")
		if isGUIValid(ob) then
			oaa=ob
			ob:setSize(0,0)
			ob:getParent():setSize(0,0)
			ob:getParent():setVisible(false)
			aa=GUI1C(rt):addCanvas {
				w=0,h=0,
				onInit=function(self) if isGUIValid(oaa) then self:setChildIndex(oaa:getChildIndex()+2) end end,
				onUpdate=function(self) if isGUIValid(oaa) then
					oaa:setChildIndex(self:getChildIndex())
					oaa:setVisible(false)
				end end,
			}
			aa:setTouchThrough(true)
		end
	end
	if istable(aa) then
		do
			local ob
			ob=itr2("createregion_title")
			if isGUIValid(ob) then
				GUI1C(aa):addButton {
					w=30,h=30,
					icon=ob:getIcon(),
					text=ob:getText(),
					onUpdate=function(self) if not isGUIValid(ob) then self:delete() return end end,
					onClick=function() silentClick(ob) end,
				}
				ob:setText("")
				ob:setSize(0,0)
			end
		end
		do
			local ob
			ob=itr2("stage_region_online")
			if isGUIValid(ob) then
				GUI1C(aa):addButton {
					w=30,h=30,
					icon=ob:getIcon(),
					text=ob:getText(),
					onUpdate=function(self) if not isGUIValid(ob) then self:delete() return end end,
					onClick=function() silentClick(ob) end,
				}
				ob:setText("")
				ob:setSize(0,0)
			end
		end
		do
			local ob
			ob=itr2("region_individualcities")
			if isGUIValid(ob) then
				GUI1C(aa):addButton {
					w=30,h=30,
					icon=ob:getIcon(),
					text=ob:getText(),
					onUpdate=function(self) if not isGUIValid(ob) then self:delete() return end end,
					onClick=function() silentClick(ob) end,
				}
				ob:setText("")
				ob:setSize(0,0)
			end
		end
		local w,h=0,0 for i=1,aa:countChildren() do
			local c=aa:getChild(i)
			c:setPosition(c:getX(),h)
			h=h+c:getHeight()+1
			w=math.max(w,c:getWidth())
			aa:setSize(aa:getWidth(),h)
		end
		aa:setSize(w,aa:getHeight())
		for i=1,aa:countChildren() do
			local c=aa:getChild(i)
			c:setSize(w,c:getHeight())
		end
	end
	
	do
		local ob
		ob=itr2(Icon.PREVIOUS)
		if isGUIValid(ob) then
			GUI1C.addButton(rt,{
				w=30,h=30,x=-61,y=-30,
				icon=ob:getIcon(),
				onInit=function(self) if isGUIValid(ob) then self:setChildIndex(ob:getChildIndex()+2) end end,
				onUpdate=function(self) if isGUIValid(ob) then
					ob:setChildIndex(self:getChildIndex())
					ob:setVisible(false) ob:setEnabled(false)
				end end,
				onClick=function() if isGUIValid(ob) then ob:setEnabled(true) silentClick(ob) ob:setEnabled(false) end end,
			})
			ob:setText("") ob:setIcon(0)
			ob:setSize(0,0)
			ob:setPosition(0,0)
			ob:setVisible(false)
			ob:setIcon(0)
		end
	end
	do
		local ob
		ob=itr2(Icon.NEXT)
		if isGUIValid(ob) then
			GUI1C.addButton(rt,{
				w=30,h=30,x=-30,y=-30,
				icon=ob:getIcon(),
				onInit=function(self) if isGUIValid(ob) then self:setChildIndex(ob:getChildIndex()+2) end end,
				onUpdate=function(self) if isGUIValid(ob) then
					ob:setChildIndex(self:getChildIndex())
					ob:setVisible(false) ob:setEnabled(false)
				end end,
				onClick=function() if isGUIValid(ob) then ob:setEnabled(true) silentClick(ob) ob:setEnabled(false) end end,
			})
			ob:setText("") ob:setIcon(0)
			ob:setSize(0,0)
			ob:setPosition(0,0)
			ob:setVisible(false)
			ob:setIcon(0)
		end
	end
	
	do
		local ob
		for i=1,GUI.getRoot():countChildren() do
			local c=GUI.getRoot():getChild(i)
			local icon
			if isfunction(c.getIcon) then pcall(function() icon=c:getIcon() end) end
			if icon==-1 and c:getX()==31 then
				ob=c
			end
		end
		if isGUIValid(ob) then
			--ob:setVisible(false)
			local rn=ob:getChild(3)
			local ed=ob:getChild(4)
			local ri=ob:getChild(5)
			GUI1C.addCanvas(rt,{
				w=ob:getWidth(),
				h=ob:getHeight(),
				x=ob:getX(),
				y=ob:getY(),
				onDraw=function(self,x,y,w,h)
					local setAlpha,setColor=saveDrawing()
					setAlpha(0.3) setColor(0,0,0)
					--Drawing.drawRect(x,y,w,h)
					setAlpha(1) setColor(255,255,255)
				end,
				onInit=function(self)
					self:setChildIndex(ob:getChildIndex()+2)
					local function addLabel(tbl,...)
						local tbl2={} for k,v in pairs(tbl) do tbl2[k]=v end
						tbl2.onInit=function(self,...)
							self:setTouchThrough(true)
							self:setEnabled(false)
							for _=1,self:countChildren() do self:getChild(1):delete() end
							local p=self
							GUI1C(self):addCanvas {
								onInit=function(self)
									self:setTouchThrough(true)
								end,
								onUpdate=function(self)
									self:setSize(p:getWidth(),p:getHeight())
								end,
								onDraw=function(self,x,y,w,h)
									local text,font=GUI1C(p):getText(),GUI1C(p):getFont()
									local tw,th=Drawing.getTextSize(text,font)
									local function draw(i,ii) Drawing.drawText(text,x+i,y+ii,font) end
									local _,setColor=saveDrawing()
									setColor(0,0,0)
									local s=1
									draw(-s,0) draw(0,-s) draw(s,0) draw(0,s)
									setColor(255,255,255)
									draw(0,0)
								end
							}
							if isfunction(tbl.onInit) then return tbl.onInit(self,...) end
						end
						tbl2.w=0
						tbl2.frameDefault=Draft.getDraft("$old_ui_if00"):getFrame(1)
						tbl2.frameDown=Draft.getDraft("$old_ui_if00"):getFrame(1)
						return GUI1C(self):addButton(tbl2,...)
					end
					local ptext addLabel {
						h=rn:getHeight(),
						onInit=function(self) GUI1C(self):setFont(Font.BIG) end,
						onUpdate=function(self)
							local text=rn:getText()
							if ptext==text then return end
							GUI1C(self):setText(text)
							ptext=text
						end
					} 
					GUI1C(self):addCanvas {
						w=ed:getWidth(),h=ed:getHeight(),y=2,
						onUpdate=function(self)
							local tw=Drawing.getTextSize(ptext or "",Font.BIG)
							self:setPosition(tw,self:getY())
						end,
						onDraw=function(self,x,y,w,h)
							local _,_,setScale=saveDrawing()
							setScale(0.5,0.5)
							local sx,sy=Drawing.getScale()
							local icon=Icon.EDIT
							local iw,ih=Drawing.getImageSize(icon)
							Drawing.drawImage(icon,x+(w-iw*sx)/2,y+(h-ih*sy)/2)
							setScale(1,1)
						end,
						onClick=function() ed:click() end,
					}
					local ptext addLabel {
						y=20,h=ri:getHeight(),
						onUpdate=function(self)
							local text=ri:getText()
							if ptext==text then return end
							GUI1C(self):setText(text)
							ptext=text
						end
					} 
					self:setTouchThrough(true)
				end,
				onUpdate=function(self)
					ob:setChildIndex(self:getChildIndex())
					local tw0=Drawing.getTextSize(rn:getText(),Font.BIG)
					tw0=tw0+20
					local tw1=Drawing.getTextSize(ri:getText())
					local w=math.max(tw0,tw1)
					self:setSize(w,self:getHeight())
				end
			})
			ob:setPosition(-1000,-1900)
		end
	end
	Runtime.postpone(function() for _,adtd in pairs{"$adt_adt_icon00","$rwadt_1c_icon00"} do
		local adtd=Draft.getDraft(adtd)
		if istable(adtd) then
			local ob
			ob=itr2(adtd:getFrame(1))
			if isGUIValid(ob) then
				local id=ob:getId()
				ob:setId()
				GUI1C.addButton(rt,{
					id=id,
					w=30,h=30,
					icon=ob:getIcon(),
					text=ob:getText(),
					onInit=function(self) if isGUIValid(ob) then
						self:setPosition(ob:getX(),ob:getY())
						self:setChildIndex(ob:getChildIndex()+2)
						ob.orig=self.orig
					end end,
					onUpdate=function(self) if isGUIValid(ob) then
						ob:setChildIndex(self:getChildIndex())
						ob:setVisible(false) ob:setEnabled(false)
					else self:delete() end end,
					onClick=function() if isGUIValid(ob) then ob:setEnabled(true) silentClick(ob) ob:setEnabled(false) end end,
					frameDefault=Draft.getDraft("$old_ui_if00"):getFrame(1),
					frameDown=Draft.getDraft("$old_ui_if00"):getFrame(1),
				})
				ob:setText("") ob:setIcon(0)
				ob:setSize(0,0)
				ob:setPosition(0,0)
				ob:setVisible(false)
				ob:setEnabled(false)
			end
		end
	end end)
end