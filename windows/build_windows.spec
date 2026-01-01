# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec file for Windows build
Run with: pyinstaller build_windows.spec
"""

import sys
from pathlib import Path

# 1a. get customtkinter path for bundling
import customtkinter
ctk_path = Path(customtkinter.__file__).parent

block_cipher = None

# 1b. analysis configuration
a = Analysis(
    ['src/main.py'],
    pathex=[],
    binaries=[],
    datas=[
        # 1c. include customtkinter assets (themes, etc)
        (str(ctk_path), 'customtkinter'),
    ],
    hiddenimports=[
        'customtkinter',
        'PIL._tkinter_finder',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'matplotlib',
        'numpy',
        'pandas',
        'scipy',
        'pytest',
        'IPython',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

# 1d. create PYZ archive
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

# 1e. create executable
exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='EBookConverterPro',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,  # no console window
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='assets/icon.ico',  # TODO: add icon
)

# 1f. collect into distribution folder
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='EBookConverterPro',
)
