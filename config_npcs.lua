ConfigNPC = {}

ConfigNPC.SafeZonesNpc = {
    {
        coords = vector3(431.13, -978.57, 30.71),
        radius = 50.0,
        blipradius = 1.5,
        showblip = true,
        blipsprite = 120,
        blipscale = 0.9,
        blipcolor = 2,
        blipname = "Military Safe Zone comisaria",
        npcs = {
            model = "s_m_y_hwaycop_01",
            weapons = {"WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_COMBATMG"},
            invincible = true,
            freeze = true,
            respawn = 20000, -- 1 * 60000 = 1 minute
            positions = {
                vector4(431.13, -978.57, 29.71, 90.26),
                vector4(430.88, -985.67, 29.71, 90.69),
                vec4(433.97021, -972.541, 29.71, 99.25)
            }
        }
    },
    { -- Hospital zona 2
        coords = vector3(298.35, -584.74, 43.26),
        radius = 50.0,
        blipradius = 1.5,
        showblip = true,
        blipsprite = 120,
        blipscale = 0.9,
        blipcolor = 2,
        blipname = "Military Safe Zone Hospital",
        npcs = {
            model = "s_m_y_cop_01",
            weapons = {"WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_COMBATMG"},
            invincible = true,
            freeze = true,
            respawn = 20000, -- 1 * 60000 = 1 minute
            positions = {
                vector4(297.24, -586.6, 42.26, 73.11), --npc 1 hospital
                vector4(298.75, -581.22, 42.26, 81.63), --npc 1 hospital
            }
        }
    }
}