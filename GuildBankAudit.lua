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
    print("GBA Options Here!")
  else
    print("GBA Options Here!")
  end
end
