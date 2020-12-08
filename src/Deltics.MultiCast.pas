{
  * MIT LICENSE *

  Copyright © 2008,2020 Jolyon Smith

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

  unit Deltics.MultiCast;


interface

  uses
    Deltics.Multicast.Event,
    Deltics.Multicast.Exceptions,
    Deltics.Multicast.Notify,
    Deltics.Multicast.OnDestroy,
    Deltics.Multicast.Types;


  type
    EMultiCastException = Deltics.Multicast.Exceptions.EMulticastException;
    TMultiCastEvent     = Deltics.Multicast.Event.TMulticastEvent;
    TMultiCastNotify    = Deltics.Multicast.Notify.TMulticastNotify;

    IOn_Destroy = Deltics.Multicast.Types.IOn_Destroy;
    TOnDestroy = Deltics.Multicast.OnDestroy.TOnDestroy;


    Multicast = class
      class procedure EnableDebugAssertions;
      class procedure DisableDebugAssertions;
    end;



{-- +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ --}

implementation

  uses
  { vcl: }
    SysUtils,
    Deltics.Multicast.Debugging;








{ Multicast }

  class procedure Multicast.DisableDebugAssertions;
  begin
    DebugAssertions := FALSE;
  end;


  class procedure Multicast.EnableDebugAssertions;
  begin
    DebugAssertions := TRUE;
  end;




end.
