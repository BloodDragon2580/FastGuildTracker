-- Centralized locales for all common WoW clients
-- Fallback: enUS

local LOCALE = GetLocale()

local Base = {
  -- Generic
  title        = "FastGuildTracker",
  desc         = "Options for FastGuildTracker",
  name_col     = "Name",
  runs_col     = "M+ Runs",
  rating_col   = "M+ Rating",
  best_col     = "Best Raid Kill",
  leftClick    = "Left-click: toggle window",
  rightClick   = "Right-click: help",
  helpCmd      = "Commands: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Show only online members",
  showMinimap  = "Show minimap icon",
  minimap_on   = "Minimap button |cff44ff44shown|r.",
  minimap_off  = "Minimap button |cffff4444hidden|r.",
  openOptions  = "Open options",
}

local L = {}

-- English (default)
L.enUS = Base

-- German
L.deDE = {
  title        = "FastGuildTracker",
  desc         = "Optionen für FastGuildTracker",
  name_col     = "Name",
  runs_col     = "M+ Läufe",
  rating_col   = "M+ Wertung",
  best_col     = "Bester Raid-Kill",
  leftClick    = "Linksklick: Fenster ein-/ausblenden",
  rightClick   = "Rechtsklick: Hilfe",
  helpCmd      = "Befehle: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Nur Online-Mitglieder anzeigen",
  showMinimap  = "Minimap-Icon anzeigen",
  minimap_on   = "Minimap-Button |cff44ff44eingeblendet|r.",
  minimap_off  = "Minimap-Button |cffff4444ausgeblendet|r.",
  openOptions  = "Optionen öffnen",
}

-- French
L.frFR = {
  desc         = "Options pour FastGuildTracker",
  name_col     = "Nom",
  runs_col     = "Donjons M+",
  rating_col   = "Score M+",
  best_col     = "Meilleur kill de raid",
  leftClick    = "Clic gauche : afficher/masquer",
  rightClick   = "Clic droit : aide",
  helpCmd      = "Commandes : /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Afficher seulement les membres en ligne",
  showMinimap  = "Afficher l’icône de la minicarte",
  minimap_on   = "Bouton minicarte |cff44ff44affiché|r.",
  minimap_off  = "Bouton minicarte |cffff4444caché|r.",
  openOptions  = "Ouvrir les options",
}

-- Spanish (EU)
L.esES = {
  desc         = "Opciones de FastGuildTracker",
  name_col     = "Nombre",
  runs_col     = "Mazmorras M+",
  rating_col   = "Puntuación M+",
  best_col     = "Mejor jefe de banda",
  leftClick    = "Clic izquierdo: mostrar/ocultar",
  rightClick   = "Clic derecho: ayuda",
  helpCmd      = "Comandos: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Mostrar solo miembros conectados",
  showMinimap  = "Mostrar icono del minimapa",
  minimap_on   = "Botón del minimapa |cff44ff44visible|r.",
  minimap_off  = "Botón del minimapa |cffff4444oculto|r.",
  openOptions  = "Abrir opciones",
}

-- Spanish (LA)
L.esMX = {
  desc         = "Opciones de FastGuildTracker",
  name_col     = "Nombre",
  runs_col     = "Mazmorras M+",
  rating_col   = "Puntuación M+",
  best_col     = "Mejor jefe de banda",
  leftClick    = "Clic izq.: mostrar/ocultar",
  rightClick   = "Clic der.: ayuda",
  helpCmd      = "Comandos: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Mostrar solo miembros en línea",
  showMinimap  = "Mostrar ícono del minimapa",
  minimap_on   = "Botón del minimapa |cff44ff44visible|r.",
  minimap_off  = "Botón del minimapa |cffff4444oculto|r.",
  openOptions  = "Abrir opciones",
}

-- Portuguese (BR)
L.ptBR = {
  desc         = "Opções do FastGuildTracker",
  name_col     = "Nome",
  runs_col     = "MasM+",
  rating_col   = "Índice M+",
  best_col     = "Melhor chefe de raide",
  leftClick    = "Clique esq.: mostrar/ocultar",
  rightClick   = "Clique dir.: ajuda",
  helpCmd      = "Comandos: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Mostrar apenas membros online",
  showMinimap  = "Mostrar ícone do minimapa",
  minimap_on   = "Botão do minimapa |cff44ff44visível|r.",
  minimap_off  = "Botão do minimapa |cffff4444oculto|r.",
  openOptions  = "Abrir opções",
}

-- Italian
L.itIT = {
  desc         = "Opzioni di FastGuildTracker",
  name_col     = "Nome",
  runs_col     = "Spedizioni M+",
  rating_col   = "Punteggio M+",
  best_col     = "Miglior uccisione raid",
  leftClick    = "Clic sin.: mostra/nascondi",
  rightClick   = "Clic dest.: aiuto",
  helpCmd      = "Comandi: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Mostra solo membri online",
  showMinimap  = "Mostra icona minimappa",
  minimap_on   = "Pulsante minimappa |cff44ff44visibile|r.",
  minimap_off  = "Pulsante minimappa |cffff4444nascosto|r.",
  openOptions  = "Apri opzioni",
}

-- Russian
L.ruRU = {
  desc         = "Настройки FastGuildTracker",
  name_col     = "Имя",
  runs_col     = "Ключи M+",
  rating_col   = "Рейтинг M+",
  best_col     = "Лучший босс рейда",
  leftClick    = "ЛКМ: показать/скрыть окно",
  rightClick   = "ПКМ: помощь",
  helpCmd      = "Команды: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Показывать только онлайн-участников",
  showMinimap  = "Показывать значок на миникарте",
  minimap_on   = "Кнопка миникарты |cff44ff44включена|r.",
  minimap_off  = "Кнопка миникарты |cffff4444выключена|r.",
  openOptions  = "Открыть настройки",
}

-- Korean
L.koKR = {
  desc         = "FastGuildTracker 설정",
  name_col     = "이름",
  runs_col     = "M+ 던전",
  rating_col   = "M+ 점수",
  best_col     = "최고 레이드 처치",
  leftClick    = "좌클릭: 창 토글",
  rightClick   = "우클릭: 도움말",
  helpCmd      = "명령어: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "온라인 길드원만 표시",
  showMinimap  = "미니맵 아이콘 표시",
  minimap_on   = "미니맵 버튼 |cff44ff44표시됨|r.",
  minimap_off  = "미니맵 버튼 |cffff4444숨김|r.",
  openOptions  = "옵션 열기",
}

-- Chinese (Simplified)
L.zhCN = {
  desc         = "FastGuildTracker 选项",
  name_col     = "名字",
  runs_col     = "大秘境次数",
  rating_col   = "大秘境分数",
  best_col     = "最佳团队首领",
  leftClick    = "左键：打开/关闭窗口",
  rightClick   = "右键：帮助",
  helpCmd      = "命令：/fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "仅显示在线成员",
  showMinimap  = "显示小地图图标",
  minimap_on   = "小地图按钮|cff44ff44已显示|r。",
  minimap_off  = "小地图按钮|cffff4444已隐藏|r。",
  openOptions  = "打开选项",
}

-- Chinese (Traditional)
L.zhTW = {
  desc         = "FastGuildTracker 選項",
  name_col     = "名字",
  runs_col     = "大祕境次數",
  rating_col   = "大祕境分數",
  best_col     = "最佳團隊首領",
  leftClick    = "左鍵：開關視窗",
  rightClick   = "右鍵：說明",
  helpCmd      = "指令：/fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "只顯示上線成員",
  showMinimap  = "顯示小地圖圖示",
  minimap_on   = "小地圖按鈕|cff44ff44已顯示|r。",
  minimap_off  = "小地圖按鈕|cffff4444已隱藏|r。",
  openOptions  = "開啟選項",
}

-- Select best match
local Dict = L[LOCALE] or Base

-- Safe fallback: any missing key returns English, then key
setmetatable(Dict, {
  __index = function(_, k)
    return (Base[k]) or k
  end
})

-- Expose
_G.FastGuildTrackerLocale = Dict
