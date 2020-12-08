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

  unit Deltics.Multicast.Event;


interface

  uses
    Classes;


  type
    TMultiCastEvent = class
    {
      Provides the base class for all multi-cast events.

      When implementing a multi-cast event you will derive from this class or
       from some other class that has this class as an ancestor.

      This base class provides the mechanism for storing the list of handlers
       to be called in response to an event occuring and for ensuring that
       references between events and handler objects are maintained where
       possible.

      See also
        IOn_Destroy
    }
    private
      fDisableCount: Integer;
      fActive: Boolean;
      fMethods: TList;
      function get_Count: Integer;
      function get_Enabled: Boolean;
      function get_Method(const aIndex: Integer): TMethod;
      procedure set_Enabled(const aValue: Boolean);

      procedure ListenerDestroyed(aSender: TObject);
    protected
      class function ReferencesAreNIL(const aArray; const aCount: Integer): Boolean;

      procedure Call(const aMethod: TMethod); virtual; abstract;

      procedure Add(const aMethod: TMethod); overload;
      procedure Insert(const aMethod: TMethod); overload;
      procedure Remove(const aMethod: TMethod); overload;

      property Method[const aIndex: Integer]: TMethod read get_Method;
    public
      constructor Create; virtual;
      destructor Destroy; override;

      procedure Assign(const aSource: TMultiCastEvent);
      procedure DoEvent;
      procedure Enable;
      procedure Disable;
//      procedure GetListeners(const aList: TList);

      property Active: Boolean read fActive;
      property Count: Integer read get_Count;
      property Enabled: Boolean read get_Enabled write set_Enabled;
    end;





implementation

  uses
    SysUtils,
    Deltics.Multicast.Debugging,
    Deltics.Multicast.Exceptions,
    Deltics.Multicast.Types;


{-- TMultiCastEvent  ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- }

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TMultiCastEvent.Create;
  {@@TMultiCastEvent.Create

    Default constructor for multi-cast events.  Multi-cast event classes
     MUST call this constructor if they override or introduce an alternate
     constructor.
  }
  begin
    inherited Create;

    fMethods := TList.Create;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TMultiCastEvent.Destroy;
  {@@TMultiCastEvent.Destroy

    Destructor for multi-cast events.  Any handlers remaining in the
     handler list are removed.  If the implementor of a handler supports
     the IOn_Destroy interface the event removes it's handler from that
     object's On_Destroy event.
  }
  var
    i: Integer;
    obj: TObject;
    listener: IOn_Destroy;
  begin
    for i := 0 to Pred(fMethods.Count) do
    begin
      obj := TObject(PMethod(fMethods[i]).Data);

      if Supports(obj, IOn_Destroy, listener) then
        listener.Remove(ListenerDestroyed);

      Dispose(PMethod(fMethods[i]));
      fMethods[i] := NIL;
    end;

    FreeAndNIL(fMethods);

    inherited;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMultiCastEvent.get_Count: Integer;
  {@@TMultiCastEvent.Count

    Returns the number of handlers currently assigned to the event.
  }
  begin
    result := fMethods.Count;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMultiCastEvent.get_Enabled: Boolean;
  {@@TMultiCastEvent.Enabled

    Indicates whether or not the event is currently enabled.

    Handlers may be added or removed to an event when not enabled, but
     they will not be called if that event is fired.

    See Also
      TMultiCastEvent.Enable
      TMultiCastEvent.Disable
  }
  begin
    result := (fDisableCount <= 0);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMultiCastEvent.get_Method(const aIndex: Integer): TMethod;
  {@@TMultiCastEvent.Method

    Returns the TMethod at the iIndex position in the list of handlers for
     the event.
  }
  begin
    result := TMethod(fMethods[aIndex]^);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.Assign(const aSource: TMultiCastEvent);
  var
    i: Integer;
  begin
    if NOT Assigned(self) or NOT Assigned(aSource) then
      EXIT;

    ASSERT(aSource.ClassType = ClassType);

    for i := 0 to Pred(aSource.Count) do
      Add(PMethod(aSource.fMethods[i])^);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TMultiCastEvent.ReferencesAreNIL(const aArray;
                                                  const aCount: Integer): Boolean;
  {@@TMultiCastEvent.ReferencesAreNIL

  Parameters

    aArray - An array of pointers to references to be tested for duplicates.

    aCount - The number of pointers in the array.

  Description

    Raises an EInvalidPointer exception if the array is found to contain
     duplicate pointers or pointers to references that have already been
     assigned.

    This procedure is intended for use during development to assist in
     detecting and reporting coding errors.  This procedure is only
     available if compiling with ASSERT() statements enabled.

    Calls to this method should be made inside an $ifopt C+ conditional
     compilation directive.
  }
  type
    PointerArray  = array of Pointer;
    PPointerArray = ^PointerArray;
  var
    i, j: Integer;
    this: Pointer;
    next: Pointer;
  begin
    result := TRUE;

    if aCount = 1 then
    begin
      // No need to check for coincident references if there is only 1 of them,
      //  just check that it isn't already assigned.
      if (PointerArray(aArray)[0] <> NIL) then
        raise EInvalidPointer.CreateFmt('%s.CreateEvents: The reference has already been assigned.',
                                        [ClassName]);

      EXIT;
    end;

    for i := 0 to Pred(aCount) do
    begin
      this := PointerArray(@aArray)[i];
      if (Pointer(this^) <> NIL) then
        raise EInvalidPointer.CreateFmt('%s.CreateEvents: The reference at index %d has already '
                                      + 'been assigned.', [ClassName, i]);

      for j := i + 1 to Pred(aCount) do
      begin
        next := PointerArray(@aArray)[j];
        if (this = next) then
          raise EInvalidPointer.CreateFmt('%s.CreateEvents: Duplicate event references at '
                                        + 'indices %d and %d.', [ClassName, i, j]);
      end;
    end;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.Add(const aMethod: TMethod);
  {@@TMultiCastEvent.Add

  Parameters

    aMethod - A method (procedure or function implemented by an instance of a
               class type) which is to be added to the list of handlers for
               this event.

  Description

    Adds a specified method to the event.  Only one reference to a method can
     be attached to an event - if the specific method is already in the list
     of handlers for the event it will not be added again.

    The object implementing the specified method (the data pointer) is tested
     to see if it supports the IOn_Destroy interface.  If so, the event
     uses that interface to add its own ReceiverDestroyed handler to the
     On_Destroy event of the object.

    This ensures that if the object that implements the method being added is
     destroyed then its handler(s) will be removed.


  * Important *

    The implementation of Add in this class is NOT virtual and only has
     PROTECTED visibility.  It should NOT be overridden in derived classes.

    This is because the TMethod type of the parameter is potentially not
     type safe.  Derived classes should provide their own public Add and Remove
     methods accepting a specific TMethod signature (e.g. TNotifyEvent) to
     ensure that only handlers with the correct parameter list are added and
     removed from the event handler list.


  See Also
    IOn_Destroy
  }
  var
    i: Integer;
    obj: TObject;
    handler: PMethod;
    listener: IOn_Destroy;
  begin
    if NOT Assigned(self) then
      EXIT;

    // Check to ensure that the specified method is not already attached
    for i := 0 to Pred(fMethods.Count) do
    begin
      handler := fMethods[i];

      if (aMethod.Code = handler.Code) and (aMethod.Data = handler.Data) then
        EXIT;
    end;

    // Not already attached - create a new TMethod reference and copy the
    //  details from the specific method, then add to our list of handlers
    handler := New(PMethod);
    handler.Code := aMethod.Code;
    handler.Data := aMethod.Data;
    fMethods.Add(handler);

    // Check the object implementing this handler for support of the
    //  IOn_Destroy interface.  If available, add our own
    //  ReceiverDestroyed event handler to that object's On_Destroy event
    obj := TObject(aMethod.Data);

    if Supports(obj, IOn_Destroy, listener) then
      listener.Add(ListenerDestroyed);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.Insert(const aMethod: TMethod);
  {@@TMultiCastEvent.Insert

  Parameters

    aMethod - A method (procedure or function implemented by an instance of a
               class type) which is to be insert at the TOP of the list of
               handlers for this event.

  Description

    Adds a specified method to the event.  Only one reference to a method can
     be attached to an event - if the specific method is already in the list
     of handlers for the event it will not be added again.

    The object implementing the specified method (the data pointer) is tested
     to see if it supports the IOn_Destroy interface.  If so, the event
     uses that interface to add its own ReceiverDestroyed handler to the
     On_Destroy event of the object.

    This ensures that if the object that implements the method being added is
     destroyed then its handler(s) will be removed.


  * Important *

    The implementation of Add in this class is NOT virtual and only has
     PROTECTED visibility.  It should NOT be overridden in derived classes.

    This is because the TMethod type of the parameter is potentially not
     type safe.  Derived classes should provide their own public Add and Remove
     methods accepting a specific TMethod signature (e.g. TNotifyEvent) to
     ensure that only handlers with the correct parameter list are added and
     removed from the event handler list.


  See Also
    IOn_Destroy
  }
  var
    i: Integer;
    obj: TObject;
    handler: PMethod;
    listener: IOn_Destroy;
  begin
    if NOT Assigned(self) then
      EXIT;

    // Check to ensure that the specified method is not already attached
    for i := 0 to Pred(fMethods.Count) do
    begin
      handler := fMethods[i];

      if (aMethod.Code = handler.Code) and (aMethod.Data = handler.Data) then
        EXIT;
    end;

    // Not already attached - create a new TMethod reference and copy the
    //  details from the specific method, then add to our list of handlers
    handler := New(PMethod);
    handler.Code := aMethod.Code;
    handler.Data := aMethod.Data;
    fMethods.Insert(0, handler);

    // Check the object implementing this handler for support of the
    //  IOn_Destroy interface.  If available, add our own
    //  ReceiverDestroyed event handler to that object's On_Destroy event
    obj := TObject(aMethod.Data);

    if Supports(obj, IOn_Destroy, listener) then
      listener.Add(ListenerDestroyed);
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.Remove(const aMethod: TMethod);
  {@@TMultiCastEvent.Remove

  Parameters

    aMethod - A method (procedure or function implemented by an instance of a
               class type) which is to be removed from the list of handlers
               for this event.

  Description

    Removes the specified method from the list of handlers for the event.
    Has no effect if the specified method was not found.

    ## NOTE: No account is taken of the case where the method being removed
    ##        is the last or only handler for the event that is implemented
    ##        by an object that implements IOn_Destroy
    ##
    ##       In that case we could remove ourselves from the objects
    ##        On_Destroy event, but doing so would require scanning all
    ##        handlers to determine whether any others are implemented by
    ##        the same object as well as testing for and acquiring the
    ##        IOn_Destroy interface.
    ##
    ##       All of which is a bit excessive given that by not doing so
    ##        all we do is waste a tiny amount of memory (at most, one
    ##        entry in that objects On_Destroy handler list) that will be
    ##        properly cleaned up when either this event or the object
    ##        is eventually destroyed.

  * Important *

    The implementation of Remove in this class is NOT virtual and only has
     PROTECTED visibility.  It should NOT be overridden in derived classes.

    This is because the TMethod type of the parameter is potentially not
     type safe.  Derived classes should introduce their own public Add and
     Remove methods accepting a specific TMethod signature (e.g. TNotifyEvent)
     to ensure that only handlers with the correct parameter list are added and
     removed from the event handler list.


  See Also
    IOn_Destroy
  }
  var
    i: Integer;
    handler: PMethod;
  begin
    if NOT Assigned(self) then
      EXIT;

    for i := 0 to Pred(fMethods.Count) do
    begin
      handler := fMethods[i];

      if (aMethod.Code = handler.Code) and (aMethod.Data = handler.Data) then
      begin
        Dispose(handler);
        fMethods.Delete(i);

        // Only one reference to any method can be attached to any one event, so
        //  once we have found and removed the method there is no need to check the
        //  remaining method references.
        BREAK;
      end;
    end;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.set_Enabled(const aValue: Boolean);
  begin
    case aValue of
      FALSE : Disable;
      TRUE  : Enable;
    end;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.ListenerDestroyed(aSender: TObject);
  {@@TMultiCastEvent.ListenerDestroyed

  Parameters

    aSender - The object being destroyed that implements the IOn_Destroy
               interface and which has added one or more handlers to this event.

  Description

    This is the built-in handler for an On_Destroyed event sent from a receiver
     when that receiver is destroyed.  Inspects every handler looking for and
     removing any that are implemented by the aSender.
  }
  var
    i: Integer;
    method: PMethod;
  begin
    for i := 0 to Pred(Count) do
    begin
      method := fMethods[i];
      if (method.Data = Pointer(aSender)) then
      begin
        Dispose(method);
        fMethods[i] := NIL;
      end;
    end;

    fMethods.Pack;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.DoEvent;
  {@@TMultiCastEvent.DoEvent

  Calls every handler in the list of handlers for the event.


  * Important *

    DoEvent is NOT virtual, and is a PUBLIC method in this class.

    Since the Add and Remove methods are only PROTECTED this means that a
     TMultiCastEvent cannot be used directy to implement a multi cast event -
     a class must be derived which implements PUBLIC Add and Remove methods
     that accept methods with a specific signature.

    The default DoEvent implementation may then be used on the derived class
     to call those handlers, but ONLY if they are of a type that does not
     require any parameters OR if all required parameters are available from
     the member variables of the event class (e.g. TMultiCastNotify).

    If the methods that handle the event requires parameters, then the DoEvent
     method MUST be reintroduced in the derived class, to accept any parameters
     that are to be passed to each handler and hide this base implementation.
  }
  var
    i: Integer;
    exception: EMultiCastException;
    singleException: TObject;
  begin
    if NOT Assigned(self) or (NOT Enabled) or Active then
      EXIT;

    fActive   := TRUE;
    exception := EMulticastException.Create;
    try
      for i := 0 to Pred(Count) do
      begin
        try
          Call(Method[i]);
        except
          exception.Add;
        end;
      end;

    finally
      fActive := FALSE;
    end;

    case exception.Count of
      0 : exception.Free;
      1 : begin
            exception.Extract(singleException);
            exception.Free;

            raise singleException;
          end;
    else
      raise exception;
    end;
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.Enable;
  {
    Enables or Disables the event.  An event is create in an Enabled state
     and remains Enabled only as long as all calls to Disable have been
     balanced by a call to Enable.

    That is, if an event has been Disabled twice then it must be Enabled
     twice in order to become Enabled (un-Disabled) once again (Example 1).

    For this reason it is strongly recommended that event enabling and
     disabling should be performed in balanced try..finally constructs (Example2)

    Examples

      <code>
        event.Disable;
        event.Disable;
        event.Enable;   // event is still DISabled
        event.Enable;   // event is now enabled
      </code>

      <code>
        event.Enable;
        event.Enable;
        event.Disable;   // event is still ENabled
        event.Disable;   // event is now disabled
      </code>

    Example

      <code>
        event.Disable;
        try
          // Do work ...
        finally
          event.Enable;
        end;
      </code>
  }
  begin
    Dec(fDisableCount);

  {$ifdef debug_DelticsMulticast}
    if DebugAssertions then ASSERT(fDisableCount >= 0, 'Event is already Enabled');
  {$endif}
  end;


  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.Disable;
  {
    <COMBINE TMultiCastEvent.Enable>
  }
  begin
    Inc(fDisableCount);
  end;


(*
  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.GetListeners(const aList: TList);
  {
    Initialises a specified list with all (unique) listeners that have
     handlers currently assigned to the event.  The current contents of
     aList will be cleared.
  }
  var
    i: Integer;
  begin
    aList.Clear;
    for i := 0 to Pred(Count) do
      if aList.IndexOf(Method[i].Data) = -1 then
        aList.Add(Method[i].Data);
  end;
*)



end.
