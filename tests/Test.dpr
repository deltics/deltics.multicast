
{$define CONSOLE}

program Test;

{$i deltics.multicast.inc}

uses
  FastMM4,
  SysUtils,
  Deltics.Smoketest,
  Deltics.MultiCast in '..\src\Deltics.MultiCast.pas',
  Deltics.MultiCast.Debugging in '..\src\Deltics.MultiCast.Debugging.pas',
  Deltics.MultiCast.Event in '..\src\Deltics.MultiCast.Event.pas',
  Deltics.Multicast.Exceptions in '..\src\Deltics.Multicast.Exceptions.pas',
  Deltics.MultiCast.Notify in '..\src\Deltics.MultiCast.Notify.pas',
  Deltics.Multicast.OnDestroy in '..\src\Deltics.Multicast.OnDestroy.pas',
  Deltics.Multicast.Types in '..\src\Deltics.Multicast.Types.pas',
  Test.MulticastEvent in 'Test.MulticastEvent.pas',
  Test.MulticastNotify in 'Test.MulticastNotify.pas';

begin
  TestRun.Test(TMulticastEventTests);
  TestRun.Test(TMulticastNotifyTests);
end.

