--[[ Set the Main Global Scope for the Add On ]]--

ProfessionProfit = {}
ProfessionProfit.db = {}
ProfessionProfit.events = {}
ProfessionProfit.ui = {}

--[[----- Constants -----]]--
ProfessionProfit.MAX_VIEWABLE_LISTS = 15
ProfessionProfit.LIST_ITEM_HEIGHT = 20

ProfessionProfit.MAX_VIEWABLE_ITEMS = 8
ProfessionProfit.ITEM_HEIGHT = 37

ProfessionProfit.TITLE = "Profession Profit"

StaticPopupDialogs["ProfessionProfitDialog1"] = {
  text = "Items that bind when picked up do not appear on the auction house.",
  button1 = OKAY,
  hideOnEscape = 1,
  timeout = 0,
}

StaticPopupDialogs["ProfessionProfitDialog2"] = {
  text = "Conjured items do not appear on the auction house.",
  button1 = OKAY,
  hideOnEscape = 1,
  timeout = 0,
}

StaticPopupDialogs["ProfessionProfitDialog3"] = {
  text = "In order to add an item to a list, a list must be selected first.",
  button1 = OKAY,
  hideOnEscape = 1,
  timeout = 0,
}

StaticPopupDialogs["ProfessionProfitDialog4"] = {
  text = "This item is already in this list.",
  button1 = OKAY,
  hideOnEscape = 1,
  timeout = 0,
}


ProfessionProfit.formatMoney = function(frame, c)

  local G,S,C

  local g,s
  
  c = c or 0
  
  g = floor(c / 10000)
  c = mod(c, 10000)
  
  s = floor(c / 100)
  c = mod(c, 100)


  G = _G[frame.."Gold"]
  S = _G[frame.."Silver"]
  C = _G[frame.."Copper"]


  G:SetText(g)
  S:SetText(s)
  C:SetText(c)  

  if g == 0 then
    G:Hide()
  else
    G:Show()
  end
  
  if g==0 and s==0 then
    S:Hide()
  else
    S:Show()
  end
 
end