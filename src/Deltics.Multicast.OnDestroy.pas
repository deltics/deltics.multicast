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

  unit Deltics.Multicast.OnDestroy;


interface

  uses
    Classes,
    Deltics.Multicast.Notify,
    Deltics.Multicast.Types;


  type
    TOnDestroy = class(TInterfacedObject, IOn_Destroy)
    {
      Provides a ready-made implementation of the IOn_Destroy
       interface, encapsulating a TMultiCastNotify On_Destroy event.
       This class can be used to easily add IOn_Destroy support to any
       handler of multicast events, using interface delegation.

      <code>
        private
          fOn_Destroy: IOn_Destroy;
        public
          constructor Create;
          property On_Destroy: IOn_Destroy read fOn_Destroy implements IOn_Destroy;



        constructor ...Create;
        begin
          inherited;
          fOn_Destroy := TOnDestroy.Create(self);
        end;
      </code>
    }
    private
      fEvent: TMultiCastNotify;
    public
      constructor Create(const aOwner: TObject);
      destructor Destroy; override;
    public
      //## IOn_Destroy
      procedure Add(const aHandler: TNotifyEvent);
      procedure Remove(const aHandler: TNotifyEvent);
      procedure DoEvent;
//      procedure GetListeners(const aList: TList);
    end;



implementation

  uses
    SysUtils;


{ TOn_Destroy ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- }

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TOnDestroy.Create(const aOwner: TObject);
  {@@TOnDestroy.Create

    Creates a new instance of a TOnDestroy class encapsulating an On_Destroy
     event, implemented on behalf of the owner.  The owner should declare
     support for the IOn_Destroy interface and delegate that interface to
     an instance of this class.

    Parameters

      aOwner    The owner of the On_Destroy event implemented by the class.
                 This is the Sender parameter that will be provided when
                 the On_Destroy event is fired.

    See also
      IOn_Destroy
  }
  begin
    inherited Create;
    fEvent := TMultiCastNotify.Create(aOwner);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TOnDestroy.Destroy;
  {@@TOnDestroy.Destroy

    Destructor for an On_Destroy implementation.  Fires the On_Destroy event
     before calling the inherited destructor.
  }
  begin
    try
      fEvent.DoEvent;

    finally
      FreeAndNIL(fEvent);
    end;

    inherited;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TOnDestroy.Add(const aHandler: TNotifyEvent);
  {@@TOnDestroy.Add

    Adds a specified handler to the encapsulated On_Destroy event.
  }
  begin
    fEvent.Add(aHandler);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TOnDestroy.Remove(const aHandler: TNotifyEvent);
  {@@TOnDestroy.Remove

    Removes a specified handler from the encapsulated On_Destroy event.
  }
  begin
    fEvent.Remove(aHandler);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TOnDestroy.DoEvent;
  begin
    fEvent.DoEvent;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
//  procedure TOnDestroy.GetListeners(const aList: TList);
//  begin
//    fEvent.GetListeners(aList);
//  end;




end.
