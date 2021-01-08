SLASH_GUILDBANKAUDIT1 = "/guildbankaudit"
SLASH_GUILDBANKAUDIT2 = "/gba"
SLASH_GUILDBANKAUDIT3 = "/gbank"

function SlashCmdList.GUILDBANKAUDIT(cmd, editbox)
  local request, arg = strsplit(' ', cmd)
  if request == "all" then
    print("GBA Get All Bank")
  elseif request  == "tab" then
    print("GBA Get Current Tab")
  elseif request  == "help" then
    printHelp()
  else
    printHelp()
  end
end


function printHelp()
  print("----- |cff26c426Guild Bank Audit Options|r -----")
  print("type the slash command followed by one of the options below -> '/gba command'")
  print("|cff5fe65dall|r", " - Scans your entire guild bank.")
  print("|cff5fe65dtab|r", " - Scans the current tab open in your guild bank.")
  print("|cff5fe65dhelp|r", " - Displays this information here.")
  print("------------------------------------")
end
