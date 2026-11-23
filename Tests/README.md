# Tests

## ImeTest

Console test for the VCL text editors (`TDaisyTextInput`, `TDaisyTextArea`). It feeds the controls the data a real IME would send (composing, replacing, committing and cancelling Korean, Japanese and Arabic text) in LTR and RTL, and checks plain typing still works.

Run from the repo root:

```powershell
.\Tests\RunTests.ps1
```

Or open `Tests\ImeTest.dproj` in the IDE and build it (Win32). Both write to `Tests\Output`.

The exit code is the number of failed checks. Screenshots of the composition rendering are written to `Tests\Output` (git-ignored).

It simulates composition by calling the editors' protected methods and sending IME messages without an IME context. It cannot exercise a real IME, such as the candidate window position, so a manual check with a real Korean IME is still worthwhile.
