local FGT = _G.FastGuildTracker
local L   = _G.FastGuildTrackerLocale or { title="FastGuildTracker", desc="Options" }
if not FGT then return end

local function L_KEY(k, fallbackEU) return L[k] or (fallbackEU and L["eu_"..fallbackEU]) or nil end

-- Options Panel
local parent = (InterfaceOptionsFramePanelContainer and InterfaceOptionsFramePanelContainer) or UIParent
local panel = CreateFrame("Frame", "FastGuildTrackerOptionsPanel", parent)
panel.name = L.title

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16); title:SetText(L.title)

local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
desc:SetText(L.desc or "Options for FastGuildTracker")

local function CreateCheckbox(y, label, getter, setter)
  local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, y)
  cb.Text:SetText(label)
  cb:SetScript("OnShow", function() cb:SetChecked(getter()) end)
  cb:SetScript("OnClick", function(self) setter(self:GetChecked() and true or false) end)
  return cb
end

-- Only Online
CreateCheckbox(-28, L.onlyOnline or "Show only online members",
  function() local db = FGT:GetDB(); return db.onlyOnline and true or false end,
  function(val) FGT:SetOnlyOnline(val) end
)

-- Minimap icon
CreateCheckbox(-58, L.showMinimap or "Show minimap icon",
  function() local db = FGT:GetDB(); return (not db.minimap.hide) and true or false end,
  function(val) FGT:SetMinimapShown(val) end
)

-- Debug logging (default: off)
CreateCheckbox(-88, L.debug_label or "Enable debug logging",
  function() return FGT:IsDebug() end,
  function(val) FGT:DebugEnable(val) end
)

-- === Region-DB Bereich ===
local dbTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
dbTitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -120)
dbTitle:SetText(L_KEY("db_status_title","status_title") or "Raider.IO Region Database")

local dbStatus = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
dbStatus:SetPoint("TOPLEFT", dbTitle, "BOTTOMLEFT", 0, -6)
dbStatus:SetText("...")

local dbButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
dbButton:SetSize(200, 22)
dbButton:SetPoint("TOPLEFT", dbStatus, "BOTTOMLEFT", 0, -6)
dbButton:SetText(L_KEY("db_load_now","load_now") or "Load Region DB now")

local function UpdateDBStatus()
  if not FGT or not FGT.CheckRegionDBLoaded then return end
  local ok, missing, tag = FGT:CheckRegionDBLoaded()
  dbTitle:SetText((L_KEY("db_status_title","status_title") or "Raider.IO Region Database").." ("..(tag or "?")..")")
  if ok then
    dbStatus:SetText(L_KEY("db_status_ok","status_ok") or "Region DB loaded")
    dbStatus:SetTextColor(0.2, 1.0, 0.2)
  else
    local m = table.concat(missing or {}, ", ")
    dbStatus:SetText((L_KEY("db_status_missing","status_missing") or "Region DB missing: %s"):format(m))
    dbStatus:SetTextColor(1.0, 0.2, 0.2)
  end
end

dbButton:SetScript("OnClick", function()
  if FGT and FGT.EnsureRegionDBLoaded then
    FGT:EnsureRegionDBLoaded()
    UpdateDBStatus()
  end
end)

panel:SetScript("OnShow", UpdateDBStatus)

panel:Hide()
if Settings and Settings.RegisterAddOnCategory then
  local category = Settings.RegisterCanvasLayoutCategory(panel, L.title); category.ID = L.title
  Settings.RegisterAddOnCategory(category)
else
  InterfaceOptions_AddCategory(panel)
end
