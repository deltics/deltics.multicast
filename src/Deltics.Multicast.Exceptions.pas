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

  unit Deltics.Multicast.Exceptions;


interface

  uses
    Contnrs,
    SysUtils;


  type
    EMulticastException = class(Exception)
    end;


    EHandlerExceptions = class(Exception)
    private
      fExceptions: TObjectList;
      function get_Count: Integer;
      function get_Exceptions(const aIndex: Integer): TObject;
    protected
      procedure Add;
    public
      constructor Create;
      destructor Destroy; override;
      property Count: Integer read get_Count;
      property Exceptions[const aIndex: Integer]: TObject read get_Exceptions; default;
    end;



implementation

  uses
    Classes,
    Types;


{ EMulticastException }

  procedure EHandlerExceptions.Add;
  begin
    fExceptions.Add(TObject(AcquireExceptionObject));
  end;


  constructor EHandlerExceptions.Create;
  begin
    inherited Create('Multicast event exceptions were raised');

    fExceptions := TObjectList.Create(TRUE);
  end;


  destructor EHandlerExceptions.Destroy;
  begin
    fExceptions.Free;

    inherited;
  end;


  function EHandlerExceptions.get_Count: Integer;
  begin
    result := fExceptions.Count;
  end;


  function EHandlerExceptions.get_Exceptions(const aIndex: Integer): TObject;
  begin
    result := fExceptions[aIndex];
  end;




end.
