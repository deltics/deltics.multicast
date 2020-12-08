
{$define CONSOLE}

program Test;

{$i deltics.multicast.inc}

uses
  FastMM4,
  SysUtils,
  Deltics.Smoketest,
  Deltics.Multicast in '..\src\Deltics.Multicast.pas',
  Deltics.Multicast.Debugging in '..\src\Deltics.Multicast.Debugging.pas',
  Deltics.Multicast.Event in '..\src\Deltics.Multicast.Event.pas',
  Deltics.Multicast.Exceptions in '..\src\Deltics.Multicast.Exceptions.pas',
  Deltics.Multicast.Notify in '..\src\Deltics.Multicast.Notify.pas',
  Deltics.Multicast.OnDestroy in '..\src\Deltics.Multicast.OnDestroy.pas',
  Deltics.Multicast.Types in '..\src\Deltics.Multicast.Types.pas',
  Test.MulticastEvent in 'Test.MulticastEvent.pas',
  Test.MulticastNotify in 'Test.MulticastNotify.pas';

begin
  TestRun.Test(TMulticastEventTests);
  TestRun.Test(TMulticastNotifyTests);
end.

