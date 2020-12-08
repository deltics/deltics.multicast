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

  unit Deltics.Multicast.Notify;


interface

  uses
    Classes,
    Deltics.Multicast.Event;


  type
    {@@PMultiCastNotify

     Pointer to a TMultiCastNotify object reference.  This type is used to
      provide a type-safe implementation of TMultiCastNotify.CreateEvents to
      enable multiple TMultiCastNotify objects to be created and assigned to a
      number of reference variables in a single call.
    }
    PMultiCastNotify = ^TMultiCastNotify;


    TMultiCastNotify = class(TMultiCastEvent)
    {
      TMultiCastNotify is a multi-cast equivalent of the standard TNotifyEvent.
       This multi-cast event implementation serves two purposes:

      * A ready-to-use multi-cast version of the standard TNotifyEvent
         event for use in your own applications.

      * A complete example of a multi-cast event implementation to be used
         as a guide when implementing your own multi-cast events.
    }
    private
      fSender: TObject;
    protected
      property Sender: TObject read fSender;
      procedure Call(const aMethod: TMethod); override;
    public
      class procedure CreateEvents(const aSender: TObject;
                                   const aEvents: array of PMultiCastNotify);
      constructor Create(const aSender: TObject); reintroduce; virtual;
      procedure Insert(const aHandler: TNotifyEvent); overload;
      procedure Add(const aHandler: TNotifyEvent); overload;
      procedure Remove(const aHandler: TNotifyEvent); overload;
      procedure DoEventFor(const aSender: TObject);
    end;





implementation

  uses
    Deltics.Multicast.Debugging;



{ TMultiCastNotify ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure TMultiCastNotify.CreateEvents(const aSender: TObject;
                                                const aEvents: array of PMultiCastNotify);
  {@@TMultiCastNotify.CreateEvents

    Parameters

      aSender - The ultimate sender of the events being created.

      aEvents - An array of pointers to TMultiCastNotify references.


    Description

      Creates any number of TMultiCastNotify objects and places references to those
       objects at the locations specified by the pointers in the array.


    Exceptions

      EInvalidPointer - Raised from a call to CheckReferences if the events array
                         contains duplicate pointers or references that have already
                         been assigned.

                        CheckReferences is only called if ASSERT() statements
                         are enabled.

  }
  var
    i: Integer;
  begin
  {$ifdef debug_DelticsMulticast}
    if DebugAssertions then ASSERT(ReferencesAreNIL(aEvents, Length(aEvents)));
  {$endif}

    for i := Low(aEvents) to High(aEvents) do
      aEvents[i]^ := Create(aSender);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TMultiCastNotify.Create(const aSender: TObject);
  {@@TMultiCastNotify.Create

  Parameters

    aSender - The object that is to be considered the Sender of the
               notification events.  Typically this will be the creator of
               the multi-cast event itself.

  Description

    Constructor for multi-cast notification events.  Records a specified
     sender object which will be passed in the Sender parameter of the
     TNotifyEvent handlers that called when the multi-cast notify event is
     fired.
  }
  begin
    inherited Create;

    fSender := aSender;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.Add(const aHandler: TNotifyEvent);
  {@@TMultiCastNotify.Add

  Parameters

    aHandler - A TNotifyEvent handler to be added to the multi-cast handler
                list.

  Description

    Adds a specified TNotifyEvent handler to the multi-cast event.  If the
     handler is already in the list of handlers for the event it will not
     be added again.
  }
  begin
    inherited Add(TMethod(aHandler));
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.Insert(const aHandler: TNotifyEvent);
  {@@TMultiCastNotify.Insert

  Parameters

    aHandler - A TNotifyEvent handler to be added to TOP of the multi-cast
                handler list.

  Description

    Adds a specified TNotifyEvent handler to the multi-cast event.  If the
     handler is already in the list of handlers for the event it will not
     be added again.
  }
  begin
    inherited Insert(TMethod(aHandler));
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.Remove(const aHandler: TNotifyEvent);
  {@@TMultiCastNotify.Remove

  Parameters

    aHandler - A TNotifyEvent handler to be removed from the multi-cast
                handler list.

  Description

    Removes a specified TNotifyEvent handler from the multi-cast event.
  }
  begin
    inherited Remove(TMethod(aHandler));
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.Call(const aMethod: TMethod);
  {@@TMultiCastNotify.Call

    Calls the specified handler passing the event Sender in the Sender
     parameter.
  }
  begin
    TNotifyEvent(aMethod)(Sender);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.DoEventFor(const aSender: TObject);
  {@@TMultiCastNotify.DoEventFor

    Call all handlers for the multi-cast event, specifying an object to be
     passed as the Sender parameter for each handler.

    An example of when this method might be used is in the implementation of
     some collection class, where the collection provides an On_Change event
     to notify interested parties of a change to some item in the collection
     or to the collection itself.

    Changes to the collection would call Collection.On_Change.DoEvent,
     passing the collection as the Sender to all handlers.  Changes to an
     item in the collection would call Collection.On_Change.DoEventFor(Item)
     passing the specific item as the Sender to all handlers.
  }
  var
    originalSender: TObject;
  begin
    originalSender := Sender;
    fSender := aSender;
    try
      DoEvent;
    finally
      fSender := originalSender;
    end;
  end;



end.
