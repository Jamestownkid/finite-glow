#!/usr/bin/env python3
"""
EBook Converter Pro
A professional ebook batch converter with modern GUI
Supports: EPUB, MOBI, AZW3, PDF, DOCX, TXT, HTML, FB2, and more
"""

import customtkinter as ctk
from tkinter import filedialog, messagebox
import threading
import subprocess
import os
import sys
from pathlib import Path
from typing import Optional, List, Dict, Set
import json
import queue


# 1a. version info
APP_NAME = "EBook Converter Pro"
APP_VERSION = "1.0.0"


# 1b. supported formats that calibre can handle
EBOOK_FORMATS = {
    "EPUB": [".epub"],
    "MOBI": [".mobi"],
    "AZW3": [".azw3", ".azw"],
    "PDF": [".pdf"],
    "DOCX": [".docx"],
    "TXT": [".txt"],
    "HTML": [".html", ".htm"],
    "FB2": [".fb2"],
    "LIT": [".lit"],
    "PDB": [".pdb"],
    "RTF": [".rtf"],
    "SNB": [".snb"],
    "TCR": [".tcr"],
    "HTMLZ": [".htmlz"],
    "TXTZ": [".txtz"],
    "CBZ": [".cbz"],
    "CBR": [".cbr"],
    "CBC": [".cbc"],
    "ODT": [".odt"],
}

# 1c. flatten all extensions for quick lookup
ALL_EXTENSIONS: Set[str] = set()
for exts in EBOOK_FORMATS.values():
    ALL_EXTENSIONS.update(exts)


class ConversionWorker:
    """
    2a. handles conversion in a background thread
    keeps the UI responsive during heavy operations
    """
    
    def __init__(self, callback_queue: queue.Queue):
        self.callback_queue = callback_queue
        self.is_running = False
        self.should_stop = False
    
    def find_ebook_convert(self) -> Optional[str]:
        """
        2b. finds calibre's ebook-convert on the system
        checks the usual install paths for each OS
        """
        possible_paths = []
        
        if sys.platform == "win32":
            possible_paths = [
                r"C:\Program Files\Calibre2\ebook-convert.exe",
                r"C:\Program Files (x86)\Calibre2\ebook-convert.exe",
                os.path.expanduser(r"~\AppData\Local\Calibre2\ebook-convert.exe"),
            ]
        elif sys.platform == "darwin":
            possible_paths = [
                "/Applications/calibre.app/Contents/MacOS/ebook-convert",
                "/usr/local/bin/ebook-convert",
            ]
        else:
            possible_paths = [
                "/usr/bin/ebook-convert",
                "/usr/local/bin/ebook-convert",
                os.path.expanduser("~/.local/bin/ebook-convert"),
            ]
        
        # 2c. try PATH first
        try:
            result = subprocess.run(
                ["ebook-convert", "--version"],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                return "ebook-convert"
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass
        
        # 2d. fall back to known paths
        for path in possible_paths:
            if os.path.isfile(path):
                return path
        
        return None
    
    def scan_folder(self, folder: str, source_formats: List[str]) -> List[Path]:
        """
        3a. finds ebook files in folder matching the selected formats
        """
        files = []
        folder_path = Path(folder)
        
        target_extensions = set()
        for fmt in source_formats:
            if fmt in EBOOK_FORMATS:
                target_extensions.update(EBOOK_FORMATS[fmt])
        
        for file_path in folder_path.iterdir():
            if file_path.is_file():
                if file_path.suffix.lower() in target_extensions:
                    files.append(file_path)
        
        return sorted(files, key=lambda x: x.name.lower())
    
    def convert_files(
        self,
        files: List[Path],
        output_folder: Path,
        output_format: str,
        ebook_convert_path: str
    ):
        """
        3b. runs the actual conversion on all files
        sends progress updates back to the UI
        """
        self.is_running = True
        self.should_stop = False
        
        total = len(files)
        successful = 0
        failed = 0
        skipped = 0
        
        output_ext = f".{output_format.lower()}"
        
        for idx, input_file in enumerate(files, 1):
            if self.should_stop:
                self._send_update("status", "Conversion cancelled")
                break
            
            # 3c. skip files already in target format
            if input_file.suffix.lower() == output_ext:
                self._send_update("log", f"Skipping (already {output_format}): {input_file.name}")
                skipped += 1
                continue
            
            progress = (idx / total) * 100
            self._send_update("progress", progress)
            self._send_update("status", f"Converting {idx}/{total}: {input_file.name}")
            self._send_update("log", f"Converting: {input_file.name}")
            
            output_file = output_folder / f"{input_file.stem}{output_ext}"
            
            try:
                # 3d. call ebook-convert
                result = subprocess.run(
                    [ebook_convert_path, str(input_file), str(output_file)],
                    capture_output=True,
                    text=True,
                    timeout=600  # 10 min timeout, PDFs can be slow
                )
                
                if result.returncode == 0:
                    self._send_update("log", f"  -> Success: {output_file.name}")
                    successful += 1
                else:
                    error_msg = result.stderr[:200] if result.stderr else "Unknown error"
                    self._send_update("log", f"  -> FAILED: {error_msg}")
                    failed += 1
                    
            except subprocess.TimeoutExpired:
                self._send_update("log", f"  -> TIMEOUT: File took too long")
                failed += 1
            except Exception as e:
                self._send_update("log", f"  -> ERROR: {str(e)}")
                failed += 1
        
        # 3e. show final results
        self._send_update("progress", 100)
        self._send_update("status", "Conversion complete!")
        self._send_update("log", "\n" + "=" * 50)
        self._send_update("log", f"CONVERSION COMPLETE")
        self._send_update("log", f"  Successful: {successful}")
        self._send_update("log", f"  Failed: {failed}")
        self._send_update("log", f"  Skipped: {skipped}")
        self._send_update("log", "=" * 50)
        self._send_update("complete", {"successful": successful, "failed": failed, "skipped": skipped})
        
        self.is_running = False
    
    def _send_update(self, msg_type: str, data):
        """
        3f. thread-safe way to push updates to the UI
        """
        self.callback_queue.put((msg_type, data))
    
    def stop(self):
        """
        3g. tells the worker to stop after current file
        """
        self.should_stop = True


class EBookConverterApp(ctk.CTk):
    """
    4a. main application window
    built with customtkinter for a modern look
    """
    
    def __init__(self):
        super().__init__()
        
        # 4b. window setup
        self.title(f"{APP_NAME} v{APP_VERSION}")
        self.geometry("900x700")
        self.minsize(800, 600)
        
        # 4c. default appearance
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")
        
        # 4d. state
        self.source_folder = ctk.StringVar()
        self.output_folder = ctk.StringVar()
        self.output_format = ctk.StringVar(value="MOBI")
        self.source_filter = ctk.StringVar(value="All Formats")
        self.scanned_files: List[Path] = []
        
        # 4e. worker thread setup
        self.callback_queue = queue.Queue()
        self.worker = ConversionWorker(self.callback_queue)
        
        # 4f. build the UI
        self._create_ui()
        
        # 4g. check if calibre is available
        self._check_calibre()
        
        # 4h. start polling for worker updates
        self._process_queue()
    
    def _create_ui(self):
        """
        5a. builds all the UI elements
        """
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(4, weight=1)
        
        # ===== HEADER =====
        header_frame = ctk.CTkFrame(self, fg_color="transparent")
        header_frame.grid(row=0, column=0, padx=20, pady=(20, 10), sticky="ew")
        
        title_label = ctk.CTkLabel(
            header_frame,
            text=APP_NAME,
            font=ctk.CTkFont(size=28, weight="bold")
        )
        title_label.pack(side="left")
        
        version_label = ctk.CTkLabel(
            header_frame,
            text=f"v{APP_VERSION}",
            font=ctk.CTkFont(size=14),
            text_color="gray"
        )
        version_label.pack(side="left", padx=(10, 0), pady=(8, 0))
        
        self.theme_btn = ctk.CTkButton(
            header_frame,
            text="Light Mode",
            width=100,
            command=self._toggle_theme
        )
        self.theme_btn.pack(side="right")
        
        # ===== SOURCE FOLDER SECTION =====
        source_frame = ctk.CTkFrame(self)
        source_frame.grid(row=1, column=0, padx=20, pady=10, sticky="ew")
        source_frame.grid_columnconfigure(1, weight=1)
        
        ctk.CTkLabel(
            source_frame,
            text="Source Folder:",
            font=ctk.CTkFont(size=14, weight="bold")
        ).grid(row=0, column=0, padx=15, pady=15, sticky="w")
        
        source_entry = ctk.CTkEntry(
            source_frame,
            textvariable=self.source_folder,
            placeholder_text="Select folder containing ebooks...",
            height=40
        )
        source_entry.grid(row=0, column=1, padx=10, pady=15, sticky="ew")
        
        source_btn = ctk.CTkButton(
            source_frame,
            text="Browse",
            width=100,
            height=40,
            command=self._select_source_folder
        )
        source_btn.grid(row=0, column=2, padx=15, pady=15)
        
        # ===== OUTPUT FOLDER SECTION =====
        output_frame = ctk.CTkFrame(self)
        output_frame.grid(row=2, column=0, padx=20, pady=10, sticky="ew")
        output_frame.grid_columnconfigure(1, weight=1)
        
        ctk.CTkLabel(
            output_frame,
            text="Output Folder:",
            font=ctk.CTkFont(size=14, weight="bold")
        ).grid(row=0, column=0, padx=15, pady=15, sticky="w")
        
        output_entry = ctk.CTkEntry(
            output_frame,
            textvariable=self.output_folder,
            placeholder_text="Select output folder...",
            height=40
        )
        output_entry.grid(row=0, column=1, padx=10, pady=15, sticky="ew")
        
        output_btn = ctk.CTkButton(
            output_frame,
            text="Browse",
            width=100,
            height=40,
            command=self._select_output_folder
        )
        output_btn.grid(row=0, column=2, padx=15, pady=15)
        
        # ===== FORMAT SELECTION SECTION =====
        format_frame = ctk.CTkFrame(self)
        format_frame.grid(row=3, column=0, padx=20, pady=10, sticky="ew")
        
        # 5b. source format filter
        filter_label = ctk.CTkLabel(
            format_frame,
            text="Convert FROM:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        filter_label.pack(side="left", padx=15, pady=15)
        
        filter_options = ["All Formats"] + list(EBOOK_FORMATS.keys())
        self.filter_menu = ctk.CTkOptionMenu(
            format_frame,
            variable=self.source_filter,
            values=filter_options,
            width=150,
            height=35,
            command=self._on_filter_change
        )
        self.filter_menu.pack(side="left", padx=10, pady=15)
        
        ctk.CTkLabel(
            format_frame,
            text="Convert TO:",
            font=ctk.CTkFont(size=14, weight="bold")
        ).pack(side="left", padx=(30, 15), pady=15)
        
        self.format_menu = ctk.CTkOptionMenu(
            format_frame,
            variable=self.output_format,
            values=list(EBOOK_FORMATS.keys()),
            width=150,
            height=35
        )
        self.format_menu.pack(side="left", padx=10, pady=15)
        
        self.scan_btn = ctk.CTkButton(
            format_frame,
            text="Scan Folder",
            width=120,
            height=35,
            fg_color="#2d5a27",
            hover_color="#3d7a37",
            command=self._scan_folder
        )
        self.scan_btn.pack(side="left", padx=(30, 10), pady=15)
        
        self.convert_btn = ctk.CTkButton(
            format_frame,
            text="Convert All",
            width=120,
            height=35,
            fg_color="#1f538d",
            hover_color="#2d6db5",
            command=self._start_conversion
        )
        self.convert_btn.pack(side="left", padx=10, pady=15)
        
        self.stop_btn = ctk.CTkButton(
            format_frame,
            text="Stop",
            width=80,
            height=35,
            fg_color="#8b2020",
            hover_color="#a52a2a",
            command=self._stop_conversion,
            state="disabled"
        )
        self.stop_btn.pack(side="left", padx=10, pady=15)
        
        # ===== PROGRESS AND LOG SECTION =====
        progress_frame = ctk.CTkFrame(self)
        progress_frame.grid(row=4, column=0, padx=20, pady=10, sticky="nsew")
        progress_frame.grid_columnconfigure(0, weight=1)
        progress_frame.grid_rowconfigure(2, weight=1)
        
        self.status_label = ctk.CTkLabel(
            progress_frame,
            text="Ready - Select a folder and click 'Scan Folder'",
            font=ctk.CTkFont(size=13)
        )
        self.status_label.grid(row=0, column=0, padx=15, pady=(15, 5), sticky="w")
        
        self.progress_bar = ctk.CTkProgressBar(progress_frame, height=20)
        self.progress_bar.grid(row=1, column=0, padx=15, pady=10, sticky="ew")
        self.progress_bar.set(0)
        
        self.log_text = ctk.CTkTextbox(
            progress_frame,
            font=ctk.CTkFont(family="Consolas", size=12),
            wrap="word"
        )
        self.log_text.grid(row=2, column=0, padx=15, pady=(5, 15), sticky="nsew")
        
        # ===== FOOTER =====
        footer_frame = ctk.CTkFrame(self, fg_color="transparent")
        footer_frame.grid(row=5, column=0, padx=20, pady=(5, 15), sticky="ew")
        
        self.files_label = ctk.CTkLabel(
            footer_frame,
            text="Files found: 0",
            font=ctk.CTkFont(size=12),
            text_color="gray"
        )
        self.files_label.pack(side="left")
        
        calibre_note = ctk.CTkLabel(
            footer_frame,
            text="Powered by Calibre",
            font=ctk.CTkFont(size=12),
            text_color="gray"
        )
        calibre_note.pack(side="right")
    
    def _toggle_theme(self):
        """
        6a. switches between light and dark mode
        """
        current = ctk.get_appearance_mode()
        if current == "Dark":
            ctk.set_appearance_mode("light")
            self.theme_btn.configure(text="Dark Mode")
        else:
            ctk.set_appearance_mode("dark")
            self.theme_btn.configure(text="Light Mode")
    
    def _check_calibre(self):
        """
        6b. checks if calibre is installed
        """
        ebook_convert = self.worker.find_ebook_convert()
        if ebook_convert:
            self._log(f"Calibre found: {ebook_convert}")
            self.ebook_convert_path = ebook_convert
        else:
            self._log("WARNING: Calibre not found!")
            self._log("Please install Calibre from: https://calibre-ebook.com/download")
            self._log("  Windows: Download installer from website")
            self._log("  Linux: sudo apt install calibre")
            self._log("  macOS: brew install calibre")
            self.ebook_convert_path = None
            
            messagebox.showwarning(
                "Calibre Not Found",
                "Calibre's ebook-convert tool is required.\n\n"
                "Install from: https://calibre-ebook.com/download\n\n"
                "After installing, restart this application."
            )
    
    def _select_source_folder(self):
        """
        6c. opens folder picker for input
        """
        folder = filedialog.askdirectory(title="Select folder with ebooks")
        if folder:
            self.source_folder.set(folder)
            if not self.output_folder.get():
                self.output_folder.set(folder)
            self._log(f"Source folder: {folder}")
    
    def _select_output_folder(self):
        """
        6d. opens folder picker for output
        """
        folder = filedialog.askdirectory(title="Select output folder")
        if folder:
            self.output_folder.set(folder)
            self._log(f"Output folder: {folder}")
    
    def _on_filter_change(self, value):
        """
        6e. re-scans when filter changes
        """
        self._log(f"Filter changed to: {value}")
        if self.source_folder.get():
            self._scan_folder()
    
    def _scan_folder(self):
        """
        7a. scans source folder for matching ebooks
        """
        folder = self.source_folder.get()
        if not folder:
            messagebox.showwarning("Warning", "Please select a source folder first!")
            return
        
        if not os.path.isdir(folder):
            messagebox.showerror("Error", "Source folder does not exist!")
            return
        
        filter_val = self.source_filter.get()
        if filter_val == "All Formats":
            source_formats = list(EBOOK_FORMATS.keys())
        else:
            source_formats = [filter_val]
        
        self._log(f"\nScanning folder: {folder}")
        self._log(f"Looking for: {', '.join(source_formats)}")
        
        self.scanned_files = self.worker.scan_folder(folder, source_formats)
        
        count = len(self.scanned_files)
        self.files_label.configure(text=f"Files found: {count}")
        self.status_label.configure(text=f"Found {count} ebook file(s)")
        
        self._log(f"Found {count} file(s):")
        for f in self.scanned_files[:20]:
            self._log(f"  - {f.name}")
        if count > 20:
            self._log(f"  ... and {count - 20} more")
    
    def _start_conversion(self):
        """
        7b. starts conversion when user clicks the button
        """
        if not self.ebook_convert_path:
            messagebox.showerror("Error", "Calibre not installed!")
            return
        
        if not self.source_folder.get():
            messagebox.showwarning("Warning", "Select a source folder!")
            return
        
        if not self.output_folder.get():
            messagebox.showwarning("Warning", "Select an output folder!")
            return
        
        if not self.scanned_files:
            self._scan_folder()
        
        if not self.scanned_files:
            messagebox.showwarning("Warning", "No ebook files found!")
            return
        
        output_path = Path(self.output_folder.get())
        output_path.mkdir(parents=True, exist_ok=True)
        
        self.convert_btn.configure(state="disabled")
        self.scan_btn.configure(state="disabled")
        self.stop_btn.configure(state="normal")
        
        thread = threading.Thread(
            target=self.worker.convert_files,
            args=(
                self.scanned_files,
                output_path,
                self.output_format.get(),
                self.ebook_convert_path
            ),
            daemon=True
        )
        thread.start()
    
    def _stop_conversion(self):
        """
        7c. cancels the current conversion
        """
        self.worker.stop()
        self._log("Stopping conversion...")
    
    def _process_queue(self):
        """
        8a. polls for worker updates and refreshes UI
        """
        try:
            while True:
                msg_type, data = self.callback_queue.get_nowait()
                
                if msg_type == "progress":
                    self.progress_bar.set(data / 100)
                elif msg_type == "status":
                    self.status_label.configure(text=data)
                elif msg_type == "log":
                    self._log(data)
                elif msg_type == "complete":
                    self._on_conversion_complete(data)
                    
        except queue.Empty:
            pass
        
        self.after(100, self._process_queue)
    
    def _on_conversion_complete(self, results: Dict):
        """
        8b. called when all files are done
        """
        self.convert_btn.configure(state="normal")
        self.scan_btn.configure(state="normal")
        self.stop_btn.configure(state="disabled")
        
        messagebox.showinfo(
            "Conversion Complete",
            f"Successful: {results['successful']}\n"
            f"Failed: {results['failed']}\n"
            f"Skipped: {results['skipped']}"
        )
    
    def _log(self, message: str):
        """
        8c. appends a line to the log textbox
        """
        self.log_text.insert("end", message + "\n")
        self.log_text.see("end")


def main():
    """
    9a. app entry point
    """
    app = EBookConverterApp()
    app.mainloop()


if __name__ == "__main__":
    main()
