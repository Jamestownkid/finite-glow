# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec file for macOS build
Creates a proper .app bundle
Run with: pyinstaller build_macos.spec
"""

import sys
from pathlib import Path

# 1a. get customtkinter path for bundling
import customtkinter
ctk_path = Path(customtkinter.__file__).parent

block_cipher = None

# 1b. analysis - gather all dependencies
a = Analysis(
    ['src/main.py'],
    pathex=[],
    binaries=[],
    datas=[
        # 1c. include customtkinter assets
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
    console=False,  # windowed mode, no terminal
    disable_windowed_traceback=False,
    argv_emulation=True,  # needed for macos drag-drop
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='assets/icon.icns',
)

# 1f. collect everything into folder
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

# 1g. create macos .app bundle
app = BUNDLE(
    coll,
    name='EBook Converter Pro.app',
    icon='assets/icon.icns',
    bundle_identifier='com.ebookconverter.pro',
    version='1.0.0',
    info_plist={
        'NSPrincipalClass': 'NSApplication',
        'NSAppleScriptEnabled': False,
        'NSHighResolutionCapable': True,
        'CFBundleDisplayName': 'EBook Converter Pro',
        'CFBundleName': 'EBook Converter Pro',
        'CFBundleShortVersionString': '1.0.0',
        'CFBundleVersion': '1.0.0',
        'LSMinimumSystemVersion': '10.13.0',
        'NSHumanReadableCopyright': 'Copyright 2024. All rights reserved.',
    },
)
