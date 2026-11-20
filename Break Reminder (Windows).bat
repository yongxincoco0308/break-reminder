@echo off
rem Double-click me.  双击我就行。  Haz doble clic aquí.
start "" powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0control-panel.ps1"
