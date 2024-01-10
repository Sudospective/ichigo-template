-- automaton-lua v4.0.0
-- Lua binding of automaton

-- (c) 2020 FMS_Cat
-- automaton-lua is distributed under MIT License
-- https://github.com/FMS-Cat/automaton-lua/blob/master/LICENSE

-- Adapted for Ichigo Template by Sudospective

local ichi = ...


local NEWTON_ITER = 4
local NEWTON_EPSILON = 0.001
local SUBDIV_ITER = 10
local SUBDIV_EPSILON = 0.000001
local TABLE_SIZE = 21

local __cache = {}

local clamp = function( t, min, max )
  return math.min( math.max( t, min ), max )
end

local A = function( cps )
  return cps.p3 - 3.0 * cps.p2 + 3.0 * cps.p1 - cps.p0
end

local B = function( cps )
  return 3.0 * cps.p2 - 6.0 * cps.p1 + 3.0 * cps.p0
end

local C = function( cps )
  return 3.0 * cps.p1 - 3.0 * cps.p0
end

local cubicBezier = function( t, cps )
  return ( ( A( cps ) * t + B( cps ) ) * t + C( cps ) ) * t + cps.p0
end

local deltaCubicBezier = function( t, cps )
  return ( 3.0 * A( cps ) * t + 2.0 * B( cps ) ) * t + C( cps )
end

local subdiv = function( x, a, b, cps )
  local candidateX = 0
  local t = 0

  for i = 1, SUBDIV_ITER do
    t = a + ( b - a ) / 2.0
    candidateX = cubicBezier( t, cps ) - x
    if 0.0 < candidateX then b = t else a = t end
    if SUBDIV_EPSILON < math.abs( candidateX ) then break end
  end

  return t
end

local newton = function( x, t, cps )
  for i = 1, NEWTON_ITER do
    local d = deltaCubicBezier( t, cps )
    if d == 0.0 then return t end
    local cx = cubicBezier( t, cps ) - x
    t = t - cx / d
  end
  return t
end

local rawBezierEasing = function( cpsx, cpsy, x )
  if x <= cpsx.p0 then return cpsy.p0 end -- clamped
  if x >= cpsx.p3 then return cpsy.p3 end -- clamped

  cpsx.p1 = clamp( cpsx.p1, cpsx.p0, cpsx.p3 )
  cpsx.p2 = clamp( cpsx.p2, cpsx.p0, cpsx.p3 )

  for i = 1, TABLE_SIZE do
    __cache[ i ] = cubicBezier( ( i - 1 ) / ( TABLE_SIZE - 1 ), cpsx )
  end

  local sample = 1
  for i = 2, TABLE_SIZE do
    sample = i - 1
    if x < __cache[ i ] then break end
  end

  local dist = ( x - __cache[ sample ] ) / ( __cache[ sample + 1 ] - __cache[ sample ] )
  local t = ( sample + dist ) / ( TABLE_SIZE - 1 )
  local d = deltaCubicBezier( t, cpsx ) / ( cpsx.p3 - cpsx.p0 )

  if NEWTON_EPSILON <= d then
    t = newton( x, t, cpsx )
  elseif d ~= 0.0 then
    t = subdiv( x, ( sample ) / ( TABLE_SIZE - 1 ), ( sample + 1.0 ) / ( TABLE_SIZE - 1 ), cpsx )
  end

  return cubicBezier( t, cpsy )
end

local automatonBezierEasing = function( node0, node1, time )
  return rawBezierEasing(
    {
      p0 = node0.time,
      p1 = node0.time + node0.outTime,
      p2 = node1.time + node1.inTime,
      p3 = node1.time
    },
    {
      p0 = node0.value,
      p1 = node0.value + node0.outValue,
      p2 = node1.value + node1.inValue,
      p3 = node1.value
    },
    time
  )
end

local AutomatonCurve = {}

AutomatonCurve.new = function( automaton, data )
  local curve = {}

  curve.__automaton = automaton
  curve.__values = {}
  curve.__nodes = {}
  curve.__fxs = {}

  setmetatable( curve, { __index = AutomatonCurve } )

  curve:deserialize( data )

  return curve
end

AutomatonCurve.getLength = function( self )
  return self.__nodes[ table.getn( self.__nodes ) ].time
end

AutomatonCurve.deserialize = function( self, data )
  self.__nodes = {}
  for _, node in ipairs( data.nodes ) do
    table.insert( self.__nodes, {
      time = node[ 1 ] or 0.0,
      value = node[ 2 ] or 0.0,
      inTime = node[ 3 ] or 0.0,
      inValue = node[ 4 ] or 0.0,
      outTime = node[ 5 ] or 0.0,
      outValue = node[ 6 ] or 0.0
    } )
  end

  self.__fxs = {}
  if data.fxs then
    for _, fx in ipairs( data.fxs ) do
      if not fx.bypass then
        table.insert( self.__fxs, {
          time = fx.time or 0.0,
          length = fx.length or 0.0,
          row = fx.row or 0,
          def = fx.def,
          params = fx.params
        } )
      end
    end
  end

  self:precalc()
end

AutomatonCurve.precalc = function( self )
  self:__generateCurve()
  self:__applyFxs()
end

AutomatonCurve.getValue = function( self, time )
  if time < 0.0 then
    -- clamp left
    return self.__values[ 1 ]

  elseif self:getLength() <= time then
    -- clamp right
    return self.__values[ table.getn( self.__values ) ]

  else
    -- fetch two values then do the linear interpolation
    local resolution = self.__automaton:getResolution()
    local index = time * resolution
    local indexi = math.floor( index )
    local indexf = index - indexi
    indexi = indexi + 1

    local v0 = self.__values[ indexi ]
    local v1 = self.__values[ indexi + 1 ]

    local v = v0 + ( v1 - v0 ) * indexf

    return v

  end
end

AutomatonCurve.__generateCurve = function( self )
  local resolution = self.__automaton:getResolution()

  local nodeTail = self.__nodes[ 1 ]
  local iTail = 1
  for iNode = 1, ( table.getn( self.__nodes ) - 1 ) do
    local node0 = nodeTail
    nodeTail = self.__nodes[ iNode + 1 ]
    local i0 = iTail
    iTail = 1 + math.floor( nodeTail.time * resolution )

    self.__values[ i0 ] = node0.value
    for i = ( i0 + 1 ), iTail do
      local time = ( i - 1 ) / resolution
      local value = automatonBezierEasing( node0, nodeTail, time )
      self.__values[ i ] = value
    end
  end

  local valuesLength = math.ceil( resolution * nodeTail.time ) + 2
  for i = ( iTail + 1 ), valuesLength do
    self.__values[ i ] = nodeTail.value
  end
end

AutomatonCurve.__applyFxs = function( self )
  local resolution = self.__automaton:getResolution()

  for iFx, fx in ipairs( self.__fxs ) do
    local fxDef = self.__automaton:getFxDefinition( fx.def )
    if fxDef then
      local availableEnd = math.min( self:getLength(), fx.time + fx.length )
      local i0 = 1 + math.ceil( resolution * fx.time )
      local i1 = 1 + math.floor( resolution * availableEnd )
      if i0 < i1 then
        local tempValues = {}
        local tempLength = i1 - i0 + 1

        local context = {
          index = i0,
          i0 = i0,
          i1 = i1,
          time = fx.time,
          t0 = fx.time,
          t1 = fx.time + fx.length,
          deltaTime = 1.0 / resolution,
          value = 0.0,
          progress = 0.0,
          elapsed = 0.0,
          resolution = resolution,
          length = fx.length,
          params = fx.params,
          array = self.__values,
          getValue = function( time ) return self:getValue( time ) end,
          init = true,
          state = {}
        }

        for i = 1, tempLength do
          context.index = ( i - 1 ) + i0
          context.time = context.index / resolution
          context.value = self.__values[ context.index ]
          context.elapsed = context.time - fx.time
          context.progress = context.elapsed / fx.length
          tempValues[ i ] = fxDef.func( context )

          context.init = false
        end

        for i = 1, tempLength do
          self.__values[ ( i - 1 ) + i0 ] = tempValues[ i ]
        end
      end
    end
  end
end

local AutomatonChannelItem = {}

AutomatonChannelItem.new = function( automaton, data )
  local item = {}

  item.__automaton = automaton

  setmetatable( item, { __index = AutomatonChannelItem } )

  item:deserialize( data )

  return item
end

AutomatonChannelItem.deserialize = function( self, data )
  self.time = data.time or 0.0
  self.length = data.length or 0.0
  self.value = data.value or 0.0
  self.offset = data.offset or 0.0
  self.speed = data.speed or 1.0
  self.amp = data.amp or 1.0
  self.reset = data.reset

  if data.curve then
    self.curve = self.__automaton:getCurve( data.curve )
    self.length = data.length or self.curve:getLength() or 1.0
  end
end

AutomatonChannelItem.getValue = function( self, time )
  if self.reset and self.length <= time then
    return 0.0
  end

  if self.curve then
    local t = self.offset + time * self.speed
    return self.value + self.amp * self.curve:getValue( t )
  end

  return self.value
end

local AutomatonChannel = {}

AutomatonChannel.new = function( automaton, data )
  local channel = {}

  channel.__automaton = automaton
  channel.__items = {}
  channel.__value = 0.0
  channel.__time = -1E999 -- -math.huge
  channel.__head = 1
  channel.__listeners = {}

  setmetatable( channel, { __index = AutomatonChannel } )

  channel:deserialize( data );

  return channel
end

AutomatonChannel.getCurrentValue = function( self )
  return self.__value
end

AutomatonChannel.getCurrentTime = function( self )
  return self.__time
end

AutomatonChannel.deserialize = function( self, data )
  self.__items = {}
  for iItem, item in ipairs( data.items or {} ) do
    self.__items[ iItem ] = AutomatonChannelItem.new( self.__automaton, item )
  end
end

AutomatonChannel.reset = function( self )
  self.__time = -1E999 -- -math.huge
  self.__value = 0.0
  self.__head = 1
end

AutomatonChannel.subscribe = function( self, listener )
  table.insert( self.__listeners, listener )
end

AutomatonChannel.getValue = function( self, time )
  local next = table.getn( self.__items )
  for iItem, item in ipairs( self.__items ) do
    if time < item.time then
      next = iItem
      break
    end
  end

  -- it's the first one!
  if next == 1 then
    return 0.0
  end

  local item = self.__items[ next ]
  if item.getEnd() < time then
    return item:getValue( item.length )
  else
    return item:getvalue( time - item.time )
  end
end

AutomatonChannel.update = function( self, time )
  local value = self.__value
  local prevTime = self.__time

  for iItem = self.__head, table.getn( self.__items ) do
    local item = self.__items[ iItem ]
    local begin = item.time
    local length = item.length
    local elapsed = time - begin

    if elapsed < 0.0 then
      break
    else
      local progress = 0.0
      local init = false
      local uninit = false

      if length <= elapsed then
        elapsed = length
        progress = 1.0
        uninit = true

        if iItem == self.__head then
          self.__head = self.__head + 1
        end
      else
        progress = length ~= 0.0
          and ( elapsed / length )
          or 1.0
      end

      if prevTime < begin then
        init = true
      end

      value = item:getValue( elapsed )

      for _, listener in ipairs( self.__listeners ) do
        listener( {
          time = time,
          elapsed = elapsed,
          begin = begin,
          [ 'end' ] = begin + length,
          length = length,
          value = value,
          progress = progress,
          init = init,
          uninit = uninit
        } )
      end
    end
  end

  self.__time = time
  self.__value = value
end

local Automaton = {}

Automaton.new = function( data, options )
  local automaton = {}

  automaton.curves = {}
  automaton.channels = {}
  automaton.mapNameToChannel = {}

  automaton.__time = 0.0
  automaton.__version = '4.0.0'
  automaton.__resolution = 1000
  automaton.__fxDefinitions = {}

  setmetatable( automaton, { __index = Automaton } )

  automaton.auto = function( name, callback ) return automaton:__auto( name, callback ) end

  if options and options.fxDefinitions then
    automaton:addFxDefinitions( options.fxDefinitions )
  end

  automaton:deserialize( data )

  return automaton
end

Automaton.getTime = function( self )
  return self.__time
end

Automaton.getVersion = function( self )
  return self.__version
end

Automaton.getResolution = function( self )
  return self.__resolution
end

Automaton.deserialize = function( self, data )
  self.__length = data.length
  self.__resolution = data.resolution

  self.curves = {}
  for iCurve, data in ipairs( data.curves ) do
    table.insert( self.curves, AutomatonCurve.new( self, data ) )
  end

  self.mapNameToChannel = {}
  self.channels = {}
  for iChannel, tuple in ipairs( data.channels ) do
    local channel = AutomatonChannel.new( self, tuple[ 2 ] )
    table.insert( self.channels, channel )
    self.mapNameToChannel[ tuple[ 1 ] ] = channel
  end
end

Automaton.addFxDefinitions = function( self, fxDefinitions )
  for id, fxDef in pairs( fxDefinitions ) do
    if type( fxDef.func ) == 'function' then
      self.__fxDefinitions[ id ] = fxDef
    end
  end

  self:precalcAll()
end

Automaton.getFxDefinition = function( self, id )
  return self.__fxDefinitions[ id ] or nil
end

Automaton.getCurve = function( self, index )
  return self.curves[ index + 1 ] or nil
end

Automaton.precalcAll = function( self )
  for _, curve in ipairs( self.curves ) do
    curve:precalc()
  end
end

Automaton.reset = function( self )
  for _, channel in ipairs( self.channels ) do
    channel:reset()
  end
end

Automaton.update = function( self, time )
  local t = math.max( time, 0.0 )

  -- cache the time
  self.__time = t

  -- grab the current value for each channels
  for _, channel in ipairs( self.channels ) do
    channel:update( self.__time )
  end
end

Automaton.__auto = function( self, name, listener )
  local channel = self.mapNameToChannel[ name ]
  if not channel then return end

  if listener then
    channel:subscribe( listener )
  end

  return channel:getCurrentValue()
end


ichi.automaton = Automaton.new
