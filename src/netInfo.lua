#!/usr/bin/env lua
--[[
Training in LUA programming -- Networking
Very incomplete program that gives some informations about a given subnet mask
To do :
 - Support complex mask
 - Work with argv -- ./netInfo -m 255.255.255.0 would be cool
 - Process "semi-decimal" masks e.g. 255.255.255.11110000
 - GUI support ? maybe ./netInfo --graphical
anyway this belongs to /dev/null
]]

function toBinary(nb)
  local value = {}
  local reversedValue = {}
  local i = 1
  local result = "0"

  while nb > 0 do
    value[i] = nb%2
    nb = math.floor(nb/2)
    i = i + 1
  end
  for i,v in ipairs(value) do
    reversedValue[#value-(i-1)] = v
  end
  for i,v in ipairs(reversedValue) do
    result = result .. reversedValue[i]
  end
  return tonumber(result)
end

function toDecimal(nb)
  local dec = 0
  for i=1, #tostring(nb) do
    dec = dec + tonumber(tostring(nb):sub(#tostring(nb)-(i-1),#tostring(nb)-(i-1))) * 2^(i-1)
  end
  return dec
end

local netmaskTable = {}
local netmaskParsed = {}

print("enter a subnet mask :")
local netmask = io.read()

for i=1, #netmask do
  netmaskTable[i] = netmask:sub(i,i)
end

do -- #1 scope layer - filling the table with numeric values
  local parser = nil
  for i=1, #netmask do
    parser = parser or 1
    if netmask:sub(i,i) ~= "." then
      if netmaskParsed[parser] == nil then
        netmaskParsed[parser] = netmask:sub(i,i)
      else
        netmaskParsed[parser] = netmaskParsed[parser] .. netmask:sub(i,i)
      end
      netmaskParsed[parser] = tonumber(netmaskParsed[parser])
    else parser = parser + 1
    end
  end
end

do
  local fullBinaryMask
  local cidr = 0
  for i in ipairs(netmaskParsed) do
    if fullBinaryMask == nil then
      fullBinaryMask = toBinary(netmaskParsed[i])
    else
      fullBinaryMask = fullBinaryMask .. toBinary(netmaskParsed[i])
    end
  end
  for i in string.gfind(fullBinaryMask, "1") do
    cidr = cidr + 1
  end
  print("CIDR notation : /" .. cidr)
  print("Max IP in the network : " .. 2^(32-cidr)-2)
  local printed = false

  if cidr >= 24 and not(printed) then print("Class C"); printed = true
  elseif cidr >= 16 and not(printed) then print("Class B"); printed = true
  elseif cidr >= 8 and not(printed) then print("Class A"); printed = true
  else print("Something went wrong")
  end
end
