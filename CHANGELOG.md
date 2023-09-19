# Changelog
All notable changes to this project will be documented in this file.

## Release 3.1.0

### New features
- Register to events of other modules / apps to forward its content via TCP/IP

### Improvements
- Update triggerEvents / eventsToForward if parameters were loaded
- Updated docu and added "Known issues" in README that data of registered events to be forwarded via TCP/IP are always transmitted as converted data type "string"

### Bugfix
- Did not convert data of registered events to strings before trying to transmit them via TCP/IP

## Release 3.0.0

### Improvements
- Renamed 'selectTriggerEventPairViaUi' to 'selectTriggerEventPairViaUI' / 'addTriggerEventPairViaUi' to 'addTriggerEventPairViaUI' / 'sendDataViaTCP' to 'sendDataViaTCPIP'
- Using recursive helper functions to convert Container <-> Lua table

## Release 2.5.0

### Improvements
- Minor code restructure
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

### Bugfix
- Wrong Enum reference

## Release 2.4.0

### Improvements
- Using internal moduleName variable to be usable in merged apps instead of _APPNAME, as this did not work with PersistentData module in merged apps.

## Release 2.3.0

### Improvements
- ParameterName available on UI
- Loading only required APIs ('LuaLoadAllEngineAPI = false') -> less time for GC needed
- Update of helper funcs to support 4-dim tables for PersistentData
- Minor code edits / docu updates

## Release 2.2.0

### Improvements
- Dynamically create events for triggerEvent pairs (events to notify if a trigger signal was received via TCPIP connection)
- Prepared for all CSK user levels: Operator, Maintenance, Service, Admin
- Changed status type of user levels from string to bool

## Release 2.1.0

### New features
- Added support for userlevels, required userlevel is Maintenance

## Release 2.0.0

### New features
- Update handling of persistent data according to CSK_PersistentData module ver. 2.0.0

## Release 1.0.0
- Initial commit