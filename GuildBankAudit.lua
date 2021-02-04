local ItemsPerTab = 98

local SavedItems = {}
local SavedItemCounts = {}
local LastGoldCheck

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
  elseif request == "money" then
    GetGBAFrame(getMoneyLog())
  elseif request  == "help" then
    printHelp()
  elseif request == "bugged" then
    GetGBAFrame(printBugInfo())
  else
    printHelp()
  end
end

-- display help in player's chat window
function printHelp()
  print("----- |cff26c426Guild Bank Audit Options|r -----")
  print("Type the slash command followed by one of the options below -> '/gba command'")
  print("|cff5fe65dall|r", " - Scans your entire guild bank. |cffc21e1eYou must click on each tab in your guild bank before running this command.|r")
  print("|cff5fe65dtab|r", " - Scans the current tab open in your guild bank.")
  print("|cff5fe65dhelp|r", " - Displays this information here.")
  print("|cff5fe65dbugged|r", " - Get the link report any bugs.")
  print("------------------------------------")
end

--scans the current tab the player is looking at
function scanTab()
  wipe(SavedItems)
  wipe(SavedItemCounts)
  local tableCount = 0
  local outText = ''
  local currentTab = GetCurrentGuildBankTab()
  for i = 1, ItemsPerTab, 1 do
    local itemTex, itemCount, itemLocked, itemFiltered, itemQuality = GetGuildBankItemInfo(currentTab, i)
    local itemName = GetGuildBankItemLink(currentTab, i)
    if itemName ~= nil then
      local cleanName = cleanString(itemName)
      if (checkTable(SavedItems, cleanName) ~= true) then
        tinsert(SavedItems, cleanName)
        tinsert(SavedItemCounts, itemCount)
        tableCount = tableCount + 1
      else
        SavedItemCounts[searchTable(SavedItems, cleanName)] = SavedItemCounts[searchTable(SavedItems, cleanName)] + itemCount
      end
    end
  end

  local  outLength = getTableLength(SavedItems)
  for i = 1, outLength, 1 do
    outText = outText .. SavedItems[i] .. ', ' .. SavedItemCounts[i] .. '\n'
  end
  print("|cff26c426Guild Bank Tab Audit Complete!|r")
  return outText
end

-- scans entire loaded guild bank (cannot load bank for you)
function scanBank()
  wipe(SavedItems)
  wipe(SavedItemCounts)
  local tableCount = 0
  local outText = ''
  local numTabs = GetNumGuildBankTabs()
  for i = 1, numTabs, 1 do
    for k = 1, ItemsPerTab, 1 do
      local itemTex, itemCount, itemLocked, itemFiltered, itemQuality = GetGuildBankItemInfo(i, k)
      local itemName = GetGuildBankItemLink(i, k)
      if itemName ~= nil then
        local cleanName = cleanString(itemName)
        if (checkTable(SavedItems, cleanName) ~= true) then
          tinsert(SavedItems, cleanName)
          tinsert(SavedItemCounts, itemCount)
          tableCount = tableCount + 1
        else
          SavedItemCounts[searchTable(SavedItems, cleanName)] = SavedItemCounts[searchTable(SavedItems, cleanName)] + itemCount
        end
      end
    end
  end
  local  outLength = getTableLength(SavedItems)
  for i = 1, outLength, 1 do
    outText = outText .. SavedItems[i] .. ', ' .. SavedItemCounts[i] .. '\n'
  end
  print("|cff26c426Guild Bank Audit Complete!|r")
  return outText
end

--grabs the money log info
function getMoneyLog()
  local outText = ''
  local numTabs = GetNumGuildBankTabs()
  local rawMoney = GetGuildBankMoney()
  local guildBankMoney = rawMoney / 100 / 100
  local moneyDifference = 0

  if LastGoldCheck == nil then
    LastGoldCheck = guildBankMoney
  end

  outText = outText .. "Current: " .. guildBankMoney .. "\n"

  if guildBankMoney ~= LastGoldCheck then
    local bitString
    if guildBankMoney > LastGoldCheck then
      moneyDifference = guildBankMoney - LastGoldCheck
      bitString = '+'
    end
    if guildBankMoney < LastGoldCheck then
      moneyDifference = LastGoldCheck - guildBankMoney
      bitString = '-'
    end
    outText = outText .. "Difference from last audit: " .. bitString .. moneyDifference .. "\n"
  else
    outText = outText .. "Difference from last audit: 0" .. "\n"
  end

  QueryGuildBankLog(numTabs + 1)
  local numMoneyTransactions = GetNumGuildBankMoneyTransactions()
  local tableCount = 0
  for i = numMoneyTransactions, 1, -1 do
    local typeString, player, amount, dateYear, dateMonth, dateDay, dateHour = GetGuildBankMoneyTransaction(i)
    amount = amount / 100 / 100
    if typeString == 'buyTab' then
      typeString = 'buys tab'
    end
    outText = outText .. player .. " " .. typeString .. " " .. amount .. " "
    if dateYear ~= nil then
      outText = outText .. dateYear .. " years ago" .. "\n"
    elseif dateYear == nil and dateMonth ~= nil then
      outText = outText .. dateMonth .. " months ago" .. "\n"
    elseif dateYear == nil and dateMonth == nil and dateDay ~= nil then
      outText = outText .. dateDay .. " days ago" .. "\n"
    else
      outText = outText .. dateHour .. " hours ago" .. "\n"
    end
  end

  LastGoldCheck = guildBankMoney
  print("|cff26c426Guild Money Log Audit Complete!|r")
  return outText
end
---------------------------------------------
--                UTILITY                  --
---------------------------------------------

--clean up item strings because theyre nasty
function cleanString(itemName)
  local _, newItemName = strsplit("[", itemName)
  local clean, _ = strsplit("]", newItemName)
  return clean
end

--get length of given table
function getTableLength(table)
  local outNumber = 0
  for _ in pairs(table) do
    outNumber = outNumber + 1
  end
  return outNumber
end

--check if element exists in given table
function checkTable(table, element)
  for _, value in pairs(table) do
    if (value == element) then
      return true
    end
  end
  return false
end

--search for the position of given element within table
function searchTable(table, element)
  for pos, value in pairs(table) do
    if (value == element) then
      return pos
    end
  end
end

---------------------------------------------
--             FRAME INIT                  --
---------------------------------------------

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

--display issue tracker for bug reporting
function printBugInfo()
  local outText = 'https://github.com/ToastyDev/GuildBankAudit/issues'
  return outText
end
