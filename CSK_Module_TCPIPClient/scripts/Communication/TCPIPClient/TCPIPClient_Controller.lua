---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the TCPIPClient_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_TCPIPClient'

-- Timer to update UI via events after page was loaded
local tmrTCPIPClient = Timer.create()
tmrTCPIPClient:setExpirationTime(300)
tmrTCPIPClient:setPeriodic(false)

local triggerValue, eventValue -- Selected trigger command + eventName for trigger/event pair via UI
local selectedTrigger = '' -- Selected trigger/event pair

-- Reference to global handle
local tcpIpClient_Model

-- ************************ UI Events Start ********************************

Script.serveEvent("CSK_TCPIPClient.OnNewConnectionStatus", "TCPIPClient_OnNewConnectionStatus")
Script.serveEvent("CSK_TCPIPClient.OnNewInterfaceList", "TCPIPClient_OnNewInterfaceList")
Script.serveEvent("CSK_TCPIPClient.OnNewInterface", "TCPIPClient_OnNewInterface")
Script.serveEvent("CSK_TCPIPClient.OnNewServerIP", "TCPIPClient_OnNewServerIP")
Script.serveEvent("CSK_TCPIPClient.OnNewPort", "TCPIPClient_OnNewPort")
Script.serveEvent("CSK_TCPIPClient.OnNewRxFrame", "TCPIPClient_OnNewRxFrame")
Script.serveEvent("CSK_TCPIPClient.OnNewTxFrame", "TCPIPClient_OnNewTxFrame")
Script.serveEvent("CSK_TCPIPClient.OnNewCurrentConnectionStatus", "TCPIPClient_OnNewCurrentConnectionStatus")
Script.serveEvent("CSK_TCPIPClient.OnNewCommand", "TCPIPClient_OnNewCommand")
Script.serveEvent("CSK_TCPIPClient.OnNewLog", "TCPIPClient_OnNewLog")
Script.serveEvent("CSK_TCPIPClient.OnNewTriggerEventPairList", "TCPIPClient_OnNewTriggerEventPairList")

Script.serveEvent("CSK_TCPIPClient.OnUserLevelOperatorActive", "TCPIPClient_OnUserLevelOperatorActive")
Script.serveEvent("CSK_TCPIPClient.OnUserLevelMaintenanceActive", "TCPIPClient_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_TCPIPClient.OnUserLevelServiceActive", "TCPIPClient_OnUserLevelServiceActive")
Script.serveEvent("CSK_TCPIPClient.OnUserLevelAdminActive", "TCPIPClient_OnUserLevelAdminActive")

Script.serveEvent("CSK_TCPIPClient.OnNewStatusLoadParameterOnReboot", "TCPIPClient_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_TCPIPClient.OnPersistentDataModuleAvailable", "TCPIPClient_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_TCPIPClient.OnDataLoadedOnReboot", "TCPIPClient_OnDataLoadedOnReboot")
Script.serveEvent("CSK_TCPIPClient.OnNewParameterName", "TCPIPClient_OnNewParameterName")

-- Event to use for forwarding commands + opt. parameters
Script.serveEvent("CSK_TCPIPClient.OnNewTestTrigger", "TCPIPClient_OnNewTestTrigger")
Script.serveEvent("CSK_TCPIPClient.OnNewDataReceived", "TCPIPClient_OnNewDataReceived")

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("TCPIPClient_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("TCPIPClient_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("TCPIPClient_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("TCPIPClient_OnUserLevelAdminActive", status)
end

--- Function to get access to the tcpIpClient_Model object
---@param handle handle Handle of tcpIpClient_Model object
local function setTCPIPClient_Model_Handle(handle)
  tcpIpClient_Model = handle
  if tcpIpClient_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if tcpIpClient_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("TCPIPClient_OnUserLevelOperatorActive", true)
    Script.notifyEvent("TCPIPClient_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("TCPIPClient_OnUserLevelServiceActive", true)
    Script.notifyEvent("TCPIPClient_OnUserLevelAdminActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrTCPIPClient()

  updateUserLevel()

  Script.notifyEvent("TCPIPClient_OnNewConnectionStatus", tcpIpClient_Model.parameters.connectionStatus)
  Script.notifyEvent("TCPIPClient_OnNewInterfaceList", tcpIpClient_Model.interfaceList)
  Script.notifyEvent("TCPIPClient_OnNewInterface", tcpIpClient_Model.parameters.interface)
  Script.notifyEvent("TCPIPClient_OnNewServerIP", tcpIpClient_Model.parameters.serverIP)
  Script.notifyEvent("TCPIPClient_OnNewPort", tcpIpClient_Model.parameters.port)
  Script.notifyEvent("TCPIPClient_OnNewRxFrame", tcpIpClient_Model.parameters.rxFrame)
  Script.notifyEvent("TCPIPClient_OnNewTxFrame", tcpIpClient_Model.parameters.txFrame)
  Script.notifyEvent("TCPIPClient_OnNewCurrentConnectionStatus", tcpIpClient_Model.currentConnectionStatus)
  Script.notifyEvent("TCPIPClient_OnNewCommand", tcpIpClient_Model.command)
  Script.notifyEvent("TCPIPClient_OnNewStatusLoadParameterOnReboot", tcpIpClient_Model.parameterLoadOnReboot)
  Script.notifyEvent("TCPIPClient_OnPersistentDataModuleAvailable", tcpIpClient_Model.persistentModuleAvailable)
  Script.notifyEvent("TCPIPClient_OnNewParameterName", tcpIpClient_Model.parametersName)
  tcpIpClient_Model.sendLog()
  Script.notifyEvent("TCPIPClient_OnNewTriggerEventPairList", tcpIpClient_Model.helperFuncs.createJsonList(tcpIpClient_Model.parameters.commandList))

end
Timer.register(tmrTCPIPClient, "OnExpired", handleOnExpiredTmrTCPIPClient)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrTCPIPClient:start()
  return ''
end
Script.serveFunction("CSK_TCPIPClient.pageCalled", pageCalled)

local function selectTriggerEventPairViaUI(selection)

  if selection == "" then
    selectedTrigger = ''
    _G.logger:info(nameOfModule .. ": Did not find TriggerCommand")
  else
    local _, pos = string.find(selection, '"TriggerCommand":"')
    if pos == nil then
      _G.logger:info(nameOfModule .. ": Did not find TriggerCommand")
      selectedTrigger = ''
    else
      pos = tonumber(pos)
      local endPos = string.find(selection, '"', pos+1)
      selectedTrigger = string.sub(selection, pos+1, endPos-1)
      if selectedTrigger == nil then
        _G.logger:info(nameOfModule .. ": Did not find TriggerCommand")
        selectedTrigger = ''
      else
        _G.logger:info(nameOfModule .. ": Selected TriggerCommand: " .. tostring(selectedTrigger))
      end
    end
  end
end
Script.serveFunction("CSK_TCPIPClient.selectTriggerEventPairViaUI", selectTriggerEventPairViaUI)

local function addTriggerEventPair(trigger, event)
  tcpIpClient_Model.parameters.commandList[trigger] = event
  _G.logger:info(nameOfModule .. ": Added Trigger/Event pair = " .. trigger .. '/' .. event)
  Script.notifyEvent("TCPIPClient_OnNewTriggerEventPairList", tcpIpClient_Model.helperFuncs.createJsonList(tcpIpClient_Model.parameters.commandList))

  local check = Script.isServedAsEvent("CSK_TCPIPClient." .. event)
  if not check then
    Script.serveEvent("CSK_TCPIPClient." .. event, "TCPIPClient_" .. event, 'string:?')
  end

end
Script.serveFunction("CSK_TCPIPClient.addTriggerEventPair", addTriggerEventPair)

local function deleteTriggerEventPair(trigger)
  tcpIpClient_Model.parameters.commandList[trigger] = nil
  Script.notifyEvent("TCPIPClient_OnNewTriggerEventPairList", tcpIpClient_Model.helperFuncs.createJsonList(tcpIpClient_Model.parameters.commandList))
  _G.logger:info(nameOfModule .. ": Deleted trigger = " .. tostring(trigger))
end
Script.serveFunction("CSK_TCPIPClient.deleteTriggerEventPair", deleteTriggerEventPair)

local function deleteTriggerEventPairViaUI()
  if selectedTrigger ~= '' then
    deleteTriggerEventPair(selectedTrigger)
  end
end
Script.serveFunction("CSK_TCPIPClient.deleteTriggerEventPairViaUI", deleteTriggerEventPairViaUI)

local function setTrigger(value)
  triggerValue = value
  _G.logger:info(nameOfModule .. ": Set trigger = " .. tostring(value))
end
Script.serveFunction("CSK_TCPIPClient.setTrigger", setTrigger)

local function setEventValue(value)
  eventValue = value
  _G.logger:info(nameOfModule .. ": Set event value = " .. tostring(value))
end
Script.serveFunction("CSK_TCPIPClient.setEventValue", setEventValue)

local function addTriggerEventPairViaUI()
  addTriggerEventPair(triggerValue, eventValue)
end
Script.serveFunction("CSK_TCPIPClient.addTriggerEventPairViaUI", addTriggerEventPairViaUI)

local function setConnectionStatus(status)
  tcpIpClient_Model.parameters.connectionStatus = status
  _G.logger:info(nameOfModule .. ": Set connection status = " .. tostring(status))
  if status then
    tcpIpClient_Model.startTCPIPClient()
  else
    tcpIpClient_Model.stopTCPIPClient()
  end
end
Script.serveFunction("CSK_TCPIPClient.setConnectionStatus", setConnectionStatus)

local function setServerAddress(address)
  tcpIpClient_Model.parameters.serverIP = address
  _G.logger:info(nameOfModule .. ": Set Server IP = " .. tostring(address))
end
Script.serveFunction("CSK_TCPIPClient.setServerAddress", setServerAddress)

local function setPort(port)
  tcpIpClient_Model.parameters.port = port
  _G.logger:info(nameOfModule .. ": Set Port = " .. tostring(port))
end
Script.serveFunction("CSK_TCPIPClient.setPort", setPort)

local function setInterface(interface)
  tcpIpClient_Model.parameters.interface = interface
  _G.logger:info(nameOfModule .. ": Set interface = " .. tostring(interface))
end
Script.serveFunction("CSK_TCPIPClient.setInterface", setInterface)

local function setRxFraming(frame)
  _G.logger:info(nameOfModule .. ": Set RX framing = " .. tostring(frame))
  if frame == 'STX-ETX' then
    tcpIpClient_Model.parameters.rxFrame = frame
  elseif frame == 'empty' then
    tcpIpClient_Model.parameters.rxFrame = frame
  end
end
Script.serveFunction("CSK_TCPIPClient.setRxFraming", setRxFraming)

local function setTxFraming(frame)
  _G.logger:info(nameOfModule .. ": Set TX framing = " .. tostring(frame))
  if frame == 'STX-ETX' then
    tcpIpClient_Model.parameters.txFrame = frame
  elseif frame == 'empty' then
    tcpIpClient_Model.parameters.txFrame = frame
  end
end
Script.serveFunction("CSK_TCPIPClient.setTxFraming", setTxFraming)

local function setCommand(cmd)
  _G.logger:info(nameOfModule .. ": Preset command to send = " .. tostring(cmd))
  tcpIpClient_Model.command = cmd
end
Script.serveFunction("CSK_TCPIPClient.setCommand", setCommand)

local function transmitCommando()
  _G.logger:info(nameOfModule .. ": Send command = " .. tostring(tcpIpClient_Model.command))
  tcpIpClient_Model.sendDataViaTCPIP(tcpIpClient_Model.command)
end
Script.serveFunction("CSK_TCPIPClient.transmitCommando", transmitCommando)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  tcpIpClient_Model.parametersName = name
  _G.logger:info(nameOfModule .. ": Set new parameter name: " .. name)
end
Script.serveFunction("CSK_TCPIPClient.setParameterName", setParameterName)

local function sendParameters()
  if tcpIpClient_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(tcpIpClient_Model.helperFuncs.convertTable2Container(tcpIpClient_Model.parameters), tcpIpClient_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, tcpIpClient_Model.parametersName, tcpIpClient_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send TCPIPClient parameters with name '" .. tcpIpClient_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_TCPIPClient.sendParameters", sendParameters)

local function loadParameters()
  if tcpIpClient_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(tcpIpClient_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      tcpIpClient_Model.parameters = tcpIpClient_Model.helperFuncs.convertContainer2Table(data)
      if tcpIpClient_Model.parameters.connectionStatus then
        tcpIpClient_Model.startTCPIPClient()
      end
      CSK_TCPIPClient.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_TCPIPClient.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  tcpIpClient_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_TCPIPClient.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')
    tcpIpClient_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      tcpIpClient_Model.parametersName = parameterName
      tcpIpClient_Model.parameterLoadOnReboot = loadOnReboot
    end

    if tcpIpClient_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('TCPIPClient_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setTCPIPClient_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

