local ADDON_NAME = ...
local ADDON_DB   = "FastGuildTrackerDB"
local L          = _G.FastGuildTrackerLocale or { title="FastGuildTracker" }

-- ============================================================================
-- Config
local DEBUG_MODE         = false
local TABLE_COLUMN_NUM   = 4
local TABLE_COLUMN_WIDTH = 150
local ROW_HEIGHT         = 24
local FADE_WHILE_MOVING  = true
local ONLY_ONLINE        = true
-- ============================================================================

local function debugPrint(...) if DEBUG_MODE then print("|cff33ff99FGT:|r", ...) end end

-- SavedVariables defaults
local function EnsureDefaults()
  _G[ADDON_DB] = _G[ADDON_DB] or {}
  local db = _G[ADDON_DB]
  db.minimap    = db.minimap or { hide = false }
  if db.showMinimap == nil then db.showMinimap = true end
  if db.onlyOnline  == nil then db.onlyOnline  = true end
  db.minimapNudge = db.minimapNudge or { x = 0, y = 0 }  -- << NEU
  return db
end

-- Addon table
local FGT = CreateFrame("Frame"); _G.FastGuildTracker = FGT
FGT:SetScript("OnEvent", function(self, event, ...) if self[event] then self[event](self, ...) end end)

local CreateWindow, Populate
local mainFrame
local isReloading = false

-- Public API for options
function FGT:GetDB() return EnsureDefaults() end
function FGT:SetOnlyOnline(enabled)
  local db = EnsureDefaults()
  db.onlyOnline = not not enabled
  ONLY_ONLINE   = db.onlyOnline
  if mainFrame then Populate(mainFrame) end
end
function FGT:SetMinimapShown(enabled)
  local db   = EnsureDefaults()
  local show = not not enabled
  db.showMinimap  = show
  db.minimap.hide = not show
  if self.ldbIcon and self.ldbIcon:IsRegistered("FastGuildTracker") then
    if show then self.ldbIcon:Show("FastGuildTracker") else self.ldbIcon:Hide("FastGuildTracker") end
    if L.minimap_on then print("|cff33ff99FGT:|r "..(show and L.minimap_on or L.minimap_off)) end
  end
end

-- UI helpers
local function OnUpdate(self)
  if not FADE_WHILE_MOVING then return end
  self:SetAlpha((IsPlayerMoving() and not self:IsMouseOver()) and 0.5 or 1.0)
end

local function CreateHorizontalLine(parent, yOffset)
  local line = parent:CreateLine()
  line:SetColorTexture(0, 0, 0, 0.8)
  line:SetThickness(1)
  line:SetStartPoint("TOPLEFT", 0, yOffset)
  line:SetEndPoint("TOPRIGHT", 0, yOffset)
  return line
end

-- ============================================================================
-- Modernes Fenster (Custom, kein PortraitFrameTemplate)
local function CreateModernContainer()
  local f = CreateFrame("Frame", "FastGuildTrackerFrame", UIParent, "BackdropTemplate")
  f:SetSize(680, 400)
  f:SetPoint("CENTER")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, r, rp, x, y = self:GetPoint()
    local db = EnsureDefaults()
    db.position = { p, r, rp, x, y }
  end)
  f:SetScript("OnMouseDown", function(self) self:SetToplevel(true) end)
  f:SetScript("OnUpdate", OnUpdate)
  f:SetClampedToScreen(true)
  f:SetFrameStrata("MEDIUM")
  f:Hide() -- nicht auto-öffnen

  -- Hintergrund (modern: dunkles, leicht transparentes Panel)
  -- Nutzt einfarbige Texturen für „Card“-Look + subtile Ränder
  local bg = f:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.08, 0.09, 0.10, 0.95) -- fast schwarz, leicht transparent

  -- Rand (feine 1px Kontur)
  local border = CreateFrame("Frame", nil, f, "BackdropTemplate")
  border:SetPoint("TOPLEFT", 1, -1)
  border:SetPoint("BOTTOMRIGHT", -1, 1)
  border:SetBackdrop({
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  border:SetBackdropBorderColor(0, 0, 0, 1)

  -- Drop Shadow (dezente Außenkante)
  local shadow = f:CreateTexture(nil, "BACKGROUND", nil, -1)
  shadow:SetPoint("TOPLEFT", -6, 6)
  shadow:SetPoint("BOTTOMRIGHT", 6, -6)
  shadow:SetTexture("Interface\\Buttons\\WHITE8x8")
  shadow:SetVertexColor(0, 0, 0, 0.35)

  -- Titlebar (klare, moderne Kopfzeile)
  local bar = f:CreateTexture(nil, "ARTWORK")
  bar:SetPoint("TOPLEFT", 0, 0)
  bar:SetPoint("TOPRIGHT", 0, 0)
  bar:SetHeight(36)
  bar:SetColorTexture(0.12, 0.14, 0.18, 1) -- dunkler Balken

  local underline = f:CreateTexture(nil, "ARTWORK")
  underline:SetPoint("TOPLEFT", 0, -36)
  underline:SetPoint("TOPRIGHT", 0, -36)
  underline:SetHeight(1)
  underline:SetColorTexture(0, 0, 0, 1)

  -- Titel (wirklich zentriert innerhalb des Frames)
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", f, "TOP", 0, -9)
  title:SetText(L.title or "FastGuildTracker")
  title:SetJustifyH("CENTER")
  title:SetTextColor(1, 1, 1, 1)
  title:SetShadowColor(0, 0, 0, 1)
  title:SetShadowOffset(1, -1)
  f.TitleText = title

  -- Close-Button (schlicht)
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScale(0.9)

  -- Header-Zeile (Spalten-Leiste)
  local header = CreateFrame("Frame", nil, f)
  header:SetPoint("TOPLEFT", 12, -44)
  header:SetPoint("TOPRIGHT", -12, -44)
  header:SetHeight(26)

  local headerBg = header:CreateTexture(nil, "ARTWORK")
  headerBg:SetAllPoints()
  headerBg:SetColorTexture(0.16, 0.18, 0.22, 1)

  local headerLine = header:CreateTexture(nil, "ARTWORK")
  headerLine:SetPoint("BOTTOMLEFT")
  headerLine:SetPoint("BOTTOMRIGHT")
  headerLine:SetHeight(1)
  headerLine:SetColorTexture(0, 0, 0, 1)

  -- ScrollFrame + Content
  local scrollFrame = CreateFrame("ScrollFrame", "FastGuildTrackerScroll", f, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 12, -72)
  scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12) -- Platz für Scrollbar

  local content = CreateFrame("Frame", nil, scrollFrame)
  scrollFrame:SetScrollChild(content)
  content:SetSize(900, 800)
  content.rows = {}
  f.content = content

  -- Header-Zeile (Texte)
  local function CreateHeaderText(parent, x, text)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("LEFT", parent, "LEFT", x, 0)
    fs:SetWidth(TABLE_COLUMN_WIDTH)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    fs:SetTextColor(1, 1, 1, 0.95)
    fs:SetShadowColor(0, 0, 0, 1)
    fs:SetShadowOffset(1, -1)
    return fs
  end

  f.header = header
  f.h1 = CreateHeaderText(header, 0,     L.name_col   or "Name")
  f.h2 = CreateHeaderText(header, 1*TABLE_COLUMN_WIDTH, L.runs_col   or "M+ Runs")
  f.h3 = CreateHeaderText(header, 2*TABLE_COLUMN_WIDTH, L.rating_col or "M+ Rating")
  f.h4 = CreateHeaderText(header, 3*TABLE_COLUMN_WIDTH, L.best_col   or "Best Raid Kill")

  -- gespeicherte Position übernehmen
  local db = EnsureDefaults()
  if db.position then f:ClearAllPoints(); f:SetPoint(unpack(db.position)) end

  return f
end

CreateWindow = function()
  local frame = CreateModernContainer()

  -- Row-Factory im modernen Look
  local function ensureRow(idx)
    if frame.content.rows[idx] then return frame.content.rows[idx] end

    local row = CreateFrame("Frame", nil, frame.content)
    row:SetSize(TABLE_COLUMN_WIDTH * TABLE_COLUMN_NUM, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 12, -((idx-1) * ROW_HEIGHT))

    -- Zebra-Hintergrund
    if (idx % 2 == 0) then
      local z = row:CreateTexture(nil, "BACKGROUND")
      z:SetAllPoints()
      z:SetColorTexture(1, 1, 1, 0.02) -- ganz subtil
      row.zebra = z
    end

    row.cols = {}
    for j = 1, TABLE_COLUMN_NUM do
      local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      fs:SetPoint("LEFT", (j-1)*TABLE_COLUMN_WIDTH, 0)
      fs:SetWidth(TABLE_COLUMN_WIDTH)
      fs:SetJustifyH("LEFT")
      fs:SetTextColor(0.9, 0.9, 0.9, 1) -- Standardhelligkeit
      fs:SetShadowColor(0,0,0,1)
      fs:SetShadowOffset(1, -1)
      row.cols[j] = fs
    end

    frame.content.rows[idx] = row
    return row
  end

  frame.ensureRow = ensureRow
  return frame
end

function FGT:Toggle()
  if not mainFrame then mainFrame = CreateWindow() end
  if mainFrame:IsShown() then HideUIPanel(mainFrame) else ShowUIPanel(mainFrame) end
end

-- ============================================================================
-- RaiderIO lookup
local function GetRIOForUnit(unitName)
  if not RaiderIO or not unitName or unitName == "" then return nil end
  local profile = RaiderIO.GetProfile(unitName); if not profile then return nil end

  local raidProgress, raidDifficulty = "N/A", nil
  if profile.raidProfile and profile.raidProfile.progress and profile.raidProfile.progress[1] then
    raidDifficulty = profile.raidProfile.progress[1].difficulty
    raidProgress   = profile.raidProfile.progress[1].progressCount
  end
  if raidDifficulty == 1 then raidDifficulty = "Normal"
  elseif raidDifficulty == 2 then raidDifficulty = "Heroic"
  elseif raidDifficulty == 3 then raidDifficulty = "Mythic" end
  if raidProgress ~= "N/A" and raidDifficulty then raidDifficulty = " ["..raidDifficulty.."]" else raidDifficulty = "" end

  local runs, score = 0, "N/A"
  if profile.mythicKeystoneProfile then
    for k=1,30 do runs = runs + (profile.mythicKeystoneProfile["keystoneMilestone"..k] or 0) end
    score = profile.mythicKeystoneProfile.currentScore or "N/A"
  end
  return { runs = runs, mplusScore = score, raid = raidProgress, raidDifficulty = raidDifficulty }
end

-- ============================================================================
-- Daten sammeln
local function CollectGuildData()
  local data = {}
  if not IsInGuild() then return data end

  if C_GuildInfo and C_GuildInfo.GuildRoster then C_GuildInfo.GuildRoster() else GuildRoster() end

  local total = GetNumGuildMembers() or 0
  local db = EnsureDefaults()
  ONLY_ONLINE = db.onlyOnline and true or false

  for i=1,total do
    local name, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
    if name then
      local unitName = name
      if not unitName:find("-", 1, true) then
        local rn = GetNormalizedRealmName()
        if rn then unitName = unitName .. "-" .. rn:gsub("^%l", string.upper) end
      end
      if (not ONLY_ONLINE) or isOnline then
        table.insert(data, {
          name = name:gsub("%-.*$", ""),
          rio  = GetRIOForUnit(unitName),
          isOnline = isOnline and true or false,
        })
      end
    end
  end

  local myFull = UnitFullName("player")
  local myName = UnitName("player")
  local rioMe  = GetRIOForUnit(myFull or myName)
  return data, { name = myName, rio = rioMe, isOnline = true }
end

-- ============================================================================
-- Rendering
local function setCell(fs, text) fs:SetFontObject("QuestFontNormalSmall"); fs:SetText(tostring(text or "")) end

Populate = function(frame)
  local content = frame.content
  for i = #content.rows, 1, -1 do
    if content.rows[i] then content.rows[i]:Hide(); content.rows[i] = nil end
  end

  local guildData, me = CollectGuildData()
  if (#guildData == 0) and (not me or not me.rio) then return end

  -- Header-Zeile als Zeile 1 (für einfachere y-Berechnung)
  local headerRow = frame.ensureRow(1)
  headerRow:ClearAllPoints()
  headerRow:SetPoint("TOPLEFT", 12, 0)
  headerRow:SetHeight(0.1) -- unsichtbarer Platzhalter, optische Header ist oben separater Balken

  local rowIndex = 2
  for _, entry in ipairs(guildData) do
    local r = frame.ensureRow(rowIndex); r:Show()

    -- Name farbig mit Schatten (online grün, offline rot)
    r.cols[1]:SetFontObject("GameFontHighlightSmall")
    r.cols[1]:SetText(entry.name or "?")
    if entry.isOnline then
      r.cols[1]:SetTextColor(0.20, 0.95, 0.30, 1)   -- modern green
    else
      r.cols[1]:SetTextColor(0.95, 0.30, 0.30, 1)   -- modern red
    end
    r.cols[1]:SetShadowColor(0,0,0,1); r.cols[1]:SetShadowOffset(1,-1)

    local runs     = entry.rio and entry.rio.runs or "N/A"
    local score    = entry.rio and entry.rio.mplusScore or "N/A"
    local raidText = (entry.rio and entry.rio.raid or "N/A") .. (entry.rio and entry.rio.raidDifficulty or "")
    setCell(r.cols[2], runs); setCell(r.cols[3], score); setCell(r.cols[4], raidText)

    rowIndex = rowIndex + 1
  end

  if me and me.rio then
    local sep = CreateHorizontalLine(content, -((rowIndex-1) * ROW_HEIGHT))
    local r = frame.ensureRow(rowIndex); r:Show()
    r.cols[1]:SetFontObject("DialogButtonHighlightText"); r.cols[1]:SetText(me.name)
    r.cols[1]:SetTextColor(0.20, 0.95, 0.30, 1)
    r.cols[1]:SetShadowColor(0,0,0,1); r.cols[1]:SetShadowOffset(1,-1)
    setCell(r.cols[2], me.rio.runs or "N/A")
    setCell(r.cols[3], me.rio.mplusScore or "N/A")
    local raidText = (me.rio.raid or "N/A") .. (me.rio.raidDifficulty or "")
    setCell(r.cols[4], raidText)
  end

  local totalRows = (#guildData > 0 and (#guildData + 2) or 3)
  content:SetHeight(totalRows * ROW_HEIGHT + 20)
end

-- ============================================================================
-- Events / Init
FGT:RegisterEvent("ADDON_LOADED")
FGT:RegisterEvent("PLAYER_LOGIN")
FGT:RegisterEvent("PLAYER_ENTERING_WORLD")
FGT:RegisterEvent("PLAYER_GUILD_UPDATE")
FGT:RegisterEvent("GUILD_ROSTER_UPDATE")

function FGT:ADDON_LOADED(name)
  if name ~= ADDON_NAME then return end
  local db = EnsureDefaults()
  ONLY_ONLINE = db.onlyOnline and true or false
  self:RegisterMinimap()
end

function FGT:PLAYER_ENTERING_WORLD(_, isReloadingUi) isReloading = isReloadingUi end
function FGT:PLAYER_LOGIN()
  C_Timer.After(1.0, function()
    if not mainFrame then mainFrame = CreateWindow() end
    Populate(mainFrame) -- baut nur Inhalte, zeigt nicht automatisch
  end)
end
function FGT:PLAYER_GUILD_UPDATE() if mainFrame then Populate(mainFrame) end end
function FGT:GUILD_ROSTER_UPDATE() if mainFrame then Populate(mainFrame) end end

-- ============================================================================
-- Slash
SLASH_FGT1 = "/fgt"
SlashCmdList["FGT"] = function(msg)
  msg = (msg and msg:lower() or "")
  if msg == "minimap" or msg == "mm" then
    local db = EnsureDefaults()
    FGT:SetMinimapShown(db.minimap.hide) -- toggle
    return
  elseif msg == "options" or msg == "opt" or msg == "config" then
    if Settings and Settings.OpenToCategory then Settings.OpenToCategory(L.title)
    elseif InterfaceOptionsFrame_OpenToCategory then InterfaceOptionsFrame_OpenToCategory(L.title); InterfaceOptionsFrame_OpenToCategory(L.title) end
    return
  end
  FGT:Toggle()
end

-- ============================================================================
-- Minimap (LDB + LibDBIcon)
function FGT:RegisterMinimap()
  local ldb     = LibStub and LibStub("LibDataBroker-1.1", true)
  local ldbIcon = LibStub and LibStub("LibDBIcon-1.0", true)
  if not (ldb and ldbIcon) then
    debugPrint("LibDataBroker/LibDBIcon missing (OptionalDeps).")
    return
  end

  local defaultGuildIcon = "Interface\\Icons\\INV_Banner_03"
  local dataObj = ldb:NewDataObject("FastGuildTracker", {
    type = "launcher",
    text = "FGT",
    icon = defaultGuildIcon, -- kein iconCoords hier, wir croppen später selbst
    OnClick = function(_, button)
      if button == "LeftButton" then
        FGT:Toggle()
      elseif button == "RightButton" then
        if L.helpCmd then print("|cff33ff99FGT:|r " .. L.helpCmd) end
      end
    end,
    OnTooltipShow = function(tt)
      tt:AddLine(L.title or "FastGuildTracker")
      tt:AddLine(L.leftClick or "Left-click: toggle window", 0.2, 1, 0.2)
      tt:AddLine(L.rightClick or "Right-click: help", 0.8, 0.8, 0.8)
    end,
  })

  if dataObj then
    local db = EnsureDefaults()
    ldbIcon:Register("FastGuildTracker", dataObj, db.minimap)
    FGT.ldbIcon = ldbIcon

    -- >>> ZENTRIERUNG & CROPPING (robust gegen spätere Lib-Änderungen)
    local btn = ldbIcon.GetMinimapButton and ldbIcon:GetMinimapButton("FastGuildTracker")
    if btn and btn.icon then
      local inset = 7
      local nx = (db.minimapNudge and db.minimapNudge.x) or 0
      local ny = (db.minimapNudge and db.minimapNudge.y) or 0

      btn.icon:ClearAllPoints()
      -- Symmetrische Innenabstände + optionaler Nudge
      btn.icon:SetPoint("TOPLEFT",     btn, "TOPLEFT",     inset - nx, -inset - ny)
      btn.icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -inset - nx, inset + ny)

      -- Gleichmäßiger Crop (verhindert optisches „Rutschen“)
      btn.icon:SetTexCoord(0.12, 0.88, 0.12, 0.88) -- feinere, zentrierte Variante
      btn.icon:SetDrawLayer("ARTWORK", 1)

      -- Falls eine Lib später wieder SetAllPoints() setzt: sofort neutralisieren
      hooksecurefunc(btn.icon, "SetAllPoints", function(self)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT",     btn, "TOPLEFT",     inset - nx, -inset - ny)
        self:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -inset - nx, inset + ny)
      end)
    end
    -- <<<

    if db.minimap.hide then
      ldbIcon:Hide("FastGuildTracker")
    else
      ldbIcon:Show("FastGuildTracker")
    end
  end
end

function FGT:SetMinimapIcon(icon)
  if not self.ldbIcon or not self.ldbIcon:IsRegistered("FastGuildTracker") then return end
  self.ldbIcon:SetIcon("FastGuildTracker", icon)
end

function FGT:SetMinimapIconNudge(x, y)
  local db = EnsureDefaults()
  db.minimapNudge.x, db.minimapNudge.y = x or 0, y or 0
  if self.ldbIcon and self.ldbIcon.GetMinimapButton then
    local btn = self.ldbIcon:GetMinimapButton("FastGuildTracker")
    if btn and btn.icon then
      btn.icon:ClearAllPoints()
      btn.icon:SetPoint("CENTER", btn, "CENTER", db.minimapNudge.x, db.minimapNudge.y)
    end
  end
end
