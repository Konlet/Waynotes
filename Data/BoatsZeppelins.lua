local _, ns = ...

-- Generated from Data/wow-forever-boats-zeppelins.json
-- World coordinates use continent mapId 0 (EK) / 1 (Kalimdor) / Forever instances.
-- Dock wx/wy prefer boardingPosition when present.

ns.NavTransports = {
    { routeId = 241, name = "The Maiden's Fancy", type = "boat", faction = "Both", cycleSeconds = 350.818 },
    { routeId = 285, name = "The Iron Eagle", type = "zeppelin", faction = "Horde", cycleSeconds = 303.463 },
    { routeId = 292, name = "The Lady Mehley", type = "boat", faction = "Alliance", cycleSeconds = 329.313 },
    { routeId = 293, name = "The Moonspray", type = "boat", faction = "Alliance", cycleSeconds = 316.251 },
    { routeId = 301, name = "The Purple Princess", type = "zeppelin", faction = "Horde", cycleSeconds = 333.044 },
    { routeId = 302, name = "The Thundercaller", type = "zeppelin", faction = "Horde", cycleSeconds = 356.284 },
    { routeId = 303, name = "Feathermoon Ferry", type = "boat", faction = "Alliance", cycleSeconds = 317.038 },
    { routeId = 11167, name = "The Bravery", type = "boat", faction = "Alliance", cycleSeconds = 486.183 },
    { routeId = 11391, name = "Steamwheedle Port to Powderfuse Port", type = "boat", faction = "Both", cycleSeconds = 271.107 },
    { routeId = 11398, name = "Valanaar to Dalaran", type = "skycutter", faction = "Alliance", cycleSeconds = 358.693 },
    { routeId = 11457, name = "Valanaar to Skywatcher Plateau", type = "zeppelin", faction = "Horde", cycleSeconds = 320.436 },
    { routeId = 11616, name = "Stormwind Harbor to Auberdine", type = "boat", faction = "Alliance", cycleSeconds = 247.096 },
}

ns.NavTransportDocks = {
    { dockId = 1, routeId = 241, name = "Ratchet", zone = "The Barrens", map = 1413, faction = "Both", type = "boat", routeName = "The Maiden's Fancy", wx = -1007.0, wy = -3824.9, wz = 6.0, instance = 1, dwellSeconds = 60.026, cycleSeconds = 350.818, forever = true },
    { dockId = 2, routeId = 241, name = "Booty Bay", zone = "Stranglethorn Vale", map = 1434, faction = "Both", type = "boat", routeName = "The Maiden's Fancy", wx = -14284.6, wy = 561.2, wz = 8.0, instance = 0, dwellSeconds = 60.027, cycleSeconds = 350.818, forever = true },
    { dockId = 3, routeId = 285, name = "Grom'gol Base Camp", zone = "Stranglethorn Vale", map = 1434, faction = "Horde", type = "zeppelin", routeName = "The Iron Eagle", wx = -12464.0, wy = 231.6, wz = 49.5, instance = 0, dwellSeconds = 60.03, cycleSeconds = 303.463, forever = true },
    { dockId = 4, routeId = 285, name = "Orgrimmar", zone = "Durotar", map = 1411, faction = "Horde", type = "zeppelin", routeName = "The Iron Eagle", wx = 1405.0, wy = -4605.0, wz = 70.0, instance = 1, dwellSeconds = 60.03, cycleSeconds = 303.463, forever = true },
    { dockId = 5, routeId = 292, name = "Menethil Harbor", zone = "Wetlands", map = 1437, faction = "Alliance", type = "boat", routeName = "The Lady Mehley", wx = -3904.5, wy = -601.0, wz = 6.0, instance = 0, dwellSeconds = 60.028, cycleSeconds = 329.313, forever = true },
    { dockId = 6, routeId = 292, name = "Theramore Isle", zone = "Dustwallow Marsh", map = 1445, faction = "Alliance", type = "boat", routeName = "The Lady Mehley", wx = -4008.0, wy = -4732.3, wz = 6.0, instance = 1, dwellSeconds = 60.028, cycleSeconds = 329.313, forever = true },
    { dockId = 7, routeId = 293, name = "Rut'theran Village", zone = "Teldrassil", map = 1438, faction = "Alliance", type = "boat", routeName = "The Moonspray", wx = 8553.2, wy = 1022.9, wz = 6.0, instance = 1, dwellSeconds = 60.041, cycleSeconds = 316.251, forever = true },
    { dockId = 8, routeId = 293, name = "Auberdine", zone = "Darkshore", map = 1439, faction = "Alliance", type = "boat", routeName = "The Moonspray", wx = 6579.1, wy = 760.2, wz = 6.0, instance = 1, dwellSeconds = 60.042, cycleSeconds = 316.251, forever = true },
    { dockId = 9, routeId = 11167, name = "Menethil Harbor", zone = "Wetlands", map = 1437, faction = "Alliance", type = "boat", routeName = "The Bravery", wx = -3721.4, wy = -585.1, wz = 4.0, instance = 0, dwellSeconds = 60.027, cycleSeconds = 486.183, forever = true },
    { dockId = 10, routeId = 11167, name = "Auberdine", zone = "Darkshore", map = 1439, faction = "Alliance", type = "boat", routeName = "The Bravery", wx = 6419.9, wy = 815.9, wz = 6.0, instance = 1, dwellSeconds = 60.027, cycleSeconds = 486.183, forever = true },
    { dockId = 11, routeId = 301, name = "Grom'gol Base Camp", zone = "Stranglethorn Vale", map = 1434, faction = "Horde", type = "zeppelin", routeName = "The Purple Princess", wx = -12406.9, wy = 211.8, wz = 49.7, instance = 0, dwellSeconds = 60.03, cycleSeconds = 333.044, forever = true },
    { dockId = 12, routeId = 301, name = "Undercity", zone = "Tirisfal Glades", map = 1420, faction = "Horde", type = "zeppelin", routeName = "The Purple Princess", wx = 2062.6, wy = 235.3, wz = 117.7, instance = 0, dwellSeconds = 60.03, cycleSeconds = 333.044, forever = true },
    { dockId = 13, routeId = 302, name = "Orgrimmar", zone = "Durotar", map = 1411, faction = "Horde", type = "zeppelin", routeName = "The Thundercaller", wx = 1318.1, wy = -4658.0, wz = 71.9, instance = 1, dwellSeconds = 60.018, cycleSeconds = 356.284, forever = true },
    { dockId = 14, routeId = 302, name = "Undercity", zone = "Tirisfal Glades", map = 1420, faction = "Horde", type = "zeppelin", routeName = "The Thundercaller", wx = 2062.4, wy = 293.0, wz = 115.0, instance = 0, dwellSeconds = 60.019, cycleSeconds = 356.284, forever = true },
    { dockId = 15, routeId = 303, name = "The Forgotten Coast", zone = "Feralas", map = 1444, faction = "Alliance", type = "boat", routeName = "Feathermoon Ferry", wx = -4214.9, wy = 3283.6, wz = 6.0, instance = 1, dwellSeconds = 60.024, cycleSeconds = 317.038, forever = true },
    { dockId = 16, routeId = 303, name = "Feathermoon Stronghold", zone = "Feralas", map = 1444, faction = "Alliance", type = "boat", routeName = "Feathermoon Ferry", wx = -4350.2, wy = 2423.9, wz = 6.0, instance = 1, dwellSeconds = 60.023, cycleSeconds = 317.038, forever = true },
    { dockId = 17, routeId = 11167, name = "Southshore", zone = "Hillsbrad Foothills", map = 1424, faction = "Alliance", type = "boat", routeName = "The Bravery", wx = -1086.6, wy = -553.2, wz = 6.0, instance = 0, dwellSeconds = 60.027, cycleSeconds = 486.183, forever = true },
    { dockId = 18, routeId = 11391, name = "Steamwheedle Port", zone = "Tanaris", map = 1446, faction = "Both", type = "boat", routeName = "Steamwheedle Port to Powderfuse Port", wx = -6929.4, wy = -4931.3, wz = 6.0, instance = 1, dwellSeconds = 60.027, cycleSeconds = 271.107, forever = true },
    { dockId = 19, routeId = 11391, name = "Powderfuse Port", zone = "Riverglades", map = 2548, faction = "Both", type = "boat", routeName = "Steamwheedle Port to Powderfuse Port", wx = -8226.9, wy = -5783.1, wz = 6.0, instance = 0, dwellSeconds = 60.027, cycleSeconds = 271.107, forever = true },
    { dockId = 20, routeId = 11398, name = "Dalaran", zone = "Alterac Mountains", map = 1416, faction = "Alliance", type = "skycutter", routeName = "Valanaar to Dalaran", wx = 537.3, wy = 417.9, wz = 111.0, instance = 0, dwellSeconds = 60.027, cycleSeconds = 358.693, forever = true },
    { dockId = 21, routeId = 11398, name = "Valanaar Skydocks", zone = "Zephras Isle", map = 2521, faction = "Alliance", type = "skycutter", routeName = "Valanaar to Dalaran", wx = 1858.7, wy = 569.2, wz = 644.0, instance = 2991, dwellSeconds = 60.027, cycleSeconds = 358.693, forever = true },
    { dockId = 22, routeId = 11457, name = "Skywatcher Plateau", zone = "Mulgore", map = 1412, faction = "Horde", type = "zeppelin", routeName = "Valanaar to Skywatcher Plateau", wx = -792.0, wy = 370.1, wz = 190.0, instance = 1, dwellSeconds = 60.027, cycleSeconds = 320.436, forever = true },
    { dockId = 23, routeId = 11457, name = "Valanaar Skydocks", zone = "Zephras Isle", map = 2521, faction = "Horde", type = "zeppelin", routeName = "Valanaar to Skywatcher Plateau", wx = 1962.2, wy = 1014.9, wz = 664.0, instance = 2991, dwellSeconds = 30.014, cycleSeconds = 320.436, forever = true },
    { dockId = 24, routeId = 11616, name = "Auberdine", zone = "Darkshore", map = 1439, faction = "Alliance", type = "boat", routeName = "Stormwind Harbor to Auberdine", wx = 6547.3, wy = 927.4, wz = 6.0, instance = 1, dwellSeconds = 60.027, cycleSeconds = 247.096, forever = true },
    { dockId = 25, routeId = 11616, name = "Stormwind Harbor", zone = "Stormwind City", map = 1453, faction = "Alliance", type = "boat", routeName = "Stormwind Harbor to Auberdine", wx = -8640.8, wy = 1333.3, wz = 6.0, instance = 0, dwellSeconds = 60.027, cycleSeconds = 247.096, forever = true },
}

ns.NavTransportLegs = {
    { from = 1, to = 2, seconds = 106.854, routeId = 241, faction = "Both", type = "boat", routeName = "The Maiden's Fancy" },
    { from = 2, to = 1, seconds = 123.911, routeId = 241, faction = "Both", type = "boat", routeName = "The Maiden's Fancy" },
    { from = 3, to = 4, seconds = 104.956, routeId = 285, faction = "Horde", type = "zeppelin", routeName = "The Iron Eagle" },
    { from = 4, to = 3, seconds = 78.447, routeId = 285, faction = "Horde", type = "zeppelin", routeName = "The Iron Eagle" },
    { from = 5, to = 6, seconds = 103.642, routeId = 292, faction = "Alliance", type = "boat", routeName = "The Lady Mehley" },
    { from = 6, to = 5, seconds = 105.615, routeId = 292, faction = "Alliance", type = "boat", routeName = "The Lady Mehley" },
    { from = 7, to = 8, seconds = 104.288, routeId = 293, faction = "Alliance", type = "boat", routeName = "The Moonspray" },
    { from = 8, to = 7, seconds = 91.88, routeId = 293, faction = "Alliance", type = "boat", routeName = "The Moonspray" },
    { from = 11, to = 12, seconds = 117.037, routeId = 301, faction = "Horde", type = "zeppelin", routeName = "The Purple Princess" },
    { from = 12, to = 11, seconds = 95.947, routeId = 301, faction = "Horde", type = "zeppelin", routeName = "The Purple Princess" },
    { from = 13, to = 14, seconds = 130.913, routeId = 302, faction = "Horde", type = "zeppelin", routeName = "The Thundercaller" },
    { from = 14, to = 13, seconds = 105.334, routeId = 302, faction = "Horde", type = "zeppelin", routeName = "The Thundercaller" },
    { from = 15, to = 16, seconds = 60.115, routeId = 303, faction = "Alliance", type = "boat", routeName = "Feathermoon Ferry" },
    { from = 16, to = 15, seconds = 136.876, routeId = 303, faction = "Alliance", type = "boat", routeName = "Feathermoon Ferry" },
    { from = 9, to = 17, seconds = 142.052, routeId = 11167, faction = "Alliance", type = "boat", routeName = "The Bravery" },
    { from = 10, to = 9, seconds = 79.47, routeId = 11167, faction = "Alliance", type = "boat", routeName = "The Bravery" },
    { from = 17, to = 10, seconds = 84.58, routeId = 11167, faction = "Alliance", type = "boat", routeName = "The Bravery" },
    { from = 18, to = 19, seconds = 76.483, routeId = 11391, faction = "Both", type = "boat", routeName = "Steamwheedle Port to Powderfuse Port" },
    { from = 19, to = 18, seconds = 74.57, routeId = 11391, faction = "Both", type = "boat", routeName = "Steamwheedle Port to Powderfuse Port" },
    { from = 20, to = 21, seconds = 107.517, routeId = 11398, faction = "Alliance", type = "skycutter", routeName = "Valanaar to Dalaran" },
    { from = 21, to = 20, seconds = 131.122, routeId = 11398, faction = "Alliance", type = "skycutter", routeName = "Valanaar to Dalaran" },
    { from = 22, to = 23, seconds = 83.765, routeId = 11457, faction = "Horde", type = "zeppelin", routeName = "Valanaar to Skywatcher Plateau" },
    { from = 23, to = 22, seconds = 146.63, routeId = 11457, faction = "Horde", type = "zeppelin", routeName = "Valanaar to Skywatcher Plateau" },
    { from = 24, to = 25, seconds = 67.258, routeId = 11616, faction = "Alliance", type = "boat", routeName = "Stormwind Harbor to Auberdine" },
    { from = 25, to = 24, seconds = 59.784, routeId = 11616, faction = "Alliance", type = "boat", routeName = "Stormwind Harbor to Auberdine" },
}

