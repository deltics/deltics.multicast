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

  unit Test.MulticastEvent;


interface

  uses
    Deltics.Smoketest;


  type
    TMulticastEventTests = class(TTest)
      procedure SetupMethod;
      procedure TeardownMethod;
      procedure EventsAreCreatedEnabled;
      procedure DisablingANewlyCreatedEventDisablesTheEvent;
      procedure EventsThatAreDisabledMoreTimesThanTheyAreEnabledRemainDisabled;
      procedure EventsThatAreDisabledAndEnabledEquallyAreEnabled;
      procedure EventsThatAreEnabledAndDisabledEquallyAreEnabled;
      procedure EventsThatAreEnabledMultipleTimesThenDisabledOnceRemainEnabled;
      procedure EnablingAnEventThatIsAlreadyEnabledRaisesAssertFailed;
    end;



implementation

  uses
    SysUtils,
    Deltics.Multicast;


{ TMulticastEventTests --------------------------------------------------------------------------- }

  var
    sut: TMulticastEvent;


  // Setup / Teardown methods

  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.SetupMethod;
  begin
    // We are knowingly creating an instance of the abstract class
    //  in order to test behaviour of that base class
    {$warnings off}
    sut := TMulticastEvent.Create;
    {$warnings on}
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.TeardownMethod;
  begin
    sut.Free;
  end;


  // Tests

  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.EventsAreCreatedEnabled;
  begin
    Test('Enabled').Assert(sut.Enabled);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.DisablingANewlyCreatedEventDisablesTheEvent;
  begin
    sut.Disable;

    Test('NOT Enabled').Assert(NOT sut.Enabled);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.EventsThatAreDisabledMoreTimesThanTheyAreEnabledRemainDisabled;
  begin
    sut.Disable;
    sut.Disable;
    sut.Enable;

    Test('NOT Enabled').Assert(NOT sut.Enabled);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.EventsThatAreDisabledAndEnabledEquallyAreEnabled;
  begin
    sut.Disable;
    sut.Disable;
    sut.Enable;
    sut.Enable;

    Test('Enabled').Assert(sut.Enabled);
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.EventsThatAreEnabledAndDisabledEquallyAreEnabled;
  begin
    Multicast.DisableDebugAssertions; // Otherwise the first Enable will ASSERT()
    try
      sut.Enable;
      sut.Enable;
      sut.Disable;
      sut.Disable;

      Test('Enabled').Assert(sut.Enabled);
    finally
      Multicast.EnableDebugAssertions;
    end;
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.EventsThatAreEnabledMultipleTimesThenDisabledOnceRemainEnabled;
  begin
    Multicast.DisableDebugAssertions; // Otherwise the first Enable will ASSERT()
    try
      sut.Enable;
      sut.Enable;
      sut.Disable;

      Test('Enabled').Assert(sut.Enabled);
    finally
      Multicast.EnableDebugAssertions;
    end;
  end;


  {-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --}
  procedure TMulticastEventTests.EnablingAnEventThatIsAlreadyEnabledRaisesAssertFailed;
  begin
    Test.RaisesException(EAssertionFailed);//, 'Event is already Enabled');

    Test('Enabled').Assert(sut.Enabled);
    sut.Enable;
  end;



end.
