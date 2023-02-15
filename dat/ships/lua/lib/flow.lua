local flow = {}

local flow_base = {
   -- Ships
   ["Sirius Divinity"]           = 500,
   ["Sirius Dogma"]              = 500,
   ["Sirius Providence"]         = 300,
   ["Sirius Preacher"]           = 160,
   ["Sirius Shama"]              = 80,
   ["Sirius Fidelity"]           = 50,
   -- Outfits
   ["Small Flow Amplifier"]      = 50,
   ["Medium Flow Amplifier"]     = 100,
   ["Large Flow Amplifier"]      = 200,
   ["Small Meditation Chamber"]  = 50,
   ["Medium Meditation Chamber"] = 100,
   ["Large Meditation Chamber"]  = 200,
}
flow.list_base = flow_base

local flow_regen = {
   -- Ships
   ["Sirius Divinity"]           = 7,
   ["Sirius Dogma"]              = 7,
   ["Sirius Providence"]         = 5,
   ["Sirius Preacher"]           = 3,
   ["Sirius Shama"]              = 2,
   ["Sirius Fidelity"]           = 1.5,
   -- Outfits
   ["Small Flow Resonator"]      = 1,
   ["Medium Flow Resonator"]     = 2,
   ["Large Flow Resonator"]      = 4,
}
flow.list_regen = flow_regen

local flow_mod = {
   -- Ships
   ["Sirius Divinity"]           = 1.3,
   ["Sirius Dogma"]              = 1.3,
   ["Sirius Providence"]         = 1.3,
   ["Sirius Preacher"]           = 1.3,
   ["Sirius Shama"]              = 1.3,
   ["Sirius Fidelity"]           = 1.3,
   -- Outfits
   ["Lesser Ethereal Apparition"] = 1/1.3,
   ["Ethereal Apparition"]       = 1/1.3,
   ["Greater Ethereal Apparition"] = 1/1.3,
}
flow.list_mod = flow_mod

function flow.get( p )
   local sm = p:shipMemory()
   return sm._flow or 0
end

function flow.max( p )
   local sm = p:shipMemory()
   return sm._flow_base or 0
end

function flow.regen( p )
   local sm = p:shipMemory()
   return sm._flow_regen or 0
end

function flow.activate( p )
   local sm = p:shipMemory()
   local fa = (sm._flow_active or 0)
   sm._flow_active = fa+1
end

function flow.deactivate( p )
   local sm = p:shipMemory()
   local fa = (sm._flow_active or 0)
   sm._flow_active = math.max(fa-1)
end

function flow.reset( p )
   local sm = p:shipMemory()
   sm._flow = 0.5*(sm._flow_base or 0)
   sm._flow_active = 0
end

function flow.inc( p, amount )
   local sm = p:shipMemory()
   local fb = sm._flow_base or 0
   local f = sm._flow or 0
   sm._flow = math.min( fb, f+amount )
end

function flow.dec( p, amount )
   local sm = p:shipMemory()
   local f = sm._flow or 0
   sm._flow = math.max( 0, f-amount )
end

function flow.update( p, dt )
   local sm = p:shipMemory()
   local fb = sm._flow_base or 0
   local f = sm._flow or 0
   local cap = 0.5
   if sm._flow < cap*fb then
      local fa = sm._flow_active or 0
      if fa <= 0 then
         -- Regen when under cap and no active on
         local fr = sm._flow_regen or 0
         sm._flow = math.min( cap*fb, f + dt*fr )
      end
   else
      -- Lose 2% a second when over cap
      sm._flow = math.max( cap*fb, f - dt*0.02*fb )
   end
end

function flow.onhit( p, armour, shield )
   local dmg = armour+shield
   flow.inc( p, dmg*0.1 )
end

function flow.recalculate( p )
   local sm = p:shipMemory()
   local has_amplifier = false

   local fm = flow_mod[ p:ship():nameRaw() ] or 1
   local fb = flow_base[ p:ship():nameRaw() ] or 0
   local fr = flow_regen[ p:ship():nameRaw() ] or 0
   for k,v in ipairs(p:outfitsList()) do
      fm = fm * (flow_mod[ v:nameRaw() ] or 1)
      fb = fb + (flow_base[ v:nameRaw() ] or 0)
      fr = fr + (flow_regen[ v:nameRaw() ] or 0)
      if v:tags().flow_amplifier then
         has_amplifier = true
      end
   end
   if has_amplifier then
      sm._flow_mod = fm
      sm._flow_base = fb * fm
      sm._flow_regen = fr
   end

   -- Reset just in case
   flow.reset( p )
end

return flow
