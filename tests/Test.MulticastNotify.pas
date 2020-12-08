{
  * MIT LICENSE *

  Copyright © 2020 Jolyon Smith

  Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.


  * GPL and Other Licenses *

  The FSF deem this license to be compatible with version 3 of the GPL.
   Compatability with other licenses should be verified by reference to those
   other license terms.


  * Contact Details *

  Original author : Jolyon Direnko-Smith
  e-mail          : jsmith@deltics.co.nz
  github          : deltics/deltics.multicast
}

{$i deltics.multicast.inc}

  unit Test.MulticastNotify;


interface

  uses
    Deltics.Smoketest;


  type
    TMulticastNotifyTests = class(TTest)
    private
      fCallCountA: Integer;
      fCallCountB: Integer;
      procedure NotifyA(Sender: TObject);
      procedure NotifyB(Sender: TObject);
      procedure NotifyException(Sender: TObject);
      procedure NotifyArgumentException(Sender: TObject);
    published
      procedure SetupMethod;
      procedure TeardownMethod;
      procedure SingleHandlerIsCalledWhenAnEventIsFired;
      procedure SingleHandlerThatIsRemovedIsNotCalledWhenTheEventIsFired;
      procedure AttemptToAddDuplicateHandlerIsIgnored;
      procedure MultipleHandlersAreCalledWhenAnEventIsFired;
      procedure RemainingHandlersAreCalledWhenAnEventIsFiredAfterSomeAreRemoved;
      procedure DisabledEventCallsNoHandlersWhenFired;
      procedure ExceptionsRaisedByHandlersArePropogatedToEventTrigger;
      procedure AllHandlersAreCalledIfAnExceptionIsRaisedByOne;
      procedure AllHandlersAreCalledAndAMulticastExceptionIsRaisedIfMultiplHandlersRaiseExceptions;
    end;



implementation

  uses
    SysUtils,
    Deltics.Multicast;



{ TMulticastNotifyTests -------------------------------------------------------------------------- }

  var
    sut: TMultiCastNotify;

  // Event handlers used as spies in tests

  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.NotifyA(Sender: TObject);
  begin
    Inc(fCallCountA);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.NotifyB(Sender: TObject);
  begin
    Inc(fCallCountB);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.NotifyException(Sender: TObject);
  begin
    raise Exception.Create('Deliberate error');
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.NotifyArgumentException(Sender: TObject);
  begin
    raise EArgumentException.Create('Deliberate error');
  end;


  // Setup / Teardown methods

  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.SetupMethod;
  begin
    sut := TMultiCastNotify.Create(self);

    fCallCountA := 0;
    fCallCountB := 0;
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.TeardownMethod;
  begin
    sut.Free;
  end;


  // The tests

  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.SingleHandlerIsCalledWhenAnEventIsFired;
  begin
    sut.Add(NotifyA);

    sut.DoEvent;

    Test('fCallCountA').Assert(fCallCountA).Equals(1);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.SingleHandlerThatIsRemovedIsNotCalledWhenTheEventIsFired;
  begin
    sut.Add(NotifyA);
    sut.Remove(NotifyA);

    sut.DoEvent;

    Test('fCallCountA').Assert(fCallCountA).Equals(0);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.AttemptToAddDuplicateHandlerIsIgnored;
  begin
    sut.Add(NotifyA);
    sut.Add(NotifyA);

    Test('sut.Count').Assert(sut.Count).Equals(1);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.MultipleHandlersAreCalledWhenAnEventIsFired;
  begin
    sut.Add(NotifyA);
    sut.Add(NotifyB);

    sut.DoEvent;

    Test('fCallCountA').Assert(fCallCountA).Equals(1);
    Test('fCallCountB').Assert(fCallCountA).Equals(1);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.RemainingHandlersAreCalledWhenAnEventIsFiredAfterSomeAreRemoved;
  begin
    sut.Add(NotifyA);
    sut.Add(NotifyB);
    sut.Remove(NotifyA);

    sut.DoEvent;

    Test('fCallCountA').Assert(fCallCountA).Equals(0);
    Test('fCallCountB').Assert(fCallCountB).Equals(1);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.DisabledEventCallsNoHandlersWhenFired;
  begin
    sut.Add(NotifyA);
    sut.Add(NotifyB);
    sut.Enabled := FALSE;

    sut.DoEvent;

    Test('fCallCountA').Assert(fCallCountA).Equals(0);
    Test('fCallCountB').Assert(fCallCountB).Equals(0);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.ExceptionsRaisedByHandlersArePropogatedToEventTrigger;
  begin
    Test.RaisesException(Exception, 'Deliberate error');

    sut.Add(NotifyException);

    sut.DoEvent;
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.AllHandlersAreCalledIfAnExceptionIsRaisedByOne;
  begin
    Test.RaisesException(Exception, 'Deliberate error');

    sut.Add(NotifyException);
    sut.Add(NotifyA);

    try
      sut.DoEvent;

    finally
      Test('fCallCountA').Assert(fCallCountA).Equals(1);
    end;
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastNotifyTests.AllHandlersAreCalledAndAMulticastExceptionIsRaisedIfMultiplHandlersRaiseExceptions;
  begin
    Test.RaisesException(EMulticastException);

    try
      sut.Add(NotifyException);
      sut.Add(NotifyArgumentException);

      sut.DoEvent;

    except
      on e: EMulticastException do
      begin
        Test('e.Count').Assert(e.Count).Equals(2);
        Test('e[0] is Exceptions').Assert(e[0] is Exception);
        Test('e[1] is EArgumentException').Assert(e[1] is EArgumentException);

        raise;
      end;
    end;
  end;



end.
