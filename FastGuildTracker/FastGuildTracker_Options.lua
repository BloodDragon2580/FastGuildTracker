local FGT = _G.FastGuildTracker
local L   = _G.FastGuildTrackerLocale or { title="FastGuildTracker", desc="Options" }
if not FGT then return end

-- Options Panel
local parent = (InterfaceOptionsFramePanelContainer and InterfaceOptionsFramePanelContainer) or UIParent
local panel = CreateFrame("Frame", "FastGuildTrackerOptionsPanel", parent)
panel.name = L.title

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16); title:SetText(L.title)

local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
desc:SetText(L.desc)

local function CreateCheckbox(y, label, getter, setter)
  local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, y)
  cb.Text:SetText(label)
  cb:SetScript("OnShow", function() cb:SetChecked(getter()) end)
  cb:SetScript("OnClick", function(self) setter(self:GetChecked() and true or false) end)
  return cb
end

-- Only Online
CreateCheckbox(-28, L.onlyOnline,
  function() local db = FGT:GetDB(); return db.onlyOnline and true or false end,
  function(val) FGT:SetOnlyOnline(val) end
)

-- Minimap icon
CreateCheckbox(-58, L.showMinimap,
  function() local db = FGT:GetDB(); return (not db.minimap.hide) and true or false end,
  function(val) FGT:SetMinimapShown(val) end
)

-- Register in DF Settings or legacy options
panel:Hide()
if Settings and Settings.RegisterAddOnCategory then
  local category = Settings.RegisterCanvasLayoutCategory(panel, L.title); category.ID = L.title
  Settings.RegisterAddOnCategory(category)
else
  InterfaceOptions_AddCategory(panel)
end
