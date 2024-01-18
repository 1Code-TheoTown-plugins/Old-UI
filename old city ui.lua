pcall(function() City.rebuildUI() end)
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
local function getAX(self) return self:getAbsoluteX() end
local function getAY(self) return self:getAbsoluteY() end
local function getCAX(self) local p=self:getPadding() return self:getAbsoluteX()+p end
local function getCAY(self) local _,p=self:getPadding() return self:getAbsoluteY()+p end
local function setAXY(self,x,y,...)
	x,y=tonumber(x) or 0,tonumber(y) or 0
	local p=self:getParent()
	return self:setPosition(x-getCAX(p),y-getCAY(p),...)
end
local function setAX(self,x,...) return setAXY(self,x,getAY(self),...) end
local function setAY(self,y,...) return setAXY(self,getAX(self),y,...) end
local function getAXY(self,...) return getAX(self,...),getAY(self,...) end
local function getCAXY(self,...) return getCAX(self,...),getCAY(self,...) end
local function getCW(self) return self:getClientWidth() end
local function getCH(self) return self:getClientHeight() end
local function getCWH(self) return self:getClientWidth(),self:getClientHeight() end
local function getW(self) return self:getWidth() end
local function getH(self) return self:getHeight() end
local function getWH(self) return self:getWidth(),self:getHeight() end
local isTouchPointInFocus=function(self,...)
	return (function(...)
		local tn,tx,ty=tonumber,...
		local x,y,w,h=self:getAbsoluteX(self),self:getAbsoluteY(self),self:getWidth(self),self:getHeight(self)
		if not (tn(tx) and tn(ty)) then return end
		if tx>=x and tx<x+w and ty>=y and ty<y+h then return ... end
	end)(self:getTouchPoint(...))
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
local settings
function script:lateInit()
	settings=Util.optStorage(TheoTown.getStorage(),draft:getId()..":settings")
	settings.ena=settings.ena or settings.ena==nil
	settings.rbos=tonumber(settings.rbos) or 0
end
local ths=function(s)
	do
		s=("%d"):format((math.modf(tonumber(s))))
		local k
		repeat
			s,k=s:gsub("(-?%d+)(%d%d%d)","%1,%2")
		until k==0
		return s
	end
	local s3=s
	pcall(function()
		local s2,mn,t="","",{}
		if tonumber(s) then
			if tonumber(s)%1~=0 then
				local ts=tostring
				local s4,s5=ts(s),ts(s):reverse()
				while not s4:endsWith(".") do s4=s4:sub(1,-2) end
				while not s5:endsWith(".") do s5=s5:sub(1,-2) end
				s,s2=s4:sub(1,-2),s5:sub(1,-2)
			end
			--s,s2=math.modf(s)
			if (tonumber(s) or 0)<0 then mn="-" s=tostring(s):gsub(mn,"",1)end
			if (tonumber(s2) or 0)==0 then s2="" end
		end
		s=tostring(s):reverse()
		for v in string.gmatch(s,".") do table.insert(t,v)end
		for k in pairs(t) do if k%4==0 then table.insert(t,k,",") end end
		s3=mn..(table.concat(t):reverse()..(tostring(s2):gsub("0","",1)))
	end)
	return s3
end
local ths2=(function()
	local b52=(function()
		local l,s={},"abcdefghijklmnopqrstuvwxyz"
		s=s..s:upper()
		for c in s:gmatch(".") do l[#l+1]=c end
		local f=function(n,a)
			n=math.modf(n)%(52*52)
			local on=n
			local i,t=1,{}
			repeat
				t[i]=l[1+(n%52)]
				n=math.modf(n/52)
				i=i+1
			until n<=0
			t=table.concat(t)
			if a then t=t..("a"):rep(2-#t) end
			return t
		end
		return function(n)
			n=math.modf(n)
			local t,i,m={},1,52*52
			repeat
				local nn=math.modf(n/m)-(1/m)
				t[i],i,n=f(n,nn>0),i+1,nn
			until n<=0
			return table.concat(t):reverse()
		end
	end)()
	return function(s)
		if not TheoTown.SETTINGS.shortMoney then return ths(s) end
		s=math.modf(tonumber(s))
		local l=math.log(s,1000)
		l=math.modf(math.abs(l))
		if l>-1 and l<1 then return ths(s) end
		local s5=""
		local s0={"K","M","B","T"}
		if l<=#s0 then
			s5=s0[l]
		else
			l=l-#s0-1
			s5=b52(l)
			s5=("a"):rep(2-#s5)..s5
		end
		while s>=1000 do
			s=s/1000
		end
		s=("%.f"):format(s):sub(1,4)
		if s:endsWith(".") then s=s:sub(1,-2) end
		return s..s5
	end
end)()
local fd=function(p,b)
	local er={}
	local c1
	local fd fd=function(p)
		local b0=function(c)
			local b0
			local er0,er1=pcall(function() b0=b(c) end)
			if not er0 then table.insert(er,er1) end
			if b0 then c1=c return end
		end
		if b0(p) then return end
		for ii=1,p:countChildren() do
			local c0=p:getChild(ii)
			if b0(c0) then return end
			fd(c0)
		end
	end
	fd(p)
	local i=1
	return c1,(function()
		if not i then return (nil)() end i=nil
		Runtime.postpone(function()
			for _,v in pairs(er) do assert(nil,v) end
		end)
	end)()
end
local sidebar
local saec,saect
local function silentClick(...)
	local c=... if not istable(c) then return end
	local f=c.click if not isfunction(f) then return end
	local s,k=TheoTown.SETTINGS,"soundUILevel"
	local n,a=s[k] s[k]=0 a,s[k]={pcall(f,...)},n
	if not a[1] then return error(a[2]) end
	return select(2,table.unpack(a))
end
local function showDialog(mc,mc0)
	if not isGUIValid(mc) then return end
	mc:setVisible(true)
	mc:setChildIndex(mc:getParent():countChildren())
	local s=TheoTown.SETTINGS.uiAnimations
	if not s then return end
	if not isGUIValid(mc0) then return end
	do
		local mc1=mc0:getParent()
		local iv0,iv1=mc.isVisible,mc1.isVisible
		local sv,i0=mc.setVisible,iv0(mc)
		local a0=i0==iv1(mc1)
		sv(mc,not i0) local a1=iv0(mc)==iv1(mc1)
		sv(mc,i0) mc1,iv0,iv1,i0,i1,sv=nil
		if a0~=a1 then return end
	end
	local y=mc0:getY()
	local t=Runtime.getTime()
	local function e()
		if not isGUIValid(mc) then e,y,t,s,mc0,mc=nil return end
		if not isGUIValid(mc0) then e,y,t,s,mc0,mc=nil return end
		if not mc:isVisible() then mc0:setPosition(mc0:getX(),y) e,y,t,s=nil return end
		local tt=(Runtime.getTime()-t)/50
		tt=s and math.max(0,math.min(1,tt)) or 1
		mc0:setPosition(mc0:getX(),(mc:getHeight()*(1-tt))+(y*tt))
		if tt>=1 then e,y,t,s,tt,mc0,mc=nil return end
		tt=nil Runtime.postpone(function() e() end)
	end e()
end
function script:buildCityGUI() local er0,er1=pcall(function()
	if not settings.ena then return end
	sidebar=GUI.get("sidebarLine")
	local function addButton(self,tbl,...)
		local tbl2={} for k,v in pairs(tbl) do tbl2[k]=v end
		do
			local w=self:getClientWidth()
			tbl2.width=tonumber(tbl.width) or tonumber(tbl.w) or w
			tbl2.height=tonumber(tbl.height) or tonumber(tbl.h) or w
			tbl2.w=tonumber(tbl.w) or tonumber(tbl.width) or w
			tbl2.h=tonumber(tbl.h) or tonumber(tbl.height) or w
		end
		local a1
		tbl2.onInit=function(self,...)
			pcall(function() self:getChild(2):delete() end)
			a1=GUI1C(self):addCanvas {
				onInit=function(self) self:setTouchThrough(true) end,
				onUpdate=function(self)
					a1=self
					local p=self:getParent()
					self:setPosition(0,0)
					self:setSize(p:getClientWidth(),p:getClientHeight())
				end,
				onDraw=function(self,x,y,w,h,...)
					a1=self local er={}
					local p=self:getParent()
					local tp=p:getTouchPoint()
					local ip=tbl.isPressed
					if isfunction(ip) then table.insert(er,{pcall(function() ip=ip(self) end)}) end
					--if (tp and not ip) or (ip and not tp) then y=y+0.5 else y=y-0.5 end
					local setAlpha,setColor,setScale=saveDrawing()
					setAlpha((function()
						local a=tbl.a
						if isfunction(a) then table.insert(er,{pcall(function() a=a(self) end)}) end
						return tonumber(a) or 1
					end)())
					if ip or (tp or p:isMouseOver()) then setColor(255*0.7,255*0.7,255*0.7) end
					local icon=GUI1C(p):getIcon()
					if icon>=1 then
						local iw,ih=Drawing.getImageSize(icon)
						local hx,hy=Drawing.getImageHandle(icon)
						local s=1 --math.min(1,w/iw,h/ih)
						setScale(s,s)
						local sx,sy=Drawing.getScale()
						Drawing.drawImage(icon,x+(hx*sx)+(w-(iw*sx))/2,y+(hy*sy)+(h-(ih*sy))/2)
						setScale(1,1)
					end
					local arg
					do local f=tbl.onDraw if isfunction(f) then table.insert(er,{pcall(function(...) arg={f(self,x,y,w,h,...)} end,...)}) end end
					setColor(255,255,255) setAlpha(1)
					for _,v in pairs(er) do assert(table.unpack(v)) end
					if istable(arg) then return table.unpack(arg) end
				end
			}
			local f=tbl.onInit if isfunction(f) then return f(self,...) end
		end
		tbl2.onUpdate=function(self,...)
			if not istable(a1) then self:delete() return end
			if not a1:isValid() then self:delete() return end
			if not a1:isVisible() then a1:setVisible(true) self:setVisible(false) end
			local f=tbl.onUpdate if isfunction(f) then return f(self,...) end
		end
		tbl2.isPressed=function(self)
			local er0,er1,isPressed=true;
			(function(f) if isfunction(f) then isPressed=f() end end)(tbl.isPressed)
			local tp=not not self:getTouchPoint()
			return (tp and not isPressed) or (isPressed and not tp)
		end
		tbl2.frameDefault=Draft.getDraft("$old_ui_if00"):getFrame(1)
		tbl2.frameDown=Draft.getDraft("$old_ui_if00"):getFrame(1)
		do return GUI1C.addButton(self,tbl2,...) end
	end
	local sbo={}
	
	do
		sidebar:setSize(25,sidebar:getHeight())
		local b0i=GUI.get("cmdBuild"):getChildIndex()+1
		local rf0
		do
			local id="cmdRCI"
			local oc=GUI.get(id)
			oc:setId()
			oc:setSize(oc:getWidth(),0)
			Runtime.postpone(function() oc:setSize(0,0) end)
			oc:setVisible(false) oc:delete()
			table.insert(sbo,addButton(sidebar,{
				id=id,w=25,h=25,
				onClick=function() City.openInfo(City.INFO_RCI) end,
				onInit=function(self) self:setChildIndex(2) end,
				onDraw=function(self,x,y,w,h)
					if false then
						x,y=x+w/2,y+h/2
						w,h=w/1.5,h/1.2
						x,y=x-w/2,y-h/2
					end
					local _,setColor=saveDrawing()
					for i,k in pairs{"res","com","ind"} do
						local color={{0,255,0},{0,0,255},{255,255,0}}
						setColor(table.unpack(color[i]))
						local d=0
						do
							local v={}
							for i=0,2 do
								v[i+1]=City.getFunVar("demand_"..k..i)
							end
							table.sort(v,function(a,b) return a>b end)
							v=v[1]+(v[2]+v[3])/3
							local i0=v/300
							if i0<0 then i0=-i0 end
							i0=math.min(i0,1)
							d=d+(v/((30*(1-i0))+(400*i0)))
						end
						local x,w=x+((w/3)*(i-1)),w/3
						--x=x+w/2 w=w-1 x=x-w/2
						if false then
							local setAlpha,setColor=saveDrawing()
							setAlpha(0.3) setColor(0,0,0)
							Drawing.drawRect(x,y,w,h)
							setAlpha(1) setColor(255,255,255)
						end
						d=math.max(-1,math.min(1,d))
						local function draw(x,y,w,h)
							h=math.abs(h)
							Drawing.drawRect(x,y,w,h)
							local sx,sy=math.min(1,w/2),math.min(1,h/2)
							setColor(0,0,0)
							Drawing.drawRect(x,y,sx,h)
							Drawing.drawRect(x,y,w,sy)
							Drawing.drawRect(x+w-sx,y,sx,h)
							Drawing.drawRect(x,y+h-sy,w,sy)
						end
						draw(x,y+(h/2)-((h/2)*math.max(0,d)),w,(h/2)*d)
					end
					setColor(0,0,0)
					Drawing.drawLine(x,y+h/2,x+w,y+h/2,0.5)
					setColor(255,255,255)
				end,
			}))
		end
		do
			local mc={}
			local v={
				TheoTown.translate("draftselector_titleremove"),
				TheoTown.translate("draftselector_titleview"),
				TheoTown.translate("draftselector_titlealert"),
			}
			do mc[1],mc[2],mc[3]=(function()
				local tbl={}
				fd(GUI.getRoot(),function(c)
					local f=GUI1C(c).getText
					if type(f)~="function" then return end
					local tx pcall(function() tx=f(c) end)
					if tx==v[1] or tx==v[2] or tx==v[3] then
						local c0=c
						local rt=GUI.getRoot()
						while c0:getParent()~=rt do c0=c0:getParent() end
						if tx==v[1] then tbl[1]=c0 end
						if tx==v[2] then tbl[2]=c0 end
						if tx==v[3] then tbl[3]=c0 end
					end
				end)
				return tbl[1],tbl[2],tbl[3]
			end)() end
			local function rf(i)
				local v=mc[i]
				if istable(v) then v=GUI.getChild(v:getParent(),v:getChildIndex()+1) end
				mc[i]=v return v
			end
			rf0=function(a)
				for i in ipairs(mc) do
					local c=rf(i)
					if isGUIValid(c) then
						c:setVisible(false)
						if a then
							local cc=c:getParent():countChildren()
							c:setChildIndex(math.min(c:getChildIndex()+1,cc-1))
						end
					end
				end
				local c=GUI.get("roottoolbar")
				if isGUIValid(c) then c:setVisible(false) end
			end
			do
				local rt=GUI.getRoot()
				--local oc=rt:getChild(1)
				local ti=0
				rt:addCanvas {
					onInit=function(self)
						self:setTouchThrough(true)
						local p=self:getParent()
						local pl,pt=self:getPadding()
						self:setPosition(-pl,-pt)
						self:setSize(p:getWidth(),p:getHeight())
						self:setChildIndex(2)
						--if istable(oc) then oc=GUI.getChild(GUI.getParent(oc),GUI.getChildIndex(oc)+1) end
						--if isGUIValid(oc) then self:setChildIndex(oc:getChildIndex()+1) end
					end,
					onUpdate=function(self)
						self:setTouchThrough(true)
						--if istable(oc) then oc=GUI.getChild(GUI.getParent(oc),GUI.getChildIndex(oc)+1) end
						--if isGUIValid(oc) then self:setChildIndex(oc:getChildIndex()+1) end
						if self:getTouchPoint() then
							local x,y,fx,fy=self:getTouchPoint()
							if ti==0 then ti=1 end
							if ti<2 and (x~=fx or y~=fy) then ti=2 end
						else ti=0 end
					end,
					onClick=function() if ti<2 then rf0() end end
				}
			end
			
			local pi={}
			
			for i,v in ipairs {
				"RemoveCollector",
				"ViewMarkerCollector",
				"AlertCollector",
			}
			do pi[i]=GUI.get("cmd"..v):getChildIndex()+1 end
			for i,v in ipairs {
				"RemoveCollector",
				"ViewMarkerCollector",
				"AlertCollector",
			}
			do
				local id="cmd"..v
				local oc=GUI.get(id)
				oc:setVisible(false) oc:delete()
				table.insert(sbo,addButton(sidebar,{
					icon=oc:getIcon(),
					id=id,w=25,h=25,
					isPressed=function()
						local mc=rf(i)
						if isGUIValid(mc) then return mc:isVisible() end
					end,
					onClick=function()
						local mc=rf(i)
						local iv
						if isGUIValid(mc) then iv=mc:isVisible() end
						rf0(true)
						if isGUIValid(mc) then
							iv=not iv mc:setVisible(iv)
							if iv then
								mc:setChildIndex(mc:getParent():countChildren())
							end
						end
					end,
					onInit=function(self)
						self:setChildIndex(pi[i])
						local mc=rf(i)
						if not isGUIValid(mc) then return end
						local x=getAX(self)
						if TheoTown.SETTINGS.rightSidebar then
							x=x-getW(mc)
						else
							x=x+getW(self)
						end
						setAX(mc,x)
					end,
				}))
			end
		end
		do
			local id="cmdBuild"
			local oc=GUI.get(id)
			oc:setId()
			oc:setSize(oc:getWidth(),0)
			Runtime.postpone(function() oc:setSize(0,0) end)
			setAX(oc,-2^31)
			while oc:countChildren()>=1 do oc:getChild(1):delete() end
			--oc:setChildIndex(1)
			--oc:setChildIndex(oc:getParent():countChildren())
			table.insert(sbo,addButton(sidebar,{
				id=id,w=25,h=25,
				isPressed=function()
					local c=GUI.get("roottoolbar")
					if not isGUIValid(c) then return end
					return c:isVisible()
				end,
				onClick=function()
					local c=GUI.get("roottoolbar")
					if not isGUIValid(c) then return end
					if isfunction(rf0) then rf0() end
					c:setVisible(not c:isVisible())
					silentClick(GUI.get("cmdCloseTool"))
				end,
				onInit=function(self) self:setChildIndex(b0i+1) end,
				onUpdate=function(self)
					if not istable(oc) then oc=nil self:delete() return end
					oc=GUI.getChild(oc:getParent(),oc:getChildIndex()+1)
					if not isGUIValid(oc) then oc=nil self:delete() return end
					GUI1C(self):setIcon(oc:getIcon())
				end
			}))
		end
		for i=1,2 do
			local id="cmd"..({"Region","Menu"})[i]
			local oc=GUI.get(id)
			oc:setId()
			oc:setSize(oc:getWidth(),0)
			Runtime.postpone(function() oc:setSize(0,0) end)
			local function a() return TheoTown.SETTINGS.autoSave end
			local d={(function()
				if i==1 and a() then return end
				silentClick(oc) local rt=GUI.getRoot()
				local c=rt:getChild(rt:countChildren())
				c:setVisible(false)
				return c,c:getChild(1)
			end)()}
			local p
			local aa=true
			if i==1 then
				p=GUI.get("cmdDate"):getParent():getParent()
				local a=p~=GUI.get("cmdBudget"):getParent():getParent()
				p=p:getLastPart()
				local mm=GUI.get("cmdMinimap")
				local s=settings
				local ss=TheoTown.SETTINGS
				aa=ss.rightSidebar or (ss.leftMinimap or a or s.rbos==1) and not (s.rbos<0 or s.rbos>1)
			end
			if aa then p=sidebar:getLastPart() end
			
			addButton(p,{
				id=id,w=25,h=25,
				icon=i==1 and Icon.REGION or oc:getIcon(),
				a=i==2 and function() return TheoTown.SETTINGS.hideUI and 0.5 or nil end or nil,
				onClick=function()
					if i==2 then
						TheoTown.SETTINGS.hideUI=false
					elseif a() then
						--do City.exit(true) return end
						saect=setmetatable({},{__mode="kv"})
						local rt=GUI.getRoot()
						for i=1,rt:countChildren() do
							saect[#saect+1]=rt:getChild(i)
						end
						City.save(true) saec=0
					end
					do showDialog(table.unpack(d)) return end
				end,
				onInit=function(self)
					if i==1 then table.insert(sbo,self) end
					if not aa then
						self:setPosition(self:getX(),self:getY()-5)
					else
						self:setChildIndex(oc:getChildIndex()+1)
					end
				end,
			})
			oc:setVisible(false) oc:delete()
		end
	end
	
	local setW=function(self,w) return self:setSize(w,self:getHeight()) end
	local setWH=function(self,w,h) return self:setSize(w,h) end
	local addW=function(self,w) return self:setSize(self:getWidth()+w,self:getHeight()) end
	local setH=function(self,h) return self:setSize(self:getWidth(),h) end
	local getW=function(self) return self:getWidth() end
	local getH=function(self) return self:getHeight() end
	local getCH=function(self) return self:getClientHeight() end
	local setX=function(self,x) return self:setPosition(x,self:getY()) end
	local setY=function(self,y) return self:setPosition(self:getX(),y) end
	
	local function drawPanel(self,x,y,w,h)
		local setAlpha,setColor=saveDrawing()
		setAlpha(0.6) setColor(0,0,0)
		Drawing.drawRect(x,y,w,h)
		setAlpha(1) setColor(255,255,255)
	end
	local function addItem(ct)
		local ct2={}
		local gw=0
		return function(self,tbl)
			local r=function(self)
				for k in pairs(ct2) do ct2[k]=nil end
				gw=0
				do local i=1 while i<=#ct do
					local tn=tonumber
					local nc,c,w,h,sc={},ct[i]
					local vsb=(function(v) if isfunction(v) then v=v() end return v or v==nil end)(c.visible)
					if vsb then
						w=(function(v) if isfunction(v) then v=v() end return v end)(c.width)
						w=tn(w) or (function(v) if isfunction(v) then v=v() end return v end)(c.w)
						h=(function(v) if isfunction(v) then v=v() end return v end)(c.height)
						h=tn(h) or (function(v) if isfunction(v) then v=v() end return v end)(c.h)
						sc=(function(v) if isfunction(v) then v=v() end return v end)(c.scale)
						sc=(function()
							local sx,sy=1,1
							if isnumber(sc) then
								sx,sy=sc,sc
							elseif istable(sc) then
								sx,sy=sc[1],sc[2]
							end
							sx,sy=tn(sx) or 1,tn(sy) or 1
							return {sx,sy}
						end)()
						local v=(function(v) if isfunction(v) then return v() end return v end)(c.value)
						nc.cl=(function()
							local r,g,b=(function(f) if isfunction(f) then return f(v) end end)(c.color)
							return {tn(r) or 255,tn(g) or 255,tn(b) or 255}
						end)()
						if v~=nil then
							local ww,hh=w,h
							if c.type<1 then
								v=tn(v) or 0
								ww,hh=Drawing.getImageSize(v)
							else
								local t=c.getText
								if isfunction(t) then v=t(v) end
								v=tostring(v or v==nil and "")
								ww,hh=Drawing.getTextSize(v,Font.SMALL)
							end
							w,h=tn(w) or ww,tn(h) or hh
						end
						nc.onDraw=c.onDraw
						w,h=(tn(w) or 0)*sc[1],(tn(h) or 0)*sc[2]
						gw,nc.w,nc.h,nc.v,ct2[i]=gw+w,w,h,v,nc
					end
					i=i+1
				end end
				local pl,_,pr=self:getPadding()
				setW(self,gw+pl+pr)
			end
			local tbl2={} for k,v in pairs(tbl) do tbl2[k]=v end
			tbl2.onInit=(function(f) return function(self,...) self:setPadding(5,2,5,2) r(self) if isfunction(f) then return f(self,...) end end end)(tbl.onInit)
			tbl2.onUpdate=(function(f) return function(...) r(...) if isfunction(f) then return f(...) end end end)(tbl.onUpdate)
			tbl2.onClick=(function(f) return function(...) if isfunction(f) then return f(...) end end end)(tbl.onClick)
			tbl2.onDraw=function(self,x,y,w,h)
				drawPanel(self,x,y,w,h)
				do local pl,pt,pr,pb=self:getPadding() x,y,w,h=x+pl,y+pt,w-pl-pr,h-pt-pb end
				local _,setColor,setScale=saveDrawing()
				for i=1,#ct2 do
					local c=ct2[i]
					if istable(c) then
						local w0,h0,v=c.w,c.h,c.v
						local w1,h1=w0,h0
						setColor(table.unpack(c.cl))
						if type(v)=="number" then
							w1,h1=Drawing.getImageSize(v)
						elseif type(v)=="string" then
							w1,h1=Drawing.getTextSize(v,Font.SMALL)
						end
						local sx,sy=w0/w1,h0/h1
						setScale(sx,sy)
						if type(v)=="number" then
							Drawing.drawImage(v,x,y+(h-h0)/2)
						elseif type(v)=="string" then
							Drawing.drawText(v,x,y+h/2,Font.SMALL,0,0.5)
						end
						setScale(1,1)
						local f=c.onDraw
						if isfunction(f) then f(x,y+(h-h0)/2,w0,h0) end
						setColor(255,255,255) x=x+w0
					end
				end
			end
			return GUI1C.addCanvas(self,tbl2)
		end,
		function() return gw end
	end
	
	do
		local c=GUI.get("cmdCityName")
		local p=c:getParent()
		c:delete()
		addItem({
			{type=1,value=City.getName},
			{type=0,value=Icon.INHABITANTS},
			{type=1,value=City.getPeople,getText=function(v) return ths(v) end},
		})
		(p,{
			id="cmdCityName",
			onClick=function(self) City.openInfo(City.INFO_GENERAL) end,
		}):setChildIndex(1)
	end
	do
		local c=GUI.get("cmdRating")
		local p=c:getParent()
		c:delete()
		local r,cGetHappiness=0,function(...)
			local ts,tn=tostring,tonumber
			return tn(ts(tn(City.getHappiness(...)) or "")) or 0
		end
		local fl=math.floor
		local d=Draft.getDraft("$anim_ui_happiness00")
		addItem({
			{type=0,value=function() r=cGetHappiness() return d:getFrame(1+fl((4*r)+0.5)) end},
			{
				type=1,
				value=function() return r end,
				getText=function(v) return fl(v*100+0.5).."%" end,
				color=function(v) return 255*(2-v*2),255*math.min(1,v*2),0 end
			},
		})
		(p,{
			id="cmdRating",
			onClick=function(self) City.openInfo(City.INFO_GENERAL) end,
		}):setChildIndex(2)
	end
	if not Runtime.isPremium() then
		local c=GUI.get("cmdDiamondShop")
		local d={(function()
			silentClick(c) local rt=GUI.getRoot()
			local c=rt:getChild(rt:countChildren())
			c:setVisible(false)
			return c,c:getChild(1)
		end)()}
		local p=c:getParent()
		c:delete()
		addItem({
			{type=0,value=Icon.DIAMOND_SMALL},
			{type=1,value=TheoTown.getDiamonds,getText=function(v) return "+"..ths(v) end},
		})
		(p,{
			id="cmdDiamondShop",
			onInit=function(self) self:setChildIndex(1) table.insert(sbo,self) end,
			onClick=function(self) showDialog(table.unpack(d)) end,
		})
	end
	do
		local p=GUI.get("cmdBudget"):getParent():getParent()
		local p2=GUI.get("cmdDate"):getParent():getParent()
		--local p3={GUI.get("cmdCityName"):getParent():getParent()}
		local p3={GUI.get("cmdCityName"):getParent():getParent(),p2}
		if p~=p2 then p:setPosition(p:getX(),p:getY()-1) table.insert(p3,2,p) end
		--if p~=p2 then p:setPosition(p:getX(),p:getY()-1) end
		for _,c in pairs(p3) do
			local s=5
			c:setPosition(c:getX()-s,c:getY())
			c:setSize(c:getWidth()+s,c:getHeight())
		end
		--table.insert(p3,p2)
		--if p~=p2 then table.insert(p3,p) end
		table.remove(p3,1)
		local c=GUI.get("cmdMinimap")
		local leftMinimap=TheoTown.SETTINGS.leftMinimap
		if leftMinimap then c:setPosition(c:getX()-5,c:getY()) end
		if settings.smm then
			local s=25
			if leftMinimap then
				local pw=c:getWidth()
				c:setPosition(c:getX(),c:getY()+c:getHeight()-s)
				c:setSize(s,s)
				for _,cc in pairs(p3) do
					local s=pw-c:getWidth()
					cc:setPosition(cc:getX()-s,cc:getY())
					cc:setSize(cc:getWidth()+s,cc:getHeight())
				end
			else
				c:setPosition(c:getX()+c:getWidth()-s,c:getY()+c:getHeight()-s)
				c:setSize(s,s)
				for _,c in pairs(p3) do
					local s=s-5
					c:setSize(c:getWidth()+s,c:getHeight())
				end
			end
		end
	end
	do
		local c=GUI.get("cmdBudget")
		local p=c:getParent()
		c:delete()
		local cGetMoney,cGetIncome,cIsUber=City.getMoney,City.getIncome,City.isUber
		local money,income,sandbox=0,0
		local cIsSandbox=City.isSandbox
		local cIsSandbox0=function() return not not sandbox end
		local cIsSandbox1=function() return not sandbox end
		addItem({
			{type=0,value=function() sandbox=cIsSandbox() return 0 end},
			{type=0,scale=0.5,value=Icon.LEVEL},{w=4},
			{
				type=0,scale=0.3,visible=cIsSandbox0,value=Icon.INFINITY,
				color=function(v) if cIsUber() then return 0,255,255 else return 255,255,0 end end
			},
			{
				type=1,value=cGetMoney,visible=cIsSandbox1,
				getText=function(v) return ths2(v).."₮" end,
				color=function(v) if v<0 then return 255,0,0 else return 255,255,255 end end
			},
			{w=4,visible=cIsSandbox1},
			{
				type=1,value=cGetIncome,visible=cIsSandbox1,
				getText=function(v) return (v<0 and "" or "+")..ths2(v).."₮" end,
				color=function(v) if v<0 then return 255,0,0 else return 0,255,0 end end
			}
		})
		(p,{
			id="cmdBudget",
			onInit=function(self) self:setChildIndex(2) table.insert(sbo,self) end,
			onClick=function() City.openInfo(City.INFO_BUDGET) end,
		})
	end
	do
		local c=GUI.get("cmdDate")
		local p=c:getParent()
		c:delete()
		local cGetDay,cGetMonth,cGetYear=City.getDay,City.getMonth,City.getYear
		local cGetDayPart=City.getDayPart
		local day,month,year=0,0,0
		local pgw,gw,gw2,gw3=0,0,0
		(function(...)
			gw3=select(2,...)
			return (...)(p,{
				id="cmdDate",
				onUpdate=function() pgw,gw,gw2=gw2,gw3(),0 end,
				onInit=function(self)
					local cGetSpeed,cSetSpeed=City.getSpeed,City.setSpeed
					local icon=function(s)
						return ({
							[1]=Icon.PAUSE,
							[2]=Icon.PLAYSLOW,
							[3]=Icon.PLAY,
							[4]=Icon.PLAYFAST,
							[5]=Icon.PLAYFASTFAST
						})[s]
					end
					local add add=function(s)
						local c c=function() cSetSpeed(s) end
						local r=function(self)
							local i=self:getChildIndex()+1
							if self:getTouchPoint() and not isTouchPointInFocus(self) then
								self:setVisible(false) self:delete()
								add(s):setChildIndex(i) return
							end
							local w=getW(self) gw2=gw2+2+(i<2 and 2 or 0)
							setX(self,gw+gw2-pgw) gw2=gw2+w
						end
						return GUI1C(self):addCanvas {
							w=0,h=0,
							onInit=function(self)
								self.click=function(...) return c(...) end
								local p=self:getParent()
								local s=getCH(p) setWH(self,s,s)
								r(self)
							end,
							onClick=function(...) return c(...) end,
							onUpdate=function(self) r(self) end,
							onDraw=function(self,x,y,w,h)
								if self:getTouchPoint() or cGetSpeed()==s then
									local setAlpha=saveDrawing()
									setAlpha(0.4) Drawing.drawRect(x,y,w,h) setAlpha(1)
								end
								local icon=icon(s+1)
								local iw,ih=Drawing.getImageSize(icon)
								local sx,sy=Drawing.getScale()
								local s=0.5 --math.min(1,w/iw,h/ih)
								if w<=0 or h<=0 then s=0 end
								Drawing.setScale(sx*s,sy*s)
								local sx2,sy2=Drawing.getScale()
								Drawing.drawImage(icon,x+(w-(iw*sx2))/2,y+(h-(ih*sy2))/2)
								Drawing.setScale(sx,sy)
							end,
						}
					end
					local p=Runtime.isPremium()
					add(0) if p then add(1) end
					add(2) add(3)
					if p then add(4) end
				end,
				onClick=function() City.openInfo(City.INFO_STATISTICS) end,
			})
		end)
		(addItem({
			{type=0,value=function() day,month,year=cGetDay(),cGetMonth(),cGetYear() return 0 end},
			{
				type=0,scale=0.5,value=Icon.CLOCK_EMPTY,
				onDraw=function(x,y,w,h)
					w,h=w/2,h/2 x,y=x+w,y+h w,h=w-2.5,h-2.5
					local max,sin,cos,pi=(function(math) return math.max,math.sin,math.cos,math.pi end)(math)
					local f=function(v,s)
						v,s=v%1,s or 1 local x0,y0=x,y
						local x1,y1=x+w*sin(v*(pi*2)),y-h*cos(v*(pi*2))
						local va=function(i0,i1) return (i0*(1-s))+(i1*s) end
						Drawing.drawLine(x0,y0,va(x0,x1),va(y0,y1))
					end
					local setAlpha,setColor=saveDrawing()
					setColor(0,0,0)
					f(((30*month)+day)/360,0.6)
					setAlpha(0.5) f(day/30)
					setAlpha(1) setColor(255,255,255)
				end
			},{w=4},
			{type=1,value=function()
				local v=function(v,i)
					local tn,ts=tonumber,tostring
					v=ts(tn(ts(tn(v))) or 0)
					i=tonumber(i) or 1
					return ("0"):rep(math.max(0,i-#v))..v
				end
				return TheoTown.translate("game_date"):gsub("%%(%d-)$,?(%d-)d",function(i,ii)
					return ({v(day,ii),v(month,ii),v(year,ii)})[i+0]
				end)
			end},
			{w=function() return gw2 end}
		}))
	end
	do
		local phui=TheoTown.SETTINGS.hideUI
		GUI1C.addCanvas(GUI.getRoot(),{
			w=0,h=0,
			onInit=function(self)
				self:setChildIndex(3)
				for _,cc in pairs(sbo)
				do if cc then
					cc:setVisible(not TheoTown.SETTINGS.hideUI)
				end end
			end,
			onUpdate=function(self)
				self:setSize(0,0) self:setPosition(0,0)
				self:setTouchThrough(true)
				local nv=TheoTown.SETTINGS.hideUI
				if phui~=nv then
					for _,c in pairs(sbo) do if c then
						c:setVisible(phui)
					end end
				end
				phui=nv
			end
		}):setTouchThrough(true)
	end
	--Runtime.popStage()
	if false then
		local p=sidebar:getFirstPart()
		--local f=p:getFirstPart().addButton
		local f=p.addButton
		p.addButton=function(...)
			local draft=Script.getScript():getDraft()
			Debug.toast(draft:getId(),draft:isPrivileged())
			return f(...)
		end
	end
	do return end 
	do
		local a,c
		local f f=function()
			GUI.createDialog {
				w=0,h=0,
				onUpdate=function(self)
					pcall(function()
						local p0=self.content:getParent():getParent()
						p0:setChildIndex(GUI.getRoot():countChildren())
					end)
					pcall(function()
						local p0=self.content:getParent():getParent()
						local p1=a.content:getParent():getParent()
						p1:setChildIndex(p0:getChildIndex())
					end)
					pcall(function() a.close() end)
					self.content:getParent():getParent():setTouchThrough(true)
				end,
				onInit=function(self)
					local i=0
					local tp
					self.content:getParent():getParent():addCanvas {
						onClick=function()
							--self.close()
						end,
						onInit=function(self)
							c=self
							tp=function() return self:getTouchPoint() or c:getTouchPoint() end
						end,
						onUpdate=function()
							i=i+1
							if i<2 then return end
							a=self
							f()
						end 
					}:setTouchThrough(true)
					self.content:getParent():getParent():setTouchThrough(true)
					local p0=self.content:getParent():getParent()
					p0:setChildIndex(GUI.getRoot():countChildren())
				end,
			}
		end
		Runtime.postpone(function() f() end)
	end
end) Runtime.postpone(function() assert(er0,er1) end) end

local rbosI
function script:enterStage(sn)
	if saec==0 and sn=="SaveWaitingStage" then
		saec=1
	elseif saec==1 and sn~="SaveWaitingStage" then
		local bt,er,c=saect,setmetatable({},{__mode="kv"})
		saec,saect=nil
		(function() end)(
			(function() City.setView(0,0,1e+100) end)(),
			(function() City.exit() end)(),
			(function() er={} while #bt>=1 do
				c,bt[#bt]=bt[#bt]
				er[#er+1],c={pcall(function() c:delete() end)}
			end bt=nil end)()
		)
		if istable(er) then for k,v in pairs(er) do er[k]=nil assert(table.unpack(v)) v=nil end end
	elseif rbosI then
		rbosI=nil
		local d=GUI.createDialog {
			text="Only effective if right sidebar setting is off",
			pause=false
		}
		local t=Runtime.getTime()
		local p=d.content:getParent():getParent()
		local function e()
			if not isGUIValid(p) then return end
			local tt=(Runtime.getTime()-t)/1000
			if tt>=5 then p:setVisible(false) p:delete() d.close() return end
			Runtime.postpone(function() e() end)
		end e()
	end
end
function script:settings()
	local tbl={{
		name="Enabled (city UI)",
		value=not not settings.ena,
		onChange=function(v) settings.ena=v end
	}}
	if settings.ena then
		local rs=TheoTown.SETTINGS.rightSidebar
		table.insert(tbl,{
			name="Small minimap icon",
			value=not not settings.smm,
			onChange=function(v) settings.smm=v end
		})
		local i=math.random()
		table.insert(tbl,{
			name="Region button position",
			value=tonumber(settings.rbos) or "",
			values={i,0,1,2},
			valueNames={"[i]","Auto","Sidebar","Bottom"},
			onChange=function(v) if not rs then
				if v==i then
					rbosI=true
				else
					settings.rbos=v
				end
			end end
		})
	end
	return tbl
end