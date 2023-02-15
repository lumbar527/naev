local flow = require "ships.lua.lib.flow"

function init( p )
   flow.recalculate( p )
end

function onadd( p )
   flow.recalculate( p )
end

function onremove( p )
   flow.recalculate( p )
end

function update( p, _po, dt )
   flow.update( p, dt )
end

function onhit( p, _po, armour, shield )
   flow.onhit( p, armour, shield )
end
