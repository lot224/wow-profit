--[[-----------------

  DB Related IO Functions
 
-----------------]]--
local pp = ProfessionProfit;
pp.db.data = nil
pp.db.item = nil
pp.db.queue = {}
pp.db.sort = {}

--[[--------------------

  Local Functions
  
--------------------]]--
local function getItemId(itemLink)
  return itemLink:match("item:(%d+):")
end

local function getDateNum()
  return date('%y%m%d%H%M')
end

--[[--------------------

  SORTING Functions

--------------------]]--
pp.db.sortAsc = true
pp.db.sortIndex = 2

local function sortNames(a, b)
  return string.lower(a) < string.lower(b)
end

local function linkDetails(link)
  local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
  return Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name
end

-- Sort By Texture, then by name
pp.db.sort[1] = function(a, b)
  if pp.db.sortAsc then
    if string.lower(a.texture) == string.lower(b.texture) then
      return string.lower(a.name) < string.lower(b.name)    
    end
    return string.lower(a.texture) < string.lower(b.texture)
  else
    if string.lower(a.texture) == string.lower(b.texture) then
      return string.lower(a.name) > string.lower(b.name)    
    end
    return string.lower(a.texture) > string.lower(b.texture)
  end
end

-- Sort By Name
pp.db.sort[2] = function(a, b)
  if pp.db.sortAsc then
    return string.lower(a.name) < string.lower(b.name)
  else
    return string.lower(a.name) > string.lower(b.name)
  end
end

-- Sort By Count
pp.db.sort[3] = function(a, b)
  if pp.db.sortAsc then
    return a.itemcount < b.itemcount
  else
    return a.itemcount > b.itemcount
  end
end

-- Sort By Seller
pp.db.sort[4] = function(a, b)
  if pp.db.sortAsc then
    return string.lower(a.owner) < string.lower(b.owner)
  else
    return string.lower(a.owner) > string.lower(b.owner)
  end
end


-- Sort By Buyout
pp.db.sort[5] = function(a, b)
  if pp.db.sortAsc then
    return a.buyout < b.buyout
  else
    return a.buyout > b.buyout
  end
end

--[[--------------------

  EVENT Functions
  
--------------------]]--
function ProfessionProfitDataFrame_OnEvent(self, event, arg1)
  if event == "ADDON_LOADED" and arg1 == "ProfessionProfit" then
    pp.db.load()
  elseif event == "PLAYER_LOGOUT" then
    pp.db.save()
  elseif event == "AUCTION_ITEM_LIST_UPDATE" then
    pp.db.queue.update()
  end
end



--[[--------------------

  BASE IO Functions
  
--------------------]]--
pp.db.load = function()
  if not ProfessionProfitDataStore then
    ProfessionProfitDataStore = {}
  end
  
  if not ProfessionProfitItemStore then
    ProfessionProfitItemStore = {}
  end
  
  pp.db.data = ProfessionProfitDataStore
  pp.db.item = ProfessionProfitItemStore
end

pp.db.save = function()
  if not pp.db.data then pp.db.data = {} end
  ProfessionProfitDataStore = pp.db.data
  
  if not pp.db.item then pp.db.item = {} end
  ProfessionProfitItemStore = pp.db.item  
end

pp.db.clear = function()
  ProfessionProfitDataStore = {}
  ProfessionProfitItemStore = {}
  pp.db.load();
end



--[[--------------------

  LIST Functions
  
--------------------]]--
pp.db.Lists = function()
  local nResult = {}

  for index, value in pairs(pp.db.data) do 
    if value then
      nResult[getn(nResult) + 1] = index
    end
  end
  
  table.sort(nResult, sortNames)
  
  return nResult
end

pp.db.listExists = function(name)
  if not name then return false end
  
  local n = string.lower(name)
  
  for index in pairs(pp.db.data) do 
    if (string.lower(index) == n) then
      return true
    end
  end  

  return false
end

pp.db.addList = function(name)
  if not name then return end
  if not pp.db.data[name] then
    pp.db.data[name] = {}
  end
end

pp.db.removeList = function(name)
  if not name then return end
  if not pp.db.data[name] then return end
  
  local nResult = {}
  
  for index, value in pairs(pp.db.data) do 
    if not (index == name) then
      if value then
        nResult[index] = value
      end
    end
  end
  
  pp.db.data = nResult
end



--[[--------------------

  LIST ITEM Functions
  
--------------------]]--
pp.db.Items = function(list)
  if not list then return {} end
  if not pp.db.data[list] then return {} end

  -- Need to modify this so it returns an array of details not just a list of items.
  local nResult = {}
  
  for index = 1, getn(pp.db.data[list]) do
    local item = pp.db.itemDetails(pp.db.data[list][index])
    item.listname = pp.db.data[list][index]
    table.insert(nResult, item)
  end
  
  table.sort(nResult, pp.db.sort[pp.db.sortIndex])
  
  return nResult
end

pp.db.addItem = function(list,item)
  if not list or not item then return end
  if not pp.db.data[list] then return end
  
  pp.db.data[list][getn(pp.db.data[list])+1] = item
end

pp.db.removeItem = function(list,item)
  if not list or not item then return end
  
  local n = string.lower(item)
  local index = nil
  
  for i = 1, getn(pp.db.data[list]) do
    if string.lower(pp.db.data[list][i]) == n then
     index = i
    end
  end
  
  if index ~= nil then
    table.remove(pp.db.data[list], index);
  end
end

pp.db.itemExists = function(list,item)
  if not list or not item then return false end
  if not pp.db.data[list] then return false end
  
  local n = string.lower(item)
  
  for i = 1, getn(pp.db.data[list]) do
    if string.lower(pp.db.data[list][i]) == n then
     return true
    end
  end
  
  return false
end



--[[--------------------

  BLIZZARD ITEM Functions
  
--------------------]]--
pp.db.itemDetails = function(name)
  if pp.db.item[name] then return pp.db.item[name] end
  
  local nResult = {
    id = nil,
    link = '',
    name = name,
    quality = 8,
    texture = 'Interface\\Icons\\Inv_Misc_QuestionMark',
    itemcount = "",
    auctioncount = "",
    buyout = 0,
    owner = ""
  }
  
  local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(name)
  
  if itemName then
    local _, _, itemId = linkDetails(itemLink)
    nResult.id = itemId
    nResult.name = itemName
    nResult.link = itemLink
    nResult.quality = itemRarity
    nResult.texture = itemTexture
    nResult.itemcount = ""
    nResult.auctioncount = ""
    nResult.buyout = 0
    nResult.owner = ""
    pp.db.item[name] = nResult
  else
    pp.db.queue.put(name)
  end
  
  return nResult
end


--[[ QUEUE FUNCTION ]]--
pp.db.queue.data = {}
pp.db.queue.active = nil
pp.db.queue.override = false
pp.db.queue.recent = {}
pp.db.queue.throttle = date('%y%m%d%H%M%S')

pp.db.queue.peek = function()
  if getn(pp.db.queue.data) == 0 then return nil end
  return pp.db.queue.data[1]
end

pp.db.queue.count = function()
  return getn(pp.db.queue.data)
end

pp.db.queue.pull = function()
  if getn(pp.db.queue.data) == 0 then
    pp.db.queue.active = nil
  else
    pp.db.queue.active = pp.db.queue.data[1]
    table.remove(pp.db.queue.data, 1);
  end
end

pp.db.queue.put = function(name, page)
  if not page then page = 0 end
  table.insert(pp.db.queue.data, { name = name, page = page} )
end

pp.db.queue.push = function(name, page)
  if not page then page = 0 end
  table.insert(pp.db.queue.data, 1, { name = name, page = page} )
end

pp.db.queue.clear = function()
  pp.db.queue.data = {}
end

pp.db.queue.query = function() 

  local d = date('%y%m%d%H%M%S')

  if pp.db.queue.active == nil and pp.db.queue.count() > 0 and CanSendAuctionQuery("list") and (d - pp.db.queue.throttle > 0) then
    pp.db.queue.throttle = d
    
    pp.db.queue.pull()
    
    local Query = pp.db.queue.active;
    
    -- makes sure the search is no ""
    if Query ~= nil then
    
      -- Recently checked?
      local d = getDateNum()
      local r = pp.db.queue.recent[Query.name.."|"..Query.page]
      
      if r and (d - r < 30) and pp.db.queue.override == false then
        pp.db.queue.active = nil
      else
        
        --print("Submitting Query to AH. Name="..Query.name..", Page="..Query.page);
        pp.db.queue.recent[Query.name.."|"..Query.page] = d
        -- Old Query
        -- QueryAuctionItems(Query.name, nil, nil, 0, 0, 0, Query.page, 0, 0, 0)

        -- New Query
        QueryAuctionItems(Query.name, nil, nil,  Query.page, false, 0 ,false, true, nil)
      end
    end
  else
    if pp.db.queue.count() == 0 then
      -- nothing left to query.
      local ScanBnt = _G["AuctionFrameProfit".."ListScanButton"];
      ScanBnt:SetText('Scan');
      ScanBnt:Enable()
    end
  end

end

pp.db.queue.update = function()
  
  local Item = pp.db.queue.active
  
  if Item ~= nil then
    
    --print('AUCTION_ITEM_LIST_UPDATE: Item:'..Item.name..', Page:'..Item.page)
    local page = Item.page + 1
    local name, texture, count, quality, minBid, buyoutPrice, itemId, itemOwner, itemOwnerFullName, allinfo
    local itemName, itemLink, itemRarity, itemTexture 
    local Batch, Autions = GetNumAuctionItems("list");
    
    if page == 1 and pp.db.item[Item.name] then
      pp.db.item[Item.name].itemcount = 0
      pp.db.item[Item.name].auctioncount = 0
      pp.db.item[Item.name].buyout = 0
      pp.db.item[Item.name].owner = ""
    end
    
    --print("Count:"..Autions..", Batch:"..Batch)
    
    for i = 1, Batch do
      
      name, texture, count, quality, _, _, _, minBid, _, buyoutPrice, _, _, _, itemOwner, itemOwnerFullName, _, itemId, allinfo = GetAuctionItemInfo("list", i);
      
      if not itemOwner then itemOwner = "unknown" end
      
      if name then
        if string.lower(name) == string.lower(Item.name) then
          if not pp.db.item[Item.name] then
            itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemId)

            pp.db.item[Item.name] = {
              id = itemId,
              link = itemLink,
              name = itemName,
              quality = itemRarity,
              texture = itemTexture,
              itemcount = 0,
              auctioncount = 0,
              buyout = 0,
              owner = itemOwner
            }
          end
          
          pp.db.item[Item.name].itemcount = pp.db.item[Item.name].itemcount + count

          if count ~= 0 then
            pp.db.item[Item.name].auctioncount = pp.db.item[Item.name].auctioncount + 1
          end

          -- Update the buyout price so it shows (per item)
          if count ~=0 and count > 1 then
            buyoutPrice = floor(buyoutPrice / count);
          end
          
          if pp.db.item[Item.name].buyout == 0 or (buyoutPrice < pp.db.item[Item.name].buyout and buyoutPrice > 0) then
            pp.db.item[Item.name].buyout = buyoutPrice
            
            pp.db.item[Item.name].owner = itemOwner
            if pp.db.item[Item.name].owner == nil then
              pp.db.item[Item.name].owner = itemOwnerFullName
            end
          end
          
          -- kk now do stats....
        
        end
      end
    end
    
    if page * 50 < Autions then
      pp.db.queue.push(Item.name, page);
    end

    pp.db.queue.active = nil
    pp.ui.frame.itemUpdate()
  end
end

--[[ Bean Counter Intergration ]]--
pp.db.bc = {}


-- Scans Beancounters db to determin if the user has ever sold this item before, and if they did, what was the highest they sold it for.
pp.db.bc.Item = function(itemId)
  itemId = itemId or 0
  local High = nil

  if BeanCounterDB then
    local Realm = GetRealmName()
    local data = nil
    local count, price
    
    if BeanCounterDB[Realm] then
      for key in pairs(BeanCounterDB[Realm]) do
        local context = BeanCounterDB[Realm][key]["completedAuctions"][""..itemId..""]
     
        if context then
          for obj in pairs(context) do
            for i = 1, getn(context[obj]) do
              data = { strsplit(";", context[obj][i]) }
              count = tonumber(data[1])
              price = tonumber(data[5])
              
              if count > 1 then
                price = floor(price / count)
              end
              
              if High == nil or price > High then
                High = price
              end
            end
          end
        end
      end    
    end
  end
  
  return High
end
