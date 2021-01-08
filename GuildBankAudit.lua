SavedBankItemInfo = {}
local ItemsPerTab = 98

SLASH_GUILDBANKAUDIT1 = "/guildbankaudit"
SLASH_GUILDBANKAUDIT2 = "/gba"
SLASH_GUILDBANKAUDIT3 = "/gbank"

function SlashCmdList.GUILDBANKAUDIT(cmd, editbox)
  local request, arg = strsplit(' ', cmd)
  if request == "all" then
    scanBank()
  elseif request  == "tab" then
    scanTab()
  elseif request  == "help" then
    printHelp()
  else
    printHelp()
  end
end


function printHelp()
  print("----- |cff26c426Guild Bank Audit Options|r -----")
  print("Type the slash command followed by one of the options below -> '/gba command'")
  print("|cff5fe65dall|r", " - Scans your entire guild bank.")
  print("|cff5fe65dtab|r", " - Scans the current tab open in your guild bank.")
  print("|cff5fe65dhelp|r", " - Displays this information here.")
  print("------------------------------------")
end

function scanBank()
  -- get number of tabs
  -- for each tab (GetGuildBankTabInfo)
  -- for each item (GetGuildBankItemInfo)
  -- save to table
  local numTabs = GetNumGuildBankTabs()
  for i = 1, numTabs, 1 do
    --local tabName, tabIcon, tabViewable, tabCanDeposit, tabNumWithdrawls, tabRemainingWithdrawals = GetGuildBankTabInfo(i)
    for k = 1, ItemsPerTab, 1 do
      local itemTex, itemCount, itemLocked, itemFiltered, itemQuality = GetGuildBankItemInfo(i, k)
      local itemName = GetGuildBankItemLink(i, k)
      if itemName ~= nil then
        tinsert(SavedBankItemInfo, format("%s, %c,", itemName, tostring(itemCount)))
      end
    end
  end
  print("|cff26c426Guild Bank Audit Complete!|r")
end

function scanTab()
  -- get current tab
  -- for each item
  -- save to table
  local currentTab = GetCurrentGuildBankTab()
  for i = 1, ItemsPerTab, 1 do
    local itemTex, itemCount, itemLocked, itemFiltered, itemQuality = GetGuildBankItemInfo(currentTab, i)
    local itemName = GetGuildBankItemLink(currentTab, i)
    if itemName ~= nil then
      tinsert(SavedBankItemInfo, format("%s, %c,", itemName, tostring(itemCount)))
    end
  end
  print("|cff26c426Guild Bank Tab Audit Complete!|r")
end
