# Deltics.Multicast

Provides an extensible implementation of a multicast events framework for
 Delphi (Win32/Win64), including a reference implementation of TMultiCastNotify -
 a multicast equivalent of TNotifyEvent.

Multicast events in this framework are designed to be compatible with existing
 unicast event handler methods.

Includes:

  - TMultiCastEvent     : base class for multicast event implementations

  - TMultiCastNotify    : a multicast implementation of TNotifyEvent

  - IOn_Destroy         : an interface establishing that the implementing
                           class supports an On_Destroy multicast TNotifyEvent

  - TOnDestroy          : class to enable IOn_Destroy interface support to be
                           easily added to any multicast listener using interface
                           delegation

  - EMulticastException : An aggregator exception that collects all exceptions
                           raised by multicast event handlers and which is then
                           itself raised following the firing of an event.


# Introduction

# Getting Started - Duget Package

To use this library simply add a `deltics.multicast` reference in your project .duget file and run `duget update` to obtain the latest version available in any of your feeds (duget.org is recommended).

# Build and Test

The build pipeline for this package compiles a set of tests with every version of Delphi from version 7 onward.  The test project uses [Smoketest 2.x](https://github.com/deltics/deltics.smoketest).