local pp = ProfessionProfit;
pp.ui.tab = {}
pp.ui.frame = {}

--[[ Tab Functions ]]--
pp.ui.tab["name"] = nil
pp.ui.tab["Index"] = nil
pp.ui.frame["Index"] = nil

local Frame
local ToolTip
local FrameListAddButton
local FrameListAddText
local FrameListDeleteButton
local FrameItemName
local FrameItemAddButton
local FrameItemIcon

local BoundCheck = {
  [1] = ITEM_BIND_ON_PICKUP,
  [2] = ITEM_CONJURED
}

pp.ui.itemscan = function(itemLink, phrase)
  ToolTip:ClearLines()
  ToolTip:SetHyperlink(itemLink)

  for i = 2, ToolTip:NumLines() do
    local text = _G["ProfessionProfitTooltipTextLeft"..i]:GetText()
    if text and text ~= "" then
      local result = string.find(text, phrase)
      if result then return true end
    end
  end
  return false
end

function ProfessionProfit_Tab_OnLoad(self)
  self:RegisterEvent("AUCTION_HOUSE_SHOW");
end

function ProfessionProfit_Tab_OnEvent(self, event, ...)
  pp.ui.tab[event](self);
end

function ProfessionProfit_Tab_OnClick(self,button,down)
  -- Turn off the frame and deselect the tab.
  AuctionFrameProfit:Hide()
  local index = self:GetID();
  PanelTemplates_SetTab(AuctionFrame, index);
  
  if index == pp.ui.tab["Index"] then
    -- Set Background Layout
    AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft");
    AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top");
    AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight");
    AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft");
    AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
    AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");

    AuctionFrameProfit:Show()
    AuctionFrame.type = "list";
    SetAuctionsTabShowing(false);  
  end
end

pp.ui.tab["AUCTION_HOUSE_SHOW"] = function(self)
  local tab = self
  local count = 1;
  
  while (_G["AuctionFrameTab"..(count)]) do
    if _G["AuctionFrameTab"..(count)]:GetName() == tab:GetName() then
      return
    end
    count = count + 1;
  end

  pp.ui.tab["name"] = tab:GetName()
  pp.ui.tab["Index"] = count

  _G["AuctionFrameTab"..count] = tab
  tab:SetParent("AuctionFrame");
  tab:SetPoint("TOPLEFT", _G["AuctionFrameTab"..(count - 1)]:GetName(), "TOPRIGHT", -8, 0);
  tab:SetID(count);
  tab:Show();

  -- Update the count of the tabs for global functions to see the tab
  AuctionFrame.numTabs = count
  PanelTemplates_DeselectTab(tab);

  hooksecurefunc("AuctionFrameTab_OnClick", ProfessionProfit_Tab_OnClick)
end


--[[ Frame Functions ]]--
pp.ui.frame["activeList"] = ""
pp.ui.frame["activeItem"] = ""

function ProfessionProfit_Frame_OnLoad(self)
  self:RegisterEvent("AUCTION_HOUSE_SHOW");
  self:RegisterEvent("AUCTION_HOUSE_CLOSED");

  Frame = self
  ToolTip = _G["ProfessionProfitTooltip"]
  FrameListAddButton = _G["ProfitListAddButton"]
  FrameListAddText = _G["ProfitListName"]
  FrameListDeleteButton = _G["ProfitListDeleteButton"]
  FrameItemName = _G["AuctionFrameProfit".."ItemName"]
  FrameItemAddButton = _G["AuctionFrameProfit".."ItemAddButton"]
  FrameItemIcon = _G["AuctionFrameProfit".."ItemIcon"]
  FrameItemDeleteButton = _G["AuctionFrameProfit".."ItemDeleteButton"]
  

  FauxScrollFrame_SetOffset(ProfitListScrollFrame,0);
  
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderIcon", 1)
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderName", 2)
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderCount", 3)
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderSeller", 4)
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderBuyout", 5)
  
  _G["AuctionFrameProfit".."Credit"]:SetText("by Hãwtsauce@Netherwind");
end

function ProfessionProfit_Frame_OnShow(self)
  pp.ui.frame.update()
end

function ProfessionProfit_Frame_OnEvent(self, event, ...)
  pp.ui.frame[event](self)
end

pp.ui.frame['AUCTION_HOUSE_SHOW'] = function(self)
  local frame = self
  frame:SetParent("AuctionFrame");
  frame:SetPoint("TOPLEFT");
end

pp.ui.frame['AUCTION_HOUSE_CLOSED'] = function(self)
  pp.db.save()
end

function ProfessionProfit_Frame_List_Add_Bnt_OnUpdate(self)
  local name = FrameListAddText:GetText()
  
  if string.len(name) < 3 or name == "" or pp.db.listExists(name) then
    FrameListAddButton:Disable()
  else
    FrameListAddButton:Enable()
  end
  
  if pp.ui.frame["activeList"] == "" then
    FrameListDeleteButton:Disable()
  else
    FrameListDeleteButton:Enable()
  end
end

function ProfessionProfit_Frame_List_Add_Bnt_OnClick(self)
  local name = FrameListAddText:GetText()
  
  
  if string.len(name) >= 3 and not pp.db.listExists(name) then
    FrameListAddText:SetText("")
    pp.db.addList(name)
    pp.ui.frame["activeList"] = name
    pp.ui.frame.update();
  end
end

function ProfessionProfit_Frame_List_Delete_Bnt_OnClick(self)
  local name = pp.ui.frame["activeList"]
  
  pp.db.removeList(name)
  pp.ui.frame["activeList"] = ""
  pp.ui.frame.update();
end


pp.ui.frame.update = function()
  if pp.ui.frame["activeList"] == "" then
    _G["AuctionFrameProfit".."Title"]:SetText(ProfessionProfit.TITLE);
  else
    _G["AuctionFrameProfit".."Title"]:SetText(ProfessionProfit.TITLE.." - "..pp.ui.frame["activeList"]);
  end

  pp.ui.frame.listUpdate()  
  pp.ui.frame.itemUpdate()
end

pp.ui.frame.listUpdate = function()
  local offset = FauxScrollFrame_GetOffset(ProfitListScrollFrame)
  local list, text, bntListAdd

  data = pp.db.Lists()
  
  for i = 1, pp.MAX_VIEWABLE_LISTS do
    list = _G["ProfitFile"..i];
    text = data[i + offset]
    
    if text then
      
      if pp.ui.frame["activeList"] == text then
        list:LockHighlight();
      else
        list:UnlockHighlight();      
      end
    
      list:SetText(text);
      
      if (getn(data) > pp.MAX_VIEWABLE_LISTS) then
        list:SetWidth(136);
      else
        list:SetWidth(156);
      end

      list:Show()
    else
      list:Hide()
    end
  end
  
  FauxScrollFrame_Update(ProfitListScrollFrame, getn(data), pp.MAX_VIEWABLE_LISTS, pp.LIST_ITEM_HEIGHT);
end


--[[-----List Scroll Bar Functions-----]]--
function ProfessionProfit_Frame_List_Update()
  pp.ui.frame.update()
  -- Update scrollFrame
  FauxScrollFrame_Update(ProfitListScrollFrame, getn(pp.db.Lists()), pp.MAX_VIEWABLE_LISTS, pp.LIST_ITEM_HEIGHT);
end

--[[ List Item Functions ]]--
function ProfessionProfit_Frame_ListItem_OnClick(self, button, down) 
  local name = self:GetText()
  
  if pp.ui.frame["activeList"] == name then
    pp.ui.frame["activeList"] = ""
  else
    pp.ui.frame["activeList"] = name
  end
  
  pp.ui.frame.update()  
end

--[[ ITEM FUNCTIONS ]]--
function ProfessionProfit_Frame_Item_Add_Bnt_OnClick(self)
  local text = FrameItemName:GetText();
  local list = pp.ui.frame["activeList"];
  
  if string.len(text) >= 3 then
  
    if list == "" then
      StaticPopup_Show("ProfessionProfitDialog3")
    else
      if pp.db.itemExists(list,text) then
        StaticPopup_Show("ProfessionProfitDialog4")
      else
        FrameItemName:SetText("");
        pp.db.addItem(list,text);
        
        FrameItemName:ClearFocus();
        pp.ui.frame.itemUpdate();
      end
    end
  end
end

function ProfessionProfit_Frame_Item_Add_Bnt_OnUpdate(self)
  local text = FrameItemName:GetText();

  if string.len(text) < 3 or text == "" then
    FrameItemAddButton:Disable()
  else
    FrameItemAddButton:Enable()
  end
  
  if pp.ui.frame["Index"] == nil then
    FrameItemDeleteButton:Disable()
  else
    FrameItemDeleteButton:Enable()
  end
  
  
  --parentStatusText
  if pp.db.queue.active ~= nil then
    _G["AuctionFrameProfit".."StatusText"]:SetText("Scanning ["..pp.db.queue.active.name.."]");
  else
    if pp.db.queue.count() == 0 and _G["AuctionFrameProfit".."StatusText"]:GetText() ~= "Click Scan to update listing." then
      _G["AuctionFrameProfit".."StatusText"]:SetText("Done Scanning.");
    end
  end
  
  pp.db.queue.query()
end

function ProfessionProfit_Frame_Item_Icon_OnEvent()
  print('ProfessionProfit_Frame_Item_Icon_OnEvent')
end

function ProfessionProfit_Frame_Item_Icon_OnClick(self, button)
  local ctype, itemID, itemLink = GetCursorInfo()
  
  if ctype == "item" then
    for i = 1, getn(BoundCheck) do
      if pp.ui.itemscan(itemLink, BoundCheck[i]) then
        StaticPopup_Show("ProfessionProfitDialog"..i)
      end  
    end
    
    local itemName = GetItemInfo(itemID)
    FrameItemName:SetText(itemName);
    ProfessionProfit_Frame_Item_Add_Bnt_OnClick();
  end
  ClearCursor()
end

function ProfessionProfit_Frame_Item_Delete_Bnt_OnClick(self)
  local index = pp.ui.frame["Index"]
  if index then
    local itemName = _G["AuctionFrameProfit".."ItemButton"..index.."ItemName"];
    FrameItemDeleteButton:Disable()
    pp.ui.frame["Index"] = nil
    pp.db.removeItem(pp.ui.frame["activeList"],itemName:GetText());
    pp.ui.frame.itemUpdate()
  end
end

function ProfessionProfit_Frame_Item_OnClick(self)
  local id = self:GetID();
  if id == pp.ui.frame["Index"] then
    pp.ui.frame["Index"] = nil
  else
    pp.ui.frame["Index"] = id
  end
  pp.ui.frame.itemUpdate()
end

function ProfessionProfit_Frame_List_Scan_Bnt_OnClick(self)
  self:Disable()
  if (self:GetText() == 'Scan') then
    self:SetText('Cancel');   
    self:Enable()

    -- get all the items for the list
    local list = pp.ui.frame["activeList"];
    local items = pp.db.Items(list);
    
    -- clear the recent que.
    pp.db.queue.recent = {}
    
    for i = 1, getn(items) do
      pp.db.queue.put(items[i].listname);
    end
    
    pp.db.queue.query();
  else
    pp.db.queue.clear()
  end
 
end
function ProfessionProfit_Frame_Sort_Items(self)

  local index = self:GetID()
  
  if index == pp.db.sortIndex then
    pp.db.sortAsc = not pp.db.sortAsc
  else
    pp.db.sortIndex = index
    pp.db.sortAsc = true
  end

  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderIcon", 1)
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderName", 2)
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderCount", 3)
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderSeller", 4)
  ProfessionProfit_Frame_Sort_Items_UpdateArrow("AuctionFrameProfit".."SortHeaderBuyout", 5)
  
  pp.ui.frame.itemUpdate()
end

function ProfessionProfit_Frame_Sort_Items_UpdateArrow(button, index)
  if (pp.db.sortIndex == index) then
    if (pp.db.sortAsc) then
      _G[button.."Arrow"]:Show();
      _G[button.."Arrow"]:SetTexCoord(0, 0.5625, 0, 1.0);
    else
      _G[button.."Arrow"]:Show();
      _G[button.."Arrow"]:SetTexCoord(0, 0.5625, 1.0, 0);
    end
  else
    -- hide sort arrows for non-primary column
    _G[button.."Arrow"]:Hide();
  end
end



--[[  Item Scroll Functions ]]--
function ProfessionProfit_Frame_Item_Update()
  pp.ui.frame.update()
  local list
  list = pp.ui.frame["activeList"]
  data = pp.db.Items(list)
  if data == nil then data = {} end  
  FauxScrollFrame_Update(AuctionFrameProfitItemScrollFrame, getn(data), pp.MAX_VIEWABLE_ITEMS, pp.ITEM_HEIGHT);
end

pp.ui.frame.itemUpdate = function()
  local offset = FauxScrollFrame_GetOffset(AuctionFrameProfitItemScrollFrame)
  
  local list, data, count, player
  
  list = pp.ui.frame["activeList"]
  data = pp.db.Items(list)
  count = getn(data);
  
  local player = UnitName("player")
  
  for i = 1, pp.MAX_VIEWABLE_ITEMS do
      local lblButton      = _G["AuctionFrameProfit".."ItemButton"..i];
      local lblHighlight   = _G[lblButton:GetName().."Highlight"];
      local lblName        = _G[lblButton:GetName().."Name"];
      local lblItemName    = _G[lblButton:GetName().."ItemName"];
      local lblItemLink    = _G[lblButton:GetName().."ItemLink"];
      local lblIcon        = _G[lblButton:GetName().."Item"];
      
      local lblAuctions    = _G[lblButton:GetName().."Auctions"];
      local lblTotal       = _G[lblButton:GetName().."Total"];
      local lblSeller      = _G[lblButton:GetName().."Seller"];
      local lblBuyout      = _G[lblButton:GetName().."LowestBuyout"];
      local lblBeanCounter = _G[lblButton:GetName().."HighestSale"];

      local lbl404         = _G[lblButton:GetName().."404"];
      
      local BeanCounter
      
      local item = data[i + offset];
    
    
    if count <= pp.MAX_VIEWABLE_ITEMS then
      lblButton:SetWidth(620)
      lblHighlight:SetWidth(584)
    else
      lblButton:SetWidth(599)
      lblHighlight:SetWidth(565)
    end
    
    if pp.ui.frame["Index"] == i then
        lblButton:LockHighlight();
    else
        lblButton:UnlockHighlight();    
    end
    
    
    if item then
      BeanCounter = pp.db.bc.Item(item.id) or 0

      if item.quality == 8 then
        r = 1.0; g = 0.82; b = 0
      else
        r, g, b = GetItemQualityColor(item.quality)
      end

      lblItemName:SetText(item.listname)

      lblName:SetText(item.name)
      lblName:SetTextColor(r, g, b);

      if item.texture == 'Interface\\Icons\\Inv_Misc_QuestionMark' then
        lblAuctions:Hide()
        lblTotal:Hide()
        lblSeller:Hide()
        lblBuyout:Hide()
        lblBeanCounter:Hide()
        lbl404:Show()
      
        lblIcon:SetNormalTexture(item.texture)
      else
        lblAuctions:Show()
        lblTotal:Show()
        lblSeller:Show()
        lblBuyout:Show()
        lbl404:Hide()
        
        if BeanCounterDB then
          lblBuyout:SetPoint("TOPRIGHT",-10,-2)
          lblBeanCounter:Show()
        else
          lblBuyout:SetPoint("TOPRIGHT",-10,-8)
          lblBeanCounter:Hide()
        end
        
        pp.formatMoney(lblBeanCounter:GetName(), BeanCounter)
      
        lblAuctions:SetText(item.auctioncount)
        lblTotal:SetText(item.itemcount)
        lblItemLink:SetText(item.link)
        
        lblSeller:SetText(item.owner)
        if player == item.owner then
          lblSeller:SetTextColor(GetItemQualityColor(2));
        elseif item.owner == "unknown" then
          lblSeller:SetTextColor(GetItemQualityColor(0));
        else
          lblSeller:SetTextColor(GetItemQualityColor(1));
        end
       
        pp.formatMoney(lblBuyout:GetName(), item.buyout)

        lblIcon:SetNormalTexture(item.texture)
      end

      lblButton:Show()
    else
      lblButton:Hide()
    end

  end

  FauxScrollFrame_Update(AuctionFrameProfitItemScrollFrame, count, pp.MAX_VIEWABLE_ITEMS, pp.ITEM_HEIGHT);
end
