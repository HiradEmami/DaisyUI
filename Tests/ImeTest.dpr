program ImeTest;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows, Winapi.Messages, Winapi.Imm, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls,
  Vcl.Graphics, Vcl.Imaging.pngimage, Daisy.TextEdit, Daisy.VCL.TextInput, Daisy.VCL.TextArea;

type
  TInputT = class(TDaisyTextInput)
  public
    procedure Compose(const S: string; ACursor: Integer = 0; const A: TBytes = nil);
    procedure Commit(const S: string);
    procedure Cancel;
  end;

  TAreaT = class(TDaisyTextArea)
  public
    procedure Compose(const S: string; ACursor: Integer = 0; const A: TBytes = nil);
    procedure Commit(const S: string);
    procedure Cancel;
  end;

  THelper = class
    Count: Integer;
    procedure Changed(Sender: TObject);
  end;

procedure TInputT.Compose(const S: string; ACursor: Integer; const A: TBytes);
begin
  ApplyComposition(S, ACursor, A);
end;

procedure TInputT.Commit(const S: string);
begin
  CommitComposition(S);
end;

procedure TInputT.Cancel;
begin
  ApplyComposition('', 0, nil);
end;

procedure TAreaT.Compose(const S: string; ACursor: Integer; const A: TBytes);
begin
  ApplyComposition(S, ACursor, A);
end;

procedure TAreaT.Commit(const S: string);
begin
  CommitComposition(S);
end;

procedure TAreaT.Cancel;
begin
  ApplyComposition('', 0, nil);
end;

procedure THelper.Changed(Sender: TObject);
begin
  Inc(Count);
end;

var
  GFail: Integer;
  GForm: TForm;
  GH: THelper;

procedure Check(ACond: Boolean; const AName: string);
begin
  if ACond then
    Writeln('PASS  ', AName)
  else
  begin
    Writeln('FAIL  ', AName);
    Inc(GFail);
  end;
end;

function NewInput(const AText: string = ''): TInputT;
begin
  Result := TInputT.Create(GForm);
  Result.Parent := GForm;
  Result.SetBounds(10, 10, 300, 48);
  Result.Text := AText;
  GH.Count := 0;
  Result.OnChange := GH.Changed;
end;

function NewArea(const AText: string = ''): TAreaT;
begin
  Result := TAreaT.Create(GForm);
  Result.Parent := GForm;
  Result.SetBounds(10, 70, 300, 120);
  Result.Text := AText;
  GH.Count := 0;
  Result.OnChange := GH.Changed;
end;

procedure Shot(const AName: string);
var
  LBmp: TBitmap;
  LPng: TPngImage;
begin
  LBmp := TBitmap.Create;
  LPng := TPngImage.Create;
  try
    LBmp.SetSize(GForm.ClientWidth, GForm.ClientHeight);
    GForm.PaintTo(LBmp.Canvas, 0, 0);
    LPng.Assign(LBmp);
    LPng.SaveToFile(ExtractFilePath(ParamStr(0)) + AName + '.png');
  finally
    LPng.Free;
    LBmp.Free;
  end;
end;

var
  LIn: TInputT;
  LArea: TAreaT;
  LAttrs: TBytes;
  LMsg: TMessage;
  LHan, LGeul: string;

begin
  LHan := #$D55C;  // han
  LGeul := #$AE00; // geul
  Application.Initialize;
  GH := THelper.Create;
  GForm := TForm.Create(nil);
  GForm.ClientWidth := 340;
  GForm.ClientHeight := 210;
  GForm.Show;
  Application.ProcessMessages;
  try
    // 1. composing in progress: shown, not committed, no OnChange
    LIn := NewInput;
    LIn.Compose(#$314E, 1);
    Check(LIn.Text = #$314E, 'compose shows text in the control');
    Check(LIn.SelStart = 1, 'caret after composition');
    Check(GH.Count = 0, 'no OnChange while composing');
    LIn.Compose(#$D558, 1);
    LIn.Compose(LHan, 1);
    Check(LIn.Text = LHan, 'composition replaced, not appended');
    // 2. result + next syllable in one message
    LIn.Commit(LHan);
    LIn.Compose(#$3131, 1);
    Check(LIn.Text = LHan + #$3131, 'commit then new composition');
    Check(GH.Count = 1, 'OnChange once per commit');
    LIn.Compose(LGeul, 1);
    LIn.Commit(LGeul);
    Check(LIn.Text = LHan + LGeul, 'second commit inserted once');
    Check(GH.Count = 2, 'OnChange twice after two commits');
    Check(LIn.SelStart = 2, 'caret after committed text');
    // 3. undo reverts the whole run
    LIn.Undo;
    Check(LIn.Text = '', 'undo reverts the composed run');
    LIn.Free;

    // 4. cancel restores text, no OnChange
    LIn := NewInput('abc');
    LIn.SelStart := 3;
    LIn.Compose(LHan, 1);
    Check(LIn.Text = 'abc' + LHan, 'compose at end of existing text');
    LIn.Cancel;
    Check(LIn.Text = 'abc', 'cancel removes the composition');
    Check(GH.Count = 0, 'cancel fires no OnChange');
    // 5. mid-text composition
    LIn.SelStart := 1;
    LIn.Compose(LHan, 1);
    Check(LIn.Text = 'a' + LHan + 'bc', 'compose in the middle');
    LIn.Commit(LHan);
    Check((LIn.Text = 'a' + LHan + 'bc') and (LIn.SelStart = 2), 'commit in the middle keeps the rest');
    LIn.Free;

    // 6. selection is replaced
    LIn := NewInput('abcdef');
    LIn.SelStart := 1;
    LIn.SelLength := 2;
    LIn.Compose(LHan, 1);
    Check(LIn.Text = 'a' + LHan + 'def', 'composition replaces the selection');
    LIn.Commit(LHan);
    Check((LIn.Text = 'a' + LHan + 'def') and (GH.Count = 1), 'commit after selection: one change');
    LIn.Free;

    // 7. MaxLength
    LIn := NewInput;
    LIn.MaxLength := 3;
    LIn.Text := 'ab';
    LIn.SelStart := 2;
    LIn.Compose(LHan + LGeul, 2);
    Check(Length(LIn.Text) <= 3, 'MaxLength respected while composing');
    LIn.Commit(LHan + LGeul);
    Check(Length(LIn.Text) <= 3, 'MaxLength respected on commit');
    LIn.Free;

    // 8. attributes: target clause underline paints without error
    LIn := NewInput('abc ');
    LIn.SelStart := 4;
    SetLength(LAttrs, 3);
    LAttrs[0] := ATTR_INPUT;
    LAttrs[1] := ATTR_TARGET_CONVERTED;
    LAttrs[2] := ATTR_TARGET_CONVERTED;
    LIn.Compose(#$65E5#$672C#$8A9E, 3, LAttrs);
    LIn.SetFocus;
    Application.ProcessMessages;
    LIn.Invalidate;
    Application.ProcessMessages;
    Shot('input-ltr-composing');
    Check(LIn.Text = 'abc ' + #$65E5#$672C#$8A9E, 'multi char composition with attributes');
    LIn.BiDiMode := bdRightToLeft;
    Application.ProcessMessages;
    Shot('input-rtl-composing');
    Check(LIn.Text = 'abc ' + #$65E5#$672C#$8A9E, 'RTL composing keeps text');
    LIn.Commit(#$65E5#$672C#$8A9E);
    Check(LIn.Text = 'abc ' + #$65E5#$672C#$8A9E, 'RTL commit');
    LIn.BiDiMode := bdLeftToRight;
    LIn.Free;

    // 9. message plumbing
    LIn := NewInput('abc');
    LMsg.Msg := WM_IME_STARTCOMPOSITION; LMsg.WParam := 0; LMsg.LParam := 0; LMsg.Result := 99;
    LIn.Dispatch(LMsg);
    Check(LMsg.Result = 0, 'WM_IME_STARTCOMPOSITION handled');
    LMsg.Msg := WM_IME_COMPOSITION; LMsg.LParam := GCS_COMPSTR; LMsg.Result := 99;
    LIn.Dispatch(LMsg);
    Check((LMsg.Result = 0) and (LIn.Text = 'abc'), 'WM_IME_COMPOSITION with no IME context is harmless');
    LMsg.LParam := 0;
    LIn.Dispatch(LMsg);
    Check(LIn.Text = 'abc', 'cancel message harmless');
    LMsg.Msg := WM_IME_ENDCOMPOSITION; LMsg.Result := 99;
    LIn.Dispatch(LMsg);
    Check(LMsg.Result = 0, 'WM_IME_ENDCOMPOSITION handled');
    LMsg.Msg := WM_IME_SETCONTEXT; LMsg.WParam := 1; LMsg.LParam := LPARAM(ISC_SHOWUIALL);
    LIn.Dispatch(LMsg);
    Check(True, 'WM_IME_SETCONTEXT handled without error');
    LIn.ReadOnly := True;
    LMsg.Msg := WM_IME_COMPOSITION; LMsg.LParam := GCS_COMPSTR;
    LIn.Dispatch(LMsg);
    Check(LIn.Text = 'abc', 'read only ignores composition');
    LIn.Free;

    // 10. typing without IME is unaffected
    LIn := NewInput;
    LIn.SetFocus;
    Application.ProcessMessages;
    LIn.Perform(WM_CHAR, Ord('H'), 0);
    LIn.Perform(WM_CHAR, Ord('i'), 0);
    Check(LIn.Text = 'Hi', 'normal WM_CHAR typing still works');
    LIn.Free;

    // 11. text area: wrapping with a long composition
    LArea := NewArea('first line' + sLineBreak + 'second line');
    LArea.SelStart := 5;
    LArea.Compose(LHan + LGeul + LHan + LGeul + LHan + LGeul + LHan + LGeul + LHan + LGeul + LHan + LGeul +
      LHan + LGeul + LHan + LGeul + LHan + LGeul + LHan + LGeul + LHan + LGeul, 3);
    LArea.SetFocus;
    Application.ProcessMessages;
    Shot('area-ltr-composing');
    Check(Pos('first', LArea.Text) = 1, 'text area keeps text around a long composition');
    LArea.Cancel;
    Check(LArea.Text = 'first line' + sLineBreak + 'second line', 'text area cancel restores text');
    LArea.Compose(LHan, 1);
    LArea.Commit(LHan);
    Check((Copy(LArea.Text, 1, 6) = 'first' + LHan) and (GH.Count = 1), 'text area commit once');
    LArea.BiDiMode := bdRightToLeft;
    LArea.SelStart := 2;
    LArea.Compose(LGeul, 1);
    Application.ProcessMessages;
    Shot('area-rtl-composing');
    LArea.Commit(LGeul);
    Check(Pos(LGeul, LArea.Text) > 0, 'text area RTL commit');

    // 12. pure right-to-left text in RTL mode
    LIn := NewInput(#$0645#$0631#$062D#$0628#$0627 + ' ');
    LIn.BiDiMode := bdRightToLeft;
    LIn.SelStart := 6;
    LIn.Compose(#$0628#$0643, 2);
    LIn.SetFocus;
    Application.ProcessMessages;
    Shot('input-rtl-arabic-composing');
    LIn.Commit(#$0628#$0643);
    Check(Length(LIn.Text) = 8, 'Arabic composition committed');
    LIn.Free;
  except
    on E: Exception do
    begin
      Writeln('EXCEPTION ', E.ClassName, ': ', E.Message);
      Inc(GFail);
    end;
  end;
  Writeln;
  Writeln('Failures: ', GFail);
  ExitCode := GFail;
end.
