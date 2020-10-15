
--addEvent("playerOpenInventory", true)

local inv = {}
-- inv[USER ID] = { ..... }



function cosmicGetPlayerItem(player, itemID)
	local userID = NameToID(getPlayerName(player))
	
	if userID then
		for a, b in ipairs(inv[userID]) do
			if b.id == itemID then
				return b.amount
			end
		end
		
		return 0
	end
end


function cosmicSetPlayerItem(player, itemID, itemAmount)
	local userID = NameToID(getPlayerName(player))
	
	if userID then
		for a, b in ipairs(inv[userID]) do
			if b.id == itemID then
				b.amount = itemAmount
				triggerClientEvent(player, "clientSyncInventory", player, b, false)
				
				if b.amount == 0 then
					table.remove(inv[userID], a)
				end
				
				return
			end
		end
		
		if itemAmount > 0 then
			local new = {
				id = itemID,
				amount = itemAmount,
			}
			
			table.insert(inv[userID], new)
			triggerClientEvent(player, "clientSyncInventory", player, new, false)
		end
	end
end


function cosmicAddPlayerItem(player, itemID, itemAmount)
	-- RETURNS: True IF SUCCESS; False OTHERWISE
	
	local userID = NameToID(getPlayerName(player))
	
	if userID then
		for a, b in ipairs(inv[userID]) do
			if b.id == itemID then
				if (b.amount + itemAmount) >= 0 then
					b.amount = b.amount + itemAmount
					triggerClientEvent(player, "clientSyncInventory", player, b, false)
					
					if b.amount == 0 then
						table.remove(inv[userID], a)
					end
					
					return true
				else
					return false
				end
			end
		end
		
		if itemAmount > 0 then
			local new = {
				id = itemID,
				amount = itemAmount,
			}
			
			table.insert(inv[userID], new)
			triggerClientEvent(player, "clientSyncInventory", player, new, false)
			
			return true
		end
	end
end


function cosmicLoadPlayerInventory(userID)
	if not inv[userID] then
		local result = dbPoll(dbQuery(dbHandler, "SELECT Items FROM inventory WHERE ID=?", userID), -1)
		
		if result and result[1] then
			-- example: 1-5|4-2|.....
			-- ID-AMOUNT|ID-AMOUNT|.......
			
			local new = {}
			
			for i = 1, 999, 1 do
				local ph = gettok(result[1]["Items"], i, "|")
				
				if ph then
					local item = {
						id = tonumber(gettok(ph, 1, "-")),
						amount = tonumber(gettok(ph, 2, "-")),
					}
					
					table.insert(new, item)
				else
					break
				end
			end
			
			table.insert(inv, new)
			
			local player = getPlayerFromName(IDToName(userID))
			triggerClientEvent(player, "clientSyncInventory", player, new, true)
		end
	else
		local player = getPlayerFromName(IDToName(userID))
		triggerClientEvent(player, "clientSyncInventory", player, inv[userID], true)
	end
end


local function unloadAndSavePlayerInventory()
	local id = NameToID(getPlayerName(source))
	
	if inv[id] then
		local str = ""
		
		for i = 1, #inv[id], 1 do
			str = str .. inv[id][i].id .. "-" .. inv[id][i].amount
			
			if i ~= #inv[id] then
				str = str .. "|"
			end
		end
		
		dbExec(dbHandler, "UPDATE inventory SET Items=? WHERE ID=?", str, id)
		
		
		inv[id] = nil
	end
end
addEventHandler("onPlayerExit", getRootElement(), unloadAndSavePlayerInventory)