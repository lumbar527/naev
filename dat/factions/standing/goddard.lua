-- Goddard faction standing script
local sbase = require "factions.standing.lib.base"

standing = sbase.newStanding{
   fct            = faction.get("Goddard"),
   cap_kill       = 5,
   delta_distress = {-1, 0},    -- Maximum change constraints
   delta_kill     = {-5, 1},    -- Maximum change constraints
   cap_misn_def  = 30,
   cap_misn_var   = "_fcap_goddard",
}
