--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
-----------------------------------------------------------
-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
_G.availableAPIs = require('Communication.TCPIPClient.helper.checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------

-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding TCPIPClient_Model
-- Check this script regarding TCPIPClient_Model parameters and functions
_G.tcpIpClient_Model = require('Communication/TCPIPClient/TCPIPClient_Model')

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function main()

  ----------------------------------------------------------------------------------------
  -- Can be used e.g. like this
  ----------------------------------------------------------------------------------------

  --_G.tcpIpClient_Model.connect()
  --_G.tcpIpClient_Model.transmit('Hello Server.')

  -- Add trigger cmd to listen to and related event to call / forward
  --CSK_TCPIPClient.addTriggerEventPair('TRG', 'TCPIPClient_OnNewTestTrigger')

  -- Other modules can register on this event to listen to incoming data in parallel
  --[[
  --@handleOnNewDataReceived(data:string)
  local function handleOnNewDataReceived(data)
    -- Insert your event handling code here
  end
  Script.register("CSK_TCPIPClient.OnNewDataReceived", handleOnNewDataReceived)
  ]]
  CSK_TCPIPClient.pageCalled() -- Update UI
end
Script.register("Engine.OnStarted", main)

--OR

-- Call function after persistent data was loaded
--Script.register("CSK_TCPIPClient.OnDataLoadedOnReboot", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************