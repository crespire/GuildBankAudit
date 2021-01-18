SavedBankItemInfo = {}
local ItemsPerTab = 98

SLASH_GUILDBANKAUDIT1 = "/guildbankaudit"
SLASH_GUILDBANKAUDIT2 = "/gba"
SLASH_GUILDBANKAUDIT3 = "/gbank"

-- process chat commands
function SlashCmdList.GUILDBANKAUDIT(cmd, editbox)
  local request, arg = strsplit(' ', cmd)
  if request == "all" then
    GetGBAFrame(scanBank())
  elseif request  == "tab" then
    GetGBAFrame(scanTab())
  elseif request  == "help" then
    printHelp()
  elseif request == "dev" then
    runDev()
  else
    printHelp()
  end
end

-- display help in player's chat window
function printHelp()
  print("----- |cff26c426Guild Bank Audit Options|r -----")
  print("Type the slash command followed by one of the options below -> '/gba command'")
  print("|cffc21e1eDATA WILL NOT BE SAVED UNTIL YOU LOG OUT OF YOUR CHARACTER!|r")
  print("|cff5fe65dall|r", " - Scans your entire guild bank. |cffc21e1eYou must click on each tab in your guild bank before running this command.|r")
  print("|cff5fe65dtab|r", " - Scans the current tab open in your guild bank.")
  print("|cff5fe65dhelp|r", " - Displays this information here.")
  print("------------------------------------")
end

-- scans entire loaded guild bank (cannot load bank for you)
function scanBank()
  -- get number of tabs
  -- for each tab (GetGuildBankTabInfo)
  -- for each item (GetGuildBankItemInfo)
  -- save to table
  local outText = ''
  local numTabs = GetNumGuildBankTabs()
  for i = 1, numTabs, 1 do
    --local tabName, tabIcon, tabViewable, tabCanDeposit, tabNumWithdrawls, tabRemainingWithdrawals = GetGuildBankTabInfo(i)
    for k = 1, ItemsPerTab, 1 do
      local itemTex, itemCount, itemLocked, itemFiltered, itemQuality = GetGuildBankItemInfo(i, k)
      local itemName = GetGuildBankItemLink(i, k)
      if itemName ~= nil then
        local cleanName = removeStringGunk(itemName)
        tinsert(SavedBankItemInfo, format("%s, %c,", cleanName, tostring(itemCount)))
      --  tinsert(SavedBankItemInfo, itemName)
      --  tinsert(SavedBankItemInfo, itemCount)
        outText = outText .. cleanName .. ', ' .. itemCount .. '\n'
      end
    end
  end
  print("|cff26c426Guild Bank Audit Complete!|r Data will be saved when you log out.")
  return outText
end

-- scans the current tab the player is looking at
function scanTab()
  -- get current tab
  -- for each item
  -- save to table
  local outText = ''
  local currentTab = GetCurrentGuildBankTab()
  for i = 1, ItemsPerTab, 1 do
    local itemTex, itemCount, itemLocked, itemFiltered, itemQuality = GetGuildBankItemInfo(currentTab, i)
    local itemName = GetGuildBankItemLink(currentTab, i)
    if itemName ~= nil then
      local cleanName = removeStringGunk(itemName)
      tinsert(SavedBankItemInfo, format("%s, %c,", cleanName, tostring(itemCount)))
    --  tinsert(SavedBankItemInfo, itemName)
    --  tinsert(SavedBankItemInfo, itemCount)
      outText = outText .. cleanName .. ', ' .. itemCount .. '\n'
    end
  end
  print("|cff26c426Guild Bank Tab Audit Complete!|r Data will be saved when you log out.")
  return outText
end

function runDev()
  GetGBAFrame(scanBank())
end

-- add duplicates as one entry
function sortSavedTable()

end

--clean up item strings because theyre nasty
function removeStringGunk(itemName)
  local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, almostCleanItemName = strsplit(":", itemName)
  local _, closerCleanItemName = strsplit("[", almostCleanItemName)
  local cleanItemName = strsplit("]", closerCleanItemName)
  return cleanItemName
end

-- create the output frame
function GetGBAFrame(input)
  if not GBAFrame then
    local frame = CreateFrame("Frame", "GBAFrame", UIParent, "DialogBoxFrame")
    frame:SetPoint("CENTER")
    frame:SetSize(500, 500)
    frame:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
      edgeSize = 16,
      insets = {left = 8, right = 8, top = 8, bottom = 8}
    })
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:SetScript("OnMouseDown", function (self, button)
      if button == "LeftButton" then
        self:StartMoving()
      end
    end)
    frame:SetScript("OnMouseUp", function(self, button)
      self:StopMovingOrSizing()
    end)

    local scrollFrame = CreateFrame("ScrollFrame", "GBAScroll", GBAFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("LEFT", 16, 0)
    scrollFrame:SetPoint("Right", -32, 0)
    scrollFrame:SetPoint("TOP", 0, -32)
    scrollFrame:SetPoint("BOTTOM", GBAFrameButton, "TOP", 0, 0)

    local editFrame = CreateFrame("EditBox", "GBAEdit", GBAScroll)
    editFrame:SetSize(scrollFrame:GetSize())
    editFrame:SetMultiLine(true)
    editFrame:SetAutoFocus(true)
    editFrame:SetFontObject("ChatFontNormal")
    editFrame:SetScript("OnEscapePressed", function() frame:Hide() end)
    scrollFrame:SetScrollChild(editFrame)
  end
  GBAEdit:SetText(input)
  GBAEdit:HighlightText()
  GBAFrame:Show()
end
