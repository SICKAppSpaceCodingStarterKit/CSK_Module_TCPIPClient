---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_TCPIPClient'

local tcpIpClient_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
tcpIpClient_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
tcpIpClient_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
tcpIpClient_Model.parametersName = 'CSK_TCPIPClient_Parameter' -- name of parameter dataset to be used for this module
tcpIpClient_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the tcpIpClient_Model interface and give access
-- to the TCPIPClient_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setTCPIPClient_Model_Handle = require('Communication/TCPIPClient/TCPIPClient_Controller')
setTCPIPClient_Model_Handle(tcpIpClient_Model)

--Loading helper functions
tcpIpClient_Model.helperFuncs = require('Communication/TCPIPClient/helper/funcs')

-- Create parameters / instances for this module
tcpIpClient_Model.tcpIpClient = TCPIPClient.create() -- TCP/IP Client handle
tcpIpClient_Model.currentConnectionStatus = false -- Status of TCP/IP connection to TCP/IP server
tcpIpClient_Model.command = '' -- Temp command to preset to transmit
tcpIpClient_Model.log = {} -- Log of TCP/IP communication
tcpIpClient_Model.availableInterfaces = Engine.getEnumValues("EthernetInterfaces") -- Available ethernet interfaces on device
tcpIpClient_Model.interfaceList = tcpIpClient_Model.helperFuncs.createStringList(tcpIpClient_Model.availableInterfaces) -- List of ethernet interfaces

-- Parameters to be saved permanently
tcpIpClient_Model.parameters = {}
tcpIpClient_Model.parameters.connectionStatus = false -- Configure module to try to connect to server

-- List of incoming trigger commands to forward as events
-- e.g. "commandList['TRG'] = 'OnNewTrigger' will trigger the event "CSK_TCPIPClient.OnNewTrigger" if receiving 'TRG' via TCPIP connection
tcpIpClient_Model.parameters.commandList = {}

if tcpIpClient_Model.availableInterfaces then
  tcpIpClient_Model.parameters.interface = tcpIpClient_Model.availableInterfaces[1] -- e.g. 'ETH1' -- Select first available ethernet interface per default
else
  tcpIpClient_Model.parameters.interface = nil
end
tcpIpClient_Model.parameters.serverIP = '192.168.0.202' -- IP of TCP/IP server
tcpIpClient_Model.parameters.port = 1234 -- Port of TCP/IP connection
tcpIpClient_Model.parameters.rxFrame = 'STX-ETX' -- OR 'empty' -- RX Frame
tcpIpClient_Model.parameters.txFrame = 'STX-ETX' -- OR 'empty' -- TX Frame

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to notify latest TCP/IP log messages, e.g. to show on UI
local function sendLog()
  local tempLog = ''
  for i=1, #tcpIpClient_Model.log do
    tempLog = tempLog .. tcpIpClient_Model.log[i] .. '\n'
  end
  Script.notifyEvent('TCPIPClient_OnNewLog', tempLog)
end
tcpIpClient_Model.sendLog = sendLog

--- Function to react on disconnection from TCP/IP server
local function handleOnDisconnected()
  _G.logger:info(nameOfModule .. ": Connection disconnected")
  tcpIpClient_Model.currentConnectionStatus = false
  Script.notifyEvent("TCPIPClient_OnNewCurrentConnectionStatus", false)
end

--- Function to react on connection from device to TCP/IP server
local function handleOnConnected()
  _G.logger:info(nameOfModule .. ": Connected")
  tcpIpClient_Model.currentConnectionStatus = true
  Script.notifyEvent("TCPIPClient_OnNewCurrentConnectionStatus", true)
end

local function sendDataViaTCPIP(data)
  _G.logger:info(nameOfModule .. ": Try to send data...")
  if tcpIpClient_Model.currentConnectionStatus ~= nil then
    local success = tcpIpClient_Model.tcpIpClient:transmit(data)

    table.insert(tcpIpClient_Model.log, 1, DateTime.getTime() .. ' - SENT = ' .. data)
    if #tcpIpClient_Model.log == 100 then
      table.remove(tcpIpClient_Model.log, 100)
    end
    sendLog()

    if success == 0 then
      _G.logger:info(nameOfModule .. ": TCP Data Out failed")
    else
      _G.logger:info(nameOfModule .. ": Send: " .. data)
    end
  else
    _G.logger:info(nameOfModule .. ": No TCP connection.")
  end
end
Script.serveFunction("CSK_TCPIPClient.sendDataViaTCPIP", sendDataViaTCPIP)
tcpIpClient_Model.sendDataViaTCPIP = sendDataViaTCPIP

-- Function to receive data via TCP/IP connection and check if incoming command should trigger an event
---@param data string Incoming binary data
local function receiveData(data)

  _G.logger:info(nameOfModule .. ": Received data.")

  -- Forward data to other modules
  Script.notifyEvent('TCPIPClient_OnNewDataReceived', data)

  -- Check if cmd includes parameters seperated by a ','
  local _, pos = string.find(data, ',')

  if pos then
    -- Check for command with parameter attached
    local cmd = string.sub(data, 1, pos-1)
    if tcpIpClient_Model.parameters.commandList[cmd] then
      Script.notifyEvent("TCPIPClient_" .. tcpIpClient_Model.parameters.commandList[cmd], string.sub(data, pos + 1))
    end

  else
    -- Check for command without parameter
    if tcpIpClient_Model.parameters.commandList[data] then
      Script.notifyEvent("TCPIPClient_" .. tcpIpClient_Model.parameters.commandList[data])
    end
  end

  _G.logger:info(nameOfModule .. ": Data = " .. data)
  table.insert(tcpIpClient_Model.log, 1, DateTime.getTime() .. ' - RECV = ' .. data)
  if #tcpIpClient_Model.log == 100 then
    table.remove(tcpIpClient_Model.log, 100)
  end
  sendLog()
end

local function startTCPIPClient()
  _G.logger:info(nameOfModule .. ": Try to connect")
  tcpIpClient_Model.tcpIpClient:setIPAddress(tcpIpClient_Model.parameters.serverIP)
  tcpIpClient_Model.tcpIpClient:setPort(tcpIpClient_Model.parameters.port)
  if tcpIpClient_Model.parameters.rxFrame == 'STX-ETX' then
    if tcpIpClient_Model.parameters.txFrame == 'STX-ETX' then
      tcpIpClient_Model.tcpIpClient:setFraming('\02','\03','\02','\03')
    else
      tcpIpClient_Model.tcpIpClient:setFraming('\02','\03','','')
    end
  elseif tcpIpClient_Model.parameters.txFrame == 'STX-ETX' then
      tcpIpClient_Model.tcpIpClient:setFraming('','','\02','\03')
  else
      tcpIpClient_Model.tcpIpClient:setFraming('','','','')
  end

  tcpIpClient_Model.tcpIpClient:setInterface(tcpIpClient_Model.parameters.interface)

  tcpIpClient_Model.tcpIpClient:deregister('OnReceive', receiveData)
  tcpIpClient_Model.tcpIpClient:deregister("OnDisconnected", handleOnDisconnected)
  tcpIpClient_Model.tcpIpClient:deregister("OnConnected", handleOnConnected)

  tcpIpClient_Model.tcpIpClient:register('OnReceive', receiveData)
  tcpIpClient_Model.tcpIpClient:register("OnDisconnected", handleOnDisconnected)
  tcpIpClient_Model.tcpIpClient:register("OnConnected", handleOnConnected)
  tcpIpClient_Model.tcpIpClient:connect()
end
Script.serveFunction("CSK_TCPIPClient.startTCPIPClient", startTCPIPClient)
tcpIpClient_Model.startTCPIPClient = startTCPIPClient

local function stopTCPIPClient()
  _G.logger:info(nameOfModule .. ": Closing connection.")
  sendDataViaTCPIP('Closing connection.')
  tcpIpClient_Model.tcpIpClient:disconnect()
end
Script.serveFunction("CSK_TCPIPClient.stopTCPIPClient", stopTCPIPClient)
tcpIpClient_Model.stopTCPIPClient = stopTCPIPClient

return tcpIpClient_Model