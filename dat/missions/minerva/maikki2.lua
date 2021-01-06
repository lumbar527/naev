--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="Maikki's Father 2">
  <flags>
   <unique />
  </flags>
  <avail>
   <priority>4</priority>
   <chance>100</chance>
   <location>Bar</location>
   <planet>Minerva Station</planet>
   <done>Maikki's Father 1</done>
  </avail>
 </mission>
--]]

--[[
-- Maikki (Maisie McPherson) asks you to find her father, the famous pilot Kex
-- McPherson. She heard rumours he was still alive and at Minerva station.
-- Player found out that Za'lek doing stuff with the ship cargo.
--
-- 1. Told to try to find who could have been involved and given three places to look at.
-- Hint 1: Jorlas in Regas (University)
-- Hint 2: Cantina Station in Qulam (Trade Hub)
-- Hint 3: Jurai in Hideyoshi's Star (University)
-- 2. After talking to all three, the player is told to go to Naga in Damien (Underwater University)
-- 3. Mentions eccentric colleague at Westhaven
-- 4. Eccentric colleague makes the player mine some stupid stuff for him.
-- 5. Tells you he saved him and sent him off to "Minerva Station".
-- 6. Go back and report to Maikki confirming her info.
--
-- Eccentric Scientist in "Westhaven" (slightly senile with dementia).
--]]
local minerva = require "minerva"
local portrait = require 'portrait'
local vn = require 'vn'
require 'numstring'

maikki_name = minerva.maikki.name
maikki_description = minerva.maikki.description
maikki_portrait = minerva.maikki.portrait
maikki_image = minerva.maikki.image
maikki_colour = minerva.maikki.colour

hint1_name = _("Prof. Foo")
hint1_description = _("Foo")
hint1_portrait = "zalek1"
hint1_image = "zalek1.png"
hint1_colour = nil

hint2_name = _("Prof. Foo")
hint2_description = _("Foo")
hint2_portrait = "zalek1"
hint2_image = "zalek1.png"
hint2_colour = nil

hint3_name = _("Dr. Foo")
hint3_description = _("Foo")
hint3_portrait = "zalek1"
hint3_image = "zalek1.png"
hint3_colour = nil

hint4_name = _("Prof. Foo")
hint4_description = _("Foo")
hint4_portrait = "zalek1"
hint4_image = "zalek1.png"
hint4_colour = nil

ecc_name = _("Prof. Strangelove")
ecc_description = nil -- unneeded
ecc_portrait = "zalek1"
ecc_image = "zalek1.png"
ecc_colour = nil

misn_title = _("Finding Father")
misn_reward = _("???")
misn_desc = _("Maikki wants you to help her find her father.")

hintpnt = {
   "Jorlan",
   "Cantina Station",
   "Jurai",
   "Naga",
}
hintsys = {}
for k,v in ipairs(hintpnt) do
   hintsys[k] = planet.get(v):system():nameRaw()
end
eccpnt = "Strangelove Lab"
eccdiff = "strangelove"
eccsys = "Westhaven"

-- Mission states:
--  nil: mission not yet accepted
--    0: Going to the three hints
--    1: Go to fourth hint
--    2: Go to westhaven
--    3: Found base
--    4: Mining stuff
--    5: Going back to Minerva Station
misn_state = nil


function create ()
   if not misn.claim( system.get(eccsys) ) then
      misn.finish( false )
   end
   misn.setNPC( maikki_name, maikki_portrait )
   misn.setDesc( maikki_description )
   misn.setReward( misn_reward )
   misn.setTitle( misn_title )
end


function accept ()
   approach_maikki()

   -- If not accepted, misn_state will still be nil
   if misn_state==nil then
      misn.finish(false)
      return
   end

   -- Set up mission stuff
   markerhint1 = misn.markerAdd( system.get(hintsys[1]), "low")
   markerhint2 = misn.markerAdd( system.get(hintsys[2]), "low")
   markerhint3 = misn.markerAdd( system.get(hintsys[3]), "low")
   hintosd()
   hook.land( "land" )
   hook.enter( "enter" )

   -- Re-add Maikki if accepted
   land()
end


function hintosd ()
   local osd = {
      _("Investigate the Za'lek"),
   }
   local function addhint( id )
      table.insert( osd, string.format(_("\tGo to %s in %s"), _(hintpnt[id]), _(hintsys[id])) )
   end

   if misn_state==0 then
      if not visitedhint1 then
         addhint(1)
      end
      if not visitedhint2 then
         addhint(2)
      end
      if not visitedhint3 then
         addhint(3)
      end
   elseif misn_state==1 then
      addhint(4)
   end

   misn.osdCreate( misn_title, osd )
end


function approach_maikki ()
   vn.clear()
   vn.scene()
   local maikki = vn.newCharacter( minerva.vn_maikki() )
   vn.fadein()

   if misn_state==nil then
      maikki(_([["blah"]]))
      vn.menu( {
         { _("Help Maikki again"), "accept" },
         { _("Decline to help"), "decline" },
      } )
      vn.label( "decline" )
      vn.na(_("You feel it is best to leave her alone for now and disappear into the crowds leaving her once again alone to her worries."))
      vn.done()

      vn.label( "accept" )
      vn.func( function ()
         misn_accept()
         misn_state = 0
      end )
      -- give an option to improve her mood
   end

   vn.fadeout()
   vn.run()
end


function land ()
   if planet.cur() == planet.get("Minerva Station") then
      npc_maikki = misn.npcAdd( "approach_maikki", minerva.maikki.name, minerva.maikki.portrait, minerva.maikki.description )

   elseif planet.cur() == planet.get( hintpnt[1] ) then
      npc_hint1 = misn.npcAdd( "approach_hint1", hint1_name, hint1_portrait, hint1_description )

   elseif planet.cur() == planet.get( hintpnt[2] ) then
      npc_hint2 = misn.npcAdd( "approach_hint2", hint2_name, hint2_portrait, hint2_description )

   elseif planet.cur() == planet.get( hintpnt[3] ) then
      npc_hint3 = misn.npcAdd( "approach_hint3", hint3_name, hint3_portrait, hint3_description )

   elseif misn_state >= 1 and  planet.cur() == planet.get( hintpnt[3] ) then
      npc_hint4 = misn.npcAdd( "approach_hint4", hint4_name, hint4_portrait, hint4_description )

   elseif diff.isApplied(eccdiff) and planet.cur() == planet.get(eccpnt) then
      npc_ecc = misn.npcAdd( "approach_eccentric", ecc_name, ecc_portrait, ecc_description )

   end
end


function visited ()
   if misn_state==0 and visitedhint1 and visitedhint2 and visitedhint3 then
      misn_state = 1
      markerhint4 = misn.markerAdd( system.get(hintsys[4]) )
   end
   hintosd()
end


function approach_hint1 ()
   vn.clear()
   vn.scene()
   local prof = vn.newCharacter( hint1_name, { image=hint1_image, color=hint1_colour } )
   vn.fadein()

   prof([["Blah"]])

   vn.fadeout()
   vn.run()

   if not visitedhint1 then
      visitedhint1 = true
      misn.markerRm( markerhint1 )
      visited()
   end
end


function approach_hint2 ()
   vn.clear()
   vn.scene()
   local prof = vn.newCharacter( hint2_name, { image=hint2_image, color=hint2_colour } )
   vn.fadein()

   prof([["Blah"]])

   vn.fadeout()
   vn.run()

   if not visitedhint2 then
      visitedhint2 = true
      misn.markerRm( markerhint2 )
      visited()
   end
end


function approach_hint3 ()
   vn.clear()
   vn.scene()
   local prof = vn.newCharacter( hint3_name, { image=hint3_image, color=hint3_colour } )
   vn.fadein()

   prof([["Blah"]])

   vn.fadeout()
   vn.run()

   if not visitedhint3 then
      visitedhint3 = true
      misn.markerRm( markerhint3 )
      visited()
   end
end


function approach_hint4 ()
   vn.clear()
   vn.scene()
   local prof = vn.newCharacter( hint4_name, { image=hint4_image, color=hint4_colour } )
   vn.fadein()

   prof([["Blah"]])

   vn.fadeout()
   vn.run()

   if misn_state==1 then
      misn_state = 2
      misn.markerRm( markerhint4 )
      misn.markerAdd( system.get(eccsys), "low" )
      misn.osdCreate( misn_title, {string.format(_("\tGo to %s"), _(eccsys))} )
   end
end


function approach_eccentric ()
end


function enter ()
   if system.cur() == system.get(eccsys) then
      -- TODO security protocol
      diff.apply( eccdiff )
   end
end

