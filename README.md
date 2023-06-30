# CSK_Module_TCPIPClient

Module to provide TCP/IP client configuration

![](https://github.com/SICKAppSpaceCodingStarterKit/CSK_Module_TCPIPClient/blob/main/docu/media/UI_Screenshot.png)

## How to Run

The app includes an intuitive GUI to setup the TCPIP client and is intended for all devices supporting 'TCPIPClient' CROWN.  
It is possible to add "trigger/event"-pairs. If the TCPIP client receives a message with configured "trigger"-command inside, it will
notify configured event (this event needs to exist already inside of the manifest, see "OnNewTestTrigger"-event as an example).  
If directly after the "trigger"-command follows a ',' it can forward following data as a binary string parameter on the event.  
(E.g. 'TriggerCmd, data, data2')  
Additionally other modules can also listen to the received messages by registering to event "CSK_TCPIPClient.OnNewDataReceived".  
For further information check out the [documentation](https://raw.githack.com/SICKAppSpaceCodingStarterKit/CSK_Module_TCPIPClient/main/docu/CSK_Module_TCPIPClient.html) in the folder "docu".

## Information

Tested on:

1. SIM1012        - Firmware 2.2.0
2. SICK AppEngine - Firmware 1.3.2
3. TDC-E          - Firmware L4M 2023.1

This module is part of the SICK AppSpace Coding Starter Kit developing approach.  
It is programmed in an object oriented way. Some of these modules use kind of "classes" in Lua to make it possible to reuse code / classes in other projects.  
In general it is not neccessary to code this way, but the architecture of this app can serve as a sample to be used especially for bigger projects and to make it easier to share code.  
Please check the [documentation](https://github.com/SICKAppSpaceCodingStarterKit/.github/blob/main/docu/SICKAppSpaceCodingStarterKit_Documentation.md) of CSK for further information.  

## Topics

Coding Starter Kit, CSK, Module, SICK-AppSpace, TCP, IP, TCPIP, Client
