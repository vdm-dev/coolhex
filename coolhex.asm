;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/
;Copyright (c) Free Programmers' Society. All rights reversed.
;
;Unicorn Project
;
;CoolHex ver 0.11 by Maxim CooLick aka MCL
;
;Advanced hex viewer\editor with PE header analyser.
;
;;*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*;;
;;  $####$    $####$      $####$    $#       $#   #$  $####$  #X   X#;;     	  
;; $#$       $#    #$    $#    #$   $#       $#   #$  $#       #X X# ;;
;;$#$       $#      #$  $#      #$  $#       $#####$  $####$    #X#  ;;
;; $#$       $#    #$    $#    #$   $#       $#   #$  $#       #X X# ;;
;;  $####$    $####$      $####$    $######  $#   #$  $####$  #X   X#;;	
;;*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*;;
;
;Microsoft (R) Macro Assembler Version 6.14.8444
;Microsoft (R) Incremental Linker Version 5.12.8078
;
;\ml /c /coff /Cp /nologo coolhex.asm
;\rc coolhex.rc
;\link /SUBSYSTEM:WINDOWS /RELEASE /VERSION:0.11 coolhex.obj coolhex.res 

.386

.model flat,stdcall

option casemap:none

include \masm32\include\windows.inc
include \masm32\include\gdi32.inc 
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comctl32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\shell32.inc

includelib \masm32\lib\gdi32.lib 
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\shell32.lib

clWinMain proto :DWORD,:DWORD,:DWORD,:DWORD
clAboutDlgProc proto :HWND,:DWORD,:DWORD,:DWORD 
clGoToDlgProc proto :HWND,:DWORD,:DWORD,:DWORD
clGTEditProc proto :HWND,:DWORD,:DWORD,:DWORD

clFillMainList proto :DWORD, :DWORD, :DWORD 
clFillInformationTree proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

clAddItemIntoTree proto :DWORD, :DWORD, :DWORD, :DWORD
clSetFastPanelInfo proto
clSetStatus proto :DWORD, :DWORD
clPaintContent proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
clInvalidateContent proto 
clOpenIncrementFile proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :BYTE 
clOpenFile proto :DWORD
clCloseFile proto :DWORD
clPETest proto :DWORD, :DWORD
clRealHex proto :DWORD, :DWORD, :BYTE
clRealASCII proto :DWORD, :DWORD, :BYTE

clEnlargeInsertIntoFile proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
clDecreaseCutFromFile proto :DWORD, :DWORD, :DWORD, :DWORD
clCutInsert proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

clGetNTFromDOSHeader proto :DWORD
clGetISHFromDOSHeader proto :DWORD, :DWORD
clGetNumberOfSectoins proto :DWORD
clGetSectoinFromAddress proto :DWORD, :DWORD, :DWORD
clCreateData proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

clGetImageBase proto :DWORD
clFileOffset2VA proto :DWORD, :DWORD
clVA2RVA proto :DWORD, :DWORD
clFileOffset2RVA proto :DWORD, :DWORD
clVA2FileOffset proto :DWORD, :DWORD
clRVA2FileOffset proto :DWORD, :DWORD
clRVA2VA proto :DWORD, :DWORD 

   RGB macro red,green,blue
           xor eax,eax

           mov ah,blue
           shl eax,8
           mov ah,green
           mov al,red

   endm

.const 
MAIN_ICO equ 1000
ICO2 equ 1500
IDB_TREE equ 2000 
IDM_MNU equ 4000
IDM_Open equ 4002
IDM_Save equ 4003
IDM_SaveAs equ 4004
IDM_Close equ 4005
IDM_Exit equ 4007
IDM_About equ 4102
IDM_GOTO equ 4101
IDI_TRAY equ 8000

IDM_GT_OK equ 10011
IDM_GT_CANCEL equ 10012
IDC_EDIT10009 equ 10009
IDC_COMBOBOX10013 equ 10013 

IDM_ST_RESTORE equ 4500
IDM_ST_EXIT equ 4501

WM_SHELLNOTIFY equ WM_USER+5

IDM_DLG9000 equ 9000
IDM_DLG10000 equ 10000

CH_TOOLBAR						equ 6000
IDC_TBB_OPEN					equ 4002
IDC_TBB_SAVE					equ 4003
IDC_TBB_GOTO					equ 4101
IDC_TBB_EXIT					equ 4007

CL_STAT_OPENED equ 0
CL_STAT_CLOSED equ 1
CL_STAT_SAVED equ 2
CL_STAT_OPEN equ 4

tbrbtns TBBUTTON <7,IDC_TBB_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
		TBBUTTON <8,IDC_TBB_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
		TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
		TBBUTTON <16,IDC_TBB_GOTO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
		TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
	    TBBUTTON <5,IDC_TBB_EXIT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>

.data
clPreName db "> - "
clAppName db  "CoolHex v0.11", 0
clClassName db "SimpleWinClass",0
clTreeViewClass db "SysTreeView32", 0
clListViewClass db "Static", 0
clToolBarClass db "ToolbarWindow32",0
clEditClass db "SUPEREDITCLASS", 0
clEditSimple db "Edit", 0
clScrollClass db "SCROLLBAR", 0

clFontName db "Terminal", 0

clBeginStat db "File <", 0
clHasBeen db "> has been ", 0, 0, 0, 0, 0, 0, 0
clOpened db "opened.", 0
clClosed db "closed.", 0
clSaved db "saved.", 0, 0

clStatOpenSmall db "Loading file.. It may take a few seconds.", 0

clST_Restore db "Restore", 0
clST_Exit db "Exit", 0
clnote NOTIFYICONDATA <>

clError db "CoolHex v0.11: Error", 0
clOpenError db "Couldn't open the file.", 0
clPETestError db "The file is not a Win32 PE file or incorrect.", 0 

clUnhExpectText db "Unhandled expection has been occured. Please contact me: mcl@mail.ru", 0
clMutex db "CoolHex ver 0.11 has been already opened!", 0
clCloseError db "Nothing to close! ;)", 0
clSaveError db "Nothing to save! ;)", 0
clRealSaveError db "Couldn't save the file.", 0
clCloseSave db "File hasn't been saved! Do you want to save this file now?", 0
clTempFile db "~File.ch", 0
clTitle db "CoolHex v0.11: Choose the file",0
clFilterString db "Portable Executables (*.exe;*.dll)",0,"*.exe;*.dll",0,0
clFilterString2 db "All Files (*.*)",0,"*.*",0,0
clPEHeaderString db "PE Header Information", 0
clFileOffsetString db "File Offset", 0
clVAString db "VA", 0
clRVAString db "RVA", 0
clByteString db "Byte:", 0

clLVColum1Caption db "Address", 0
clLVColum1Caption2 db "as ASCII       ", 0
clofn   OPENFILENAME <>

clIncremenetLenth dd 0
clFile db 260 dup(0)
clFile2 db 260 dup(0)
                              
cl_IMAGE_DOS_HEADER db "IMAGE_DOS_HEADER", 0
cl_e_magic db "WORD  e_magic                        0x", 0, 0, 0, 0, 0, 0
cl_e_cblp db "WORD  e_cblp                         0x", 0, 0, 0, 0, 0, 0 
cl_e_cp db "WORD  e_cp                           0x", 0, 0, 0, 0, 0, 0
cl_e_crlc db"WORD  e_crlc                         0x", 0, 0, 0, 0, 0, 0
cl_e_cparhdr db "WORD  e_cparhdr                      0x", 0, 0, 0, 0, 0, 0
cl_e_minalloc db "WORD  e_minalloc                     0x", 0, 0, 0, 0, 0, 0
cl_e_maxalloc db "WORD  e_maxalloc                     0x", 0, 0, 0, 0, 0, 0
cl_e_ss db "WORD  e_ss                           0x", 0, 0, 0, 0, 0, 0
cl_e_sp db "WORD  e_sp                           0x", 0, 0, 0, 0, 0, 0
cl_e_csum db "WORD  e_csum                         0x", 0, 0, 0, 0, 0, 0
cl_e_ip db "WORD  e_ip                           0x", 0, 0, 0, 0, 0, 0
cl_e_cs db "WORD  e_cs                           0x", 0, 0, 0, 0, 0, 0
cl_e_lfarlc db "WORD  e_lfarlc                       0x", 0, 0, 0, 0, 0, 0
cl_e_ovno db "WORD  e_ovno                         0x", 0, 0, 0, 0, 0, 0
cl_e_res db "WORD  e_res[4]", 0
cl_e_res11 db "WORD                      0x", 0, 0, 0, 0, 0, 0
cl_e_oemid db "WORD  e_oemid                        0x", 0, 0, 0, 0, 0, 0
cl_e_oeminfo db "WORD  e_oeminfo                      0x", 0, 0, 0, 0, 0, 0
cl_e_res2 db "WORD  e_res2[10]", 0
cl_e_res21 db "WORD                      0x", 0, 0, 0, 0, 0, 0
cl_e_lfanew db "LONG  e_lfanew                       0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_IMAGE_NT_HEADERS db "IMAGE_NT_HEADERS",0
cl_Signature db "DWORD Signature                      0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_OFFSET_IMAGE_FILE_HEADER db "IMAGE_FILE_HEADER", 0
cl_Machine db "WORD  Machine                        0x", 0, 0, 0, 0, 0, 0
cl_NumberOfSections db "WORD  NumberOfSections               0x", 0, 0, 0, 0, 0, 0
cl_TimeDateStamp db "DWORD TimeDateStamp                  0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_PointerToSymbolTable db "DWORD PointerToSymbolTable           0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_NumberOfSymbols db "DWORD NumberOfSymbols                0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfOptionalHeader db "WORD  SizeOfOptionalHeader           0x", 0, 0, 0, 0, 0, 0
cl_Characteristics db "WORD  Characteristics                0x", 0, 0, 0, 0, 0, 0
cl_IMAGE_OPTIONAL_HEADER32 db "IMAGE_OPTIONAL_HEADER32", 0
cl_Magic db "WORD  Magic                          0x", 0, 0, 0, 0, 0, 0
cl_MajorLinkerVersion db "BYTE  MajorLinkerVersion             0x", 0, 0, 0, 0
cl_MinorLinkerVersion db "BYTE  MinorLinkerVersion             0x", 0, 0, 0, 0
cl_SizeOfCode db "DWORD SizeOfCode                     0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfInitializedData db "DWORD SizeOfInitializedData          0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfUninitializedData db "DWORD SizeOfUninitializedData        0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_AddressOfEntryPoint db "DWORD AddressOfEntryPoint            0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_BaseOfCode db "DWORD BaseOfCode                     0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_BaseOfData db "DWORD BaseOfData                     0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_ImageBase db "DWORD ImageBase                      0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SectionAlignment db "DWORD SectionAlignment               0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_FileAlignment db "DWORD FileAlignment                  0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_MajorOperatingSystemVersion db "WORD  MajorOperatingSystemVersion    0x", 0, 0, 0, 0, 0, 0
cl_MinorOperatingSystemVersion db "WORD  MinorOperatingSystemVersion    0x", 0, 0, 0, 0, 0, 0
cl_MajorImageVersion db "WORD  MajorImageVersion              0x", 0, 0, 0, 0, 0, 0
cl_MinorImageVersion db "WORD  MinorImageVersion              0x", 0, 0, 0, 0, 0, 0
cl_MajorSubsystemVersion db "WORD  MajorSubsystemVersion          0x", 0, 0, 0, 0, 0, 0
cl_MinorSubsystemVersion db "WORD  MinorSubsystemVersion          0x", 0, 0, 0, 0, 0, 0
cl_Win32VersionValue db "DWORD Win32VersionValue              0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfImage db "DWORD SizeOfImage                    0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfHeaders db "DWORD SizeOfHeaders                  0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_CheckSum db "DWORD CheckSum                       0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_Subsystem db "WORD  Subsystem                      0x", 0, 0, 0, 0, 0, 0
cl_DllCharacteristics db "WORD  DllCharacteristics             0x", 0, 0, 0, 0, 0, 0
cl_SizeOfStackReserve db "DWORD SizeOfStackReserve             0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfStackCommit db "DWORD SizeOfStackCommit              0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfHeapReserve db "DWORD SizeOfHeapReserve              0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfHeapCommit db "DWORD SizeOfHeapCommit               0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_LoaderFlags db "DWORD LoaderFlags                    0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_NumberOfRvaAndSizes db "DWORD NumberOfRvaAndSizes            0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_DataDirectory db "IMAGE_DATA_DIRECTORY DataDirectory[16]", 0
cl_IMAGE_DATA_DIRECTORY db "IMAGE_DATA_DIRECTORY", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_VirtualAddress db "DWORD VirtualAddress                 0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_Size db "DWORD Size                           0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_IMAGE_SECTION_HEADER db "IMAGE_SECTION_HEADER ", 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_Name1 db "BYTE  Name[8]", 0
cl_Name2 db "BYTE                                 0x", 0, 0, 0, 0
cl_union db "Union", 0
cl_PhysicalAddress db "DWORD PhysicalAddress                0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_VirtualSize db "DWORD VirtualSize                    0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_VirtualAddress2 db "DWORD VirtualAddress                 0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_SizeOfRawData db "DWORD SizeOfRawData                  0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_PointerToRawData db "DWORD PointerToRawData               0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_PointerToRelocations db "DWORD PointerToRelocations           0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_PointerToLinenumbers db "DWORD PointerToLinenumbers           0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_NumberOfRelocations db "WORD  NumberOfRelocations            0x", 0, 0, 0, 0, 0, 0
cl_NumberOfLinenumbers db "WORD  NumberOfLinenumbers            0x", 0, 0, 0, 0, 0, 0
cl_Characteristics2 db "DWORD Characteristics                0x", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

cl_EXPORT db " EXPORT", 0, 0, 0, 0, 0, 0, 0
cl_IMPORT db " IMPORT", 0, 0, 0, 0, 0, 0, 0
cl_RESOURCE db " RESOURCE", 0, 0, 0, 0, 0
cl_EXCEPTION db " EXCEPTION", 0, 0, 0, 0
cl_SECURITY db " SECURITY", 0, 0, 0, 0, 0
cl_BASERELOC db " BASERELOC", 0, 0, 0, 0
cl_DEBUG db " DEBUG", 0, 0, 0, 0, 0, 0, 0, 0
cl_COPYRIGHT db " COPYRIGHT", 0, 0, 0, 0
cl_GLOBALPTR db " GLOBALPTR", 0, 0, 0, 0
cl_TLS db " TLS", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_LOAD_LIBRARY db " LOAD_LIBRARY", 0 
cl_BOUND_IMPORT db " BOUND_IMPORT", 0 
cl_IAT db " IAT", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cl_UNUSED1 db " UNUSED", 0, 0, 0, 0, 0, 0, 0
cl_UNUSED2 db " UNUSED", 0, 0, 0, 0, 0, 0, 0
cl_UNUSED3 db " UNUSED", 0, 0, 0, 0, 0, 0, 0

.data?
clhInstance dd ?
clCommandLine dd ?
clMainWindowHandle dd ?
clhDragImageList dd ?
clStaticForTreeViewHandle dd ?
clFastPanelHandle dd ?
clTreeViewHandle dd ?
clListViewHandle dd ?
clScrollForListViewHandle dd ?
clStatusWindowHandle dd ?
clToolBarHandle dd ?
clSTPopupMenuHandle dd ?

clFPFileOffsetHandle dd ?
clFPVAHandle dd ?
clFPRVAHandle dd ?
clFPByteHandle dd ?

clGTWindowHwnd dd ?

clGThwndEdit dd ?
clCBHandle dd ?
clGTOldEditProc dd ?

clMainIcon dd ?

clTempString db 290 dup(?)
clOneMoreString db 270 dup(?)

clSizeOfFile dd ?
clSizeOfFile2 dd ?

cllpMappedFile dd ?

clFileSaved db ?
clFileOpened db ?
clGTDialogOpened db ?
clADialogOpened db ?

clFileOffset dd ?
clFileOffsetTemp dd ?

clPosition dd ?

clGTEditText  db 10h dup (?)

clGlobalRect RECT <>

clByteW dd ?
clByteH dd ?

clSizeOf_clChangedBytesBuf dd ?
clChangedBytesBuf dd 100h dup (?)

.code
start:
push offset clUnhExpect
call SetUnhandledExceptionFilter
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
xor eax,eax
invoke CreateMutex,eax,eax,offset clMutex
invoke GetLastError
cmp eax, ERROR_ALREADY_EXISTS
je cl_MEnd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke GetModuleHandle, 0
mov clhInstance,eax
invoke GetCommandLine
mov clCommandLine,eax
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clWinMain, clhInstance, 0, clCommandLine, SW_SHOWDEFAULT

cl_End:
invoke ExitProcess,eax
invoke InitCommonControls 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

clUnhExpect:
invoke MessageBox, clMainWindowHandle, offset clUnhExpectText, offset clError, MB_ICONERROR
mov eax, 1
ret

cl_MEnd:
invoke MessageBox, 0, offset clMutex, offset clAppName,MB_OK
jmp cl_End

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clWinMain proc cl_WM_hInst:DWORD, cl_WM_hPrevInst:DWORD, cl_WM_CmdLine:DWORD, cl_WM_CmdShow:DWORD
LOCAL cl_WM_wc:WNDCLASSEX
LOCAL cl_WM_msg:MSG
LOCAL cl_WM_hwnd:HWND
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_WM_wc.cbSize,SIZEOF WNDCLASSEX
mov cl_WM_wc.style, CS_HREDRAW or CS_VREDRAW
mov cl_WM_wc.lpfnWndProc, OFFSET clWndProc
mov cl_WM_wc.cbClsExtra, 0
mov cl_WM_wc.cbWndExtra, 0
push  clhInstance
pop cl_WM_wc.hInstance
mov cl_WM_wc.hbrBackground, COLOR_APPWORKSPACE 
mov cl_WM_wc.lpszMenuName, IDM_MNU
mov cl_WM_wc.lpszClassName, offset clClassName
invoke LoadIcon, cl_WM_hInst, MAIN_ICO
mov cl_WM_wc.hIcon,eax
invoke LoadIcon, cl_WM_hInst, ICO2
mov clMainIcon, eax
mov cl_WM_wc.hIconSm, eax
invoke LoadCursor, 0,IDC_ARROW
mov cl_WM_wc.hCursor,eax
invoke RegisterClassEx, addr cl_WM_wc
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
INVOKE CreateWindowEx, 0, addr clClassName, addr clAppName,\
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,\
           CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,\
           0, 0,\
           cl_WM_hInst, 0

mov   cl_WM_hwnd,eax
	invoke ShowWindow, cl_WM_hwnd, SW_SHOWMAXIMIZED
	invoke UpdateWindow, cl_WM_hwnd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.WHILE TRUE
    invoke GetMessage, ADDR cl_WM_msg,NULL,0,0
.BREAK .IF (!eax)
    invoke TranslateMessage, ADDR cl_WM_msg
    invoke DispatchMessage, ADDR cl_WM_msg
.ENDW

mov eax, cl_WM_msg.wParam
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clWinMain endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clWndProc proc cl_WP_hWnd:HWND, cl_WP_uMsg:UINT, cl_WP_wParam:WPARAM, cl_WP_lParam:LPARAM
LOCAL clwc:WNDCLASSEX
LOCAL cl_WP_MBStat:DWORD
LOCAL cl_WP_tbab:TBADDBITMAP
LOCAL cl_WP_pt:POINT
LOCAL cl_WP_hdc:HDC
LOCAL cl_WP_ps:PAINTSTRUCT
LOCAL cl_WP_LinePaintingFlag:DWORD
LOCAL cl_WP_NULL:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.IF cl_WP_uMsg==WM_DESTROY
    invoke PostQuitMessage, 0

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_CLOSE   
    cmp clFileOpened, 0
    jz cl_WP_Destroy
    
    call cl_WP_pCP_CloseFile
	cmp cl_WP_MBStat, 2
	je cl_WP_End
	
	cl_WP_Destroy:
	invoke DestroyWindow, cl_WP_hWnd
	
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_CREATE
	push cl_WP_hWnd
	pop clMainWindowHandle
	invoke CreateStatusWindow,WS_CHILD+WS_VISIBLE, 0, cl_WP_hWnd, 2
		
	mov clStatusWindowHandle, eax
	
	invoke CreateWindowEx,0,addr clToolBarClass,0,WS_CHILD or\
			WS_VISIBLE or TBSTYLE_FLAT,0,0,0,0,cl_WP_hWnd,CH_TOOLBAR,clhInstance,0
	
	mov clToolBarHandle,eax

	invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE+SS_SUNKEN+SS_ETCHEDFRAME, 0, 0, 0, 0, cl_WP_hWnd, 0, clhInstance, 0
            	
	mov clStaticForTreeViewHandle, eax            	
    
    invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE+SS_SUNKEN+SS_ETCHEDFRAME, 0, 0, 0, 0, cl_WP_hWnd, 0, clhInstance, 0
            	       
    mov clFastPanelHandle, eax          	        	

    invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE+SS_SUNKEN+SS_ETCHEDFRAME, 0, 25, 365, 25, cl_WP_hWnd, 0, clhInstance, 0               
  	   	    
	invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE+SS_CENTER, 5, 4, 353, 15, eax, 0, clhInstance, 0
            
	invoke SetWindowText, eax, addr clPEHeaderString
	
	invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE, 5, 4, 80, 15, clFastPanelHandle, 0, clhInstance, 0
            
	invoke SetWindowText, eax, addr clFileOffsetString
	
	invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE, 187, 4, 80, 15, clFastPanelHandle, 0, clhInstance, 0
            
	invoke SetWindowText, eax, addr clVAString
	
	invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE, 369, 4, 80, 15, clFastPanelHandle, 0, clhInstance, 0
            
	invoke SetWindowText, eax, addr clRVAString	
      				 
	invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE, 551, 4, 40, 15, clFastPanelHandle, 0, clhInstance, 0
            
	invoke SetWindowText, eax, addr clByteString	
  
    mov clwc.cbSize,sizeof WNDCLASSEX
    invoke GetClassInfoEx, 0,addr clEditSimple,addr clwc
    push clwc.lpfnWndProc
    pop clGTOldEditProc
    mov clwc.lpfnWndProc, offset clGTEditProc

    push clhInstance
    pop clwc.hInstance
    mov clwc.lpszClassName, offset clEditClass
    
    invoke RegisterClassEx, addr clwc
   			
	invoke CreateWindowEx, 0, addr clEditClass, 0, \
            WS_CHILD+WS_VISIBLE, 96, 4, 80, 15, clFastPanelHandle, 0, clhInstance, 0            	
	
	mov clFPFileOffsetHandle, eax
	
	invoke CreateWindowEx, 0, addr clEditClass, 0, \
            WS_CHILD+WS_VISIBLE, 278, 4, 80, 15, clFastPanelHandle, 0, clhInstance, 0  
	
	mov clFPVAHandle, eax
	
	invoke CreateWindowEx, 0, addr clEditClass, 0, \
            WS_CHILD+WS_VISIBLE, 460, 4, 80, 15, clFastPanelHandle, 0, clhInstance, 0                  
    
    mov clFPRVAHandle, eax
    
    invoke CreateWindowEx, 0, addr clEditClass, 0, \
            WS_CHILD+WS_VISIBLE, 597, 4, 37, 15, clFastPanelHandle, 0, clhInstance, 0                  
    
    mov clFPByteHandle, eax
    
    invoke CreateWindowEx, 0,ADDR clTreeViewClass, 0,\
     	    WS_CHILD+WS_VISIBLE+TVS_HASLINES+\
            TVS_HASBUTTONS+TVS_LINESATROOT, 0,\
          	25, 355, 480, clStaticForTreeViewHandle,0, clhInstance, 0
	
    mov clTreeViewHandle, eax
	
	invoke CreateWindowEx, 0, addr clListViewClass, 0, \
            WS_CHILD+WS_VISIBLE+SS_SUNKEN+SS_ETCHEDFRAME, 0, 0, 0, 0, cl_WP_hWnd, 0, clhInstance, 0

    mov clListViewHandle, eax
	
	invoke CreateWindowEx, 0, addr clScrollClass, 0, \
            WS_CHILD+SBS_VERT, 0, 0, 13, 200, cl_WP_hWnd, 0, clhInstance, 0
	
	mov clScrollForListViewHandle, eax
	
	invoke SendMessage, clToolBarHandle, TB_BUTTONSTRUCTSIZE,SIZEOF TBBUTTON,0
	
	push	HINST_COMMCTRL
	pop		cl_WP_tbab.hInst
	mov		cl_WP_tbab.nID, 2
	invoke SendMessage, clToolBarHandle, TB_ADDBITMAP, 15, addr cl_WP_tbab
	mov		cl_WP_tbab.nID, 8
	invoke SendMessage, clToolBarHandle, TB_ADDBITMAP, 1, addr cl_WP_tbab
	invoke SendMessage, clToolBarHandle, TB_ADDBUTTONS, 6, addr tbrbtns
	
    invoke CreatePopupMenu
    mov clSTPopupMenuHandle,eax

    invoke AppendMenu,clSTPopupMenuHandle,MF_STRING,IDM_ST_RESTORE,addr clST_Restore
    invoke AppendMenu,clSTPopupMenuHandle,MF_SEPARATOR,IDM_ST_RESTORE,addr clST_Restore
    invoke AppendMenu,clSTPopupMenuHandle,MF_STRING,IDM_ST_EXIT,addr clST_Exit
	
	invoke RegisterHotKey, cl_WP_hWnd, IDM_Open,MOD_SHIFT+MOD_ALT,VK_O
	invoke RegisterHotKey, cl_WP_hWnd, IDM_Save,MOD_SHIFT+MOD_ALT,VK_S
	invoke RegisterHotKey, cl_WP_hWnd, IDM_SaveAs,MOD_SHIFT+MOD_CONTROL,VK_S
	invoke RegisterHotKey, cl_WP_hWnd, IDM_Close,MOD_SHIFT+MOD_ALT,VK_C
	invoke RegisterHotKey, cl_WP_hWnd, IDM_Exit,MOD_SHIFT+MOD_ALT,VK_Q
	invoke RegisterHotKey, cl_WP_hWnd, IDM_GOTO,MOD_SHIFT+MOD_ALT,VK_G
	
	mov clFileOffset, offset clFile
	mov clFileOffsetTemp, offset clFile2
	mov cl_WP_NULL, 0
	mov cl_WP_LinePaintingFlag, 0
	mov clPosition, 0
	
	mov clofn.lStructSize,SIZEOF clofn
	push cl_WP_hWnd
	pop  clofn.hWndOwner
	push clhInstance
	pop  clofn.hInstance
	mov  clofn.lpstrFilter, offset clFilterString
	mov  clofn.lpstrFile, offset clFile
	mov  clofn.nMaxFile, 260
	mov  clofn.Flags, OFN_FILEMUSTEXIST or \
    	              OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
        	          OFN_EXPLORER or OFN_HIDEREADONLY
	mov  clofn.lpstrTitle, OFFSET clTitle
    mov eax, clCommandLine
    xor ecx, ecx
    mov cl, 0ffh
        
    cl_FindStrParams:
    cmp byte ptr [eax], "/"
    jz cl_WP_FOK
    
    inc eax
    loop cl_FindStrParams 
    
    jmp cl_WP_End
    
    cl_WP_FOK:
    cmp dword ptr [eax+1], "elif"
    jnz cl_WP_End
    
    add eax, 6
    mov clFileOffset, eax
    
    call cl_WP_pOP_Open
    
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_PAINT
	invoke BeginPaint,cl_WP_hWnd, ADDR cl_WP_ps
	mov cl_WP_hdc,eax

	invoke GetSysColor,COLOR_ACTIVEBORDER
	mov ebx, 0FFFFFFh
	xor edx, edx
	invoke clPaintContent, cllpMappedFile, clPosition, cl_WP_hdc, addr clFontName, edx, ebx, cl_WP_LinePaintingFlag, eax, eax
    cl_WP_LVPaintEnd: 
    invoke GetSysColor,COLOR_ACTIVEBORDER
    invoke CreatePen, PS_SOLID, 4, eax 
    invoke SelectObject,cl_WP_hdc, eax
    invoke GetClientRect, cl_WP_hWnd, addr clGlobalRect
    sub clGlobalRect.bottom, 24
    invoke MoveToEx, cl_WP_hdc, 373, clGlobalRect.bottom, 0
    invoke LineTo, cl_WP_hdc, clGlobalRect.right, clGlobalRect.bottom     
    invoke EndPaint,cl_WP_hWnd, ADDR cl_WP_ps

	invoke DefWindowProc, cl_WP_hWnd, cl_WP_uMsg, cl_WP_wParam, cl_WP_lParam	
		
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_VSCROLL
	cl_WP_WM_VSCROLL:
	invoke GetScrollPos, clScrollForListViewHandle, SB_CTL
	mov ebx, eax
		
	cmp clFileOpened, 0
	je cl_WP_End
	
	mov eax, cl_WP_wParam
	and eax, 0ffffh
	
	cl_WP_VS_SB_PAGEUP:
	cmp eax, SB_PAGEUP
	jne cl_WP_VS_SB_PAGEDOWN
	
	sub ebx, 10
	jae cl_WP_EndOfVS
	
	xor ebx, ebx
	
	cl_WP_VS_SB_PAGEDOWN:
	cmp eax, SB_PAGEDOWN
	jne cl_WP_VS_SB_LINEUP
	
	add ebx, 10
	mov edx, clSizeOfFile
	shr edx, 4
	sub edx, 1h
	cmp ebx, edx
	jb cl_WP_EndOfVS	
		
	cl_WP_VS_SB_PAGEDOWN_BSoF:
	mov ebx, clSizeOfFile
	shr ebx, 4
	sub ebx, 1h
				
	cl_WP_VS_SB_LINEUP:
	cmp eax, SB_LINEUP
	jne cl_WP_VS_SB_LINEDOWN
	
	sub ebx, 1
	jae cl_WP_EndOfVS
	
	xor ebx, ebx
		
	cl_WP_VS_SB_LINEDOWN:
	cmp eax, SB_LINEDOWN
	jne cl_WP_VS_SB_TOP
	
	inc ebx
	mov edx, clSizeOfFile
	shr edx, 4
	sub edx, 1h
	cmp ebx, edx
	jb cl_WP_EndOfVS	
		
	cl_WP_VS_SB_LINEDOWN_BSoF:
	mov ebx, clSizeOfFile
	shr ebx, 4
	sub ebx, 1h
			
	cl_WP_VS_SB_TOP:
	cmp eax, SB_TOP
	jne cl_WP_VS_SB_BOTTOM		
	
	xor ebx, ebx
	
	cl_WP_VS_SB_BOTTOM:
	cmp eax, SB_BOTTOM
	jne cl_WP_VS_SB_THUMBTRACK
	
	mov ebx, clSizeOfFile
	shr ebx, 4
	sub ebx, 1h
		
	cl_WP_VS_SB_THUMBTRACK:
	cmp eax, SB_THUMBTRACK
	jne cl_WP_EndOfVS
	
	mov ebx, cl_WP_wParam
	shr ebx, 10h

	cl_WP_EndOfVS:
	mov clPosition, ebx
	
	cl_WP_SetFastPanelNfo:
	call clSetFastPanelInfo
	invoke SetScrollPos, clScrollForListViewHandle, SB_CTL, clPosition, 1
	invoke clInvalidateContent
	invoke SetFocus, cl_WP_hWnd
		
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_SIZE
	cmp cl_WP_wParam,SIZE_MINIMIZED
    jnz cl_WP_StatNotMinimized

    mov clnote.cbSize,sizeof NOTIFYICONDATA
    push cl_WP_hWnd
    pop clnote.hwnd
    mov clnote.uID,IDI_TRAY
    mov clnote.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP
    mov clnote.uCallbackMessage,WM_SHELLNOTIFY
    push clMainIcon
    pop clnote.hIcon
    mov esi, offset clAppName
    mov edi, offset clnote.szTip
    
    cl_WP_CopyAppName2ToolTip:
    mov al, [esi]
    cmp al, 0
    jz cl_WP_NotifyIcon
    
    mov [edi], al
    inc esi
    inc edi
    jmp cl_WP_CopyAppName2ToolTip
    
    cl_WP_NotifyIcon:
    invoke ShowWindow,cl_WP_hWnd,SW_HIDE
    invoke Shell_NotifyIcon,NIM_ADD,addr clnote
        
    cl_WP_StatNotMinimized:
	mov eax, cl_WP_lParam
	and eax, 0FFFFh
	sub eax, 368
	invoke MoveWindow, clFastPanelHandle, 368, 25, eax, 25, 1  
	invoke MoveWindow, clStatusWindowHandle, 0, 0, 0, 0, 1 
	mov eax, cl_WP_lParam
	shr eax, 16
	sub eax, 70
	invoke MoveWindow, clStaticForTreeViewHandle, 0, 50, 365, eax, 1 ;3param +25
	mov eax, cl_WP_lParam
	shr eax, 16
	sub eax, 82 ; +25
	invoke MoveWindow, clTreeViewHandle, 5, 5, 353, eax, 1
	mov eax, cl_WP_lParam
	and eax, 0FFFFh
	invoke MoveWindow, clToolBarHandle, 0, 0, eax, 0, 1
	mov eax, cl_WP_lParam
	mov ebx, eax
	shr eax, 16
	sub eax, 70 ; +25
	and ebx, 0FFFFh 
	sub ebx, 369
	invoke MoveWindow, clListViewHandle, 368, 50, ebx, eax, 1 ;3param +25
	invoke GetSystemMetrics, SM_CXHSCROLL
	mov edx, cl_WP_lParam
	mov ebx, edx
	shr edx, 16
	sub edx, 81 ; +25
	and ebx, 0FFFFh 
	sub ebx, 6
	sub ebx, eax
	invoke MoveWindow, clScrollForListViewHandle, ebx, 55, eax, edx, 1 ;3param +25
	;invoke SendMessage, cl_WP_hWnd,WM_PAINT, 0, 0
	
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_KEYDOWN
	mov eax, cl_WP_wParam
	xor ebx, ebx
	dec ebx
	
	cl_WP_VS_VK_ENTER:
	cmp eax, VK_RETURN
	jne cl_WP_VS_VK_PRIOR
	
	invoke SetFocus, clFPByteHandle
	mov cl_WP_NULL, 0
	invoke SetWindowText, clFPByteHandle, cl_WP_NULL
	jmp cl_WP_End
	
	cl_WP_VS_VK_PRIOR:
	cmp eax, VK_PRIOR
	jne cl_WP_VS_VK_NEXT
	
	mov ebx, SB_PAGEUP
	
	cl_WP_VS_VK_NEXT:
	cmp eax, VK_NEXT
	jne cl_WP_VS_VK_UP
	
	mov ebx, SB_PAGEDOWN
	
	cl_WP_VS_VK_UP:
	cmp eax, VK_UP
	jne cl_WP_VS_VK_DOWN
	
	mov ebx, SB_LINEUP
		
	cl_WP_VS_VK_DOWN:
	cmp eax, VK_DOWN
	jne cl_WP_VS_VK_END
	
	mov ebx, SB_LINEDOWN
	
	cl_WP_VS_VK_END:
	cmp eax, VK_END
	jne cl_WP_VS_VK_HOME
	
	mov ebx, SB_BOTTOM
	
	cl_WP_VS_VK_HOME:
	cmp eax, VK_HOME
	jne cl_WP_VS_VR_End
	
	mov ebx, SB_TOP
	
	cl_WP_VS_VR_End:
	cmp ebx, -1
	je cl_WP_End
	
	mov cl_WP_wParam, ebx 
	jmp cl_WP_WM_VSCROLL 	 
	
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_HOTKEY
	jmp cl_WP_UnderstandCommand
	
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_COMMAND
	cl_WP_UnderstandCommand:
	mov eax,cl_WP_wParam
	
	cmp ax, IDM_Open
	jne cl_WP_Save
			
			call cl_WP_pOpenProc
			
	jmp cl_WP_End
	
	cl_WP_Save:
	cmp ax, IDM_Save
	jne cl_WP_SaveAs
	
			call cl_WP_pSaveProc
	
	jmp cl_WP_End
	
	cl_WP_SaveAs:
	cmp ax, IDM_SaveAs
	jne cl_WP_Close
			
			call cl_WP_pSaveAsProc
			
	jmp cl_WP_End
	
	cl_WP_Close:
	cmp ax, IDM_Close
	jne cl_WP_Exit
	
			call cl_WP_pCloseProc
			
	jmp cl_WP_End
	
	cl_WP_Exit:
	cmp ax, IDM_Exit
	jne cl_WP_About
			
			invoke SendMessage, cl_WP_hWnd, WM_CLOSE, 0, 0 
			
	cl_WP_About:
	cmp ax, IDM_About
    jne cl_WP_GOTO
		
		cmp clADialogOpened, 0
		jnz cl_WP_End 
		
		mov clADialogOpened, 1
		invoke CreateDialogParam, clhInstance, IDM_DLG9000, cl_WP_hWnd, offset clAboutDlgProc, 0
				
	jmp cl_WP_End
	
	cl_WP_GOTO:
	cmp ax, IDM_GOTO
    jne cl_WP_ST_Commands
		
		cmp clFileOpened, 0
		jz cl_WP_End
		
		cmp clGTDialogOpened, 0
		jnz cl_WP_End 
		
		mov clGTDialogOpened, 1
		invoke CreateDialogParam, clhInstance, IDM_DLG10000, cl_WP_hWnd, offset clGoToDlgProc, 0
		mov clGTWindowHwnd, eax 
		
	jmp cl_WP_End

	cl_WP_ST_Commands:
	cmp cl_WP_lParam, 0
	jne cl_WP_End
	
	invoke Shell_NotifyIcon,NIM_DELETE,addr clnote
    mov eax, cl_WP_wParam
	
	cmp ax, IDM_ST_RESTORE
    jne cl_WP_STCommandExit 
    
    invoke ShowWindow, cl_WP_hWnd,SW_RESTORE
    invoke SetForegroundWindow, cl_WP_hWnd
    jmp cl_WP_End
    
    cl_WP_STCommandExit:
    invoke SendMessage, cl_WP_hWnd, WM_CLOSE, 0, 0 

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_LBUTTONDOWN
	cmp clFileOpened, 0
	jz cl_WP_GettingReadyForRepainting
	
	invoke GetCursorPos, offset clByteW
	invoke GetWindowRect, cl_WP_hWnd, offset clGlobalRect
	invoke GetSystemMetrics, SM_CYCAPTION
	add eax, clGlobalRect.top
	mov ebx, clGlobalRect.left
	add eax, 41
	add ebx, 25 
	sub clByteH, eax
	sub clByteW, ebx
		
	xor eax, eax
	xchg eax, clByteH
	mov edx, 79
	xor ecx, ecx
		
	cl_WP_BedinCheckingSelectedByteH:
	cmp eax, edx
	jb cl_WP_SetByteH 
	
	add dx, 19
	inc ecx
	shl ecx, 8
	cmp ch, 50h
	je cl_WP_SetByteH
	shr ecx, 8 
	jmp cl_WP_BedinCheckingSelectedByteH 
	
	cl_WP_SetByteH:
	mov byte ptr clByteH, cl
	
	xor eax, eax
	xchg eax, clByteW
	mov edx, 465
	xor ecx, ecx
	
	cl_WP_BedinCheckingSelectedByteW:
	cmp eax, edx
	jb cl_WP_SetByteW 
	
	add dx, 23
	inc ecx
	shl ecx, 8
	cmp ch, 10h
	je cl_WP_SetByteW
	shr ecx, 8 
	jmp cl_WP_BedinCheckingSelectedByteW 
	
	cl_WP_SetByteW:
	mov byte ptr clByteW, cl
	call clSetFastPanelInfo
	
	cl_WP_GettingReadyForRepainting:
	invoke GetClientRect, cl_WP_hWnd, addr clGlobalRect
	mov clGlobalRect.top, 50
	mov clGlobalRect.left, 374
	sub clGlobalRect.bottom, 25
	invoke GetSystemMetrics,SM_CXVSCROLL
	add eax, 6
	sub clGlobalRect.right, eax
	invoke InvalidateRect, cl_WP_hWnd, addr clGlobalRect, 0
	invoke SetFocus, cl_WP_hWnd
	    
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSEIF cl_WP_uMsg==WM_SHELLNOTIFY
	cmp cl_WP_wParam, IDI_TRAY
	jne cl_WP_End
	
	cmp cl_WP_lParam, WM_RBUTTONDOWN
	jne cl_WP_WindowRestore
	
	invoke GetCursorPos,addr cl_WP_pt
	invoke SetForegroundWindow,cl_WP_hWnd
	invoke TrackPopupMenu,clSTPopupMenuHandle,TPM_RIGHTALIGN or TPM_RIGHTBUTTON,cl_WP_pt.x,cl_WP_pt.y, 0,cl_WP_hWnd, 0
	invoke PostMessage,cl_WP_hWnd,WM_NULL,0,0
	jmp cl_WP_End
	
	cl_WP_WindowRestore:
	cmp cl_WP_lParam, WM_LBUTTONDBLCLK
	jne cl_WP_End
	
	invoke SendMessage,cl_WP_hWnd,WM_COMMAND,IDM_ST_RESTORE,0
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ELSE
    invoke DefWindowProc, cl_WP_hWnd, cl_WP_uMsg, cl_WP_wParam, cl_WP_lParam		
    ret
    
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.ENDIF

cl_WP_End:
xor eax,eax
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_WP_pOpenProc:
cmp clFileOpened, 0
jz cl_WP_Dialog

call cl_WP_pCloseProc
cmp cl_WP_MBStat, 2
je cl_WP_pOP_End 

cl_WP_Dialog:
mov clFileSaved, 1
invoke GetOpenFileName, addr clofn
cmp eax, 1
jne cl_WP_pOP_End

cl_WP_pOP_Open:
invoke clSetStatus, clStatusWindowHandle, CL_STAT_OPEN

invoke UpdateWindow, cl_WP_hWnd
invoke DeleteFile, offset clTempFile
invoke clOpenIncrementFile, clFileOffset, offset clTempFile, addr clSizeOfFile, 0h, 3h, 1h    
test eax, eax
jnz cl_WP_pOP_PET

cl_WP_pOP_OpenError:
invoke DeleteFile, offset clTempFile
invoke MessageBox, cl_WP_hWnd, offset clOpenError, offset clError, MB_ICONERROR
invoke clSetStatus, clStatusWindowHandle, CL_STAT_CLOSED
retn

cl_WP_pOP_PET:
mov cllpMappedFile, eax
invoke SetFileAttributesA, offset clTempFile, 2h

invoke clPETest, cllpMappedFile, clSizeOfFile
test eax,eax
jnz cl_WP_pOP_FIT

invoke clCloseFile, cllpMappedFile
invoke DeleteFile, offset clTempFile
invoke MessageBox, cl_WP_hWnd, offset clPETestError, offset clError, MB_ICONERROR
invoke clSetStatus, clStatusWindowHandle, CL_STAT_CLOSED
retn

cl_WP_pOP_FIT:
mov clFileOpened, 1
invoke ShowWindow, clScrollForListViewHandle, SW_SHOW
mov eax, clSizeOfFile
shr eax, 4
sub eax, 1h
invoke SetScrollRange, clScrollForListViewHandle, SB_CTL, 0, eax, 0	
xor eax, eax
mov clPosition, eax
mov clByteH, eax
mov clByteW, eax
call clSetFastPanelInfo
invoke SetScrollPos, clScrollForListViewHandle, SB_CTL, 0, 1
mov clPosition, 0
invoke clFillInformationTree, cllpMappedFile, clTreeViewHandle, clhInstance, offset cl_IMAGE_DOS_HEADER, offset cl_EXPORT         	
mov edi, offset clTempString
mov byte ptr[edi], "<"
inc edi
mov esi, clFileOffset

cl_WP_pOP_Begin:
cmp byte ptr[esi], 0
jz cl_WP_pOP_EndOfStringFound

inc esi
jmp cl_WP_pOP_Begin

cl_WP_pOP_EndOfStringFound:
xor ecx, ecx

cl_WP_pOP_FindName:
cmp byte ptr [esi], "\"
je cl_WP_pOP_NameFound

dec esi
inc ecx
jmp cl_WP_pOP_FindName

cl_WP_pOP_NameFound:
inc esi
dec ecx
cld
rep movsb

mov esi, offset clPreName
; for change [beta]\-  ||   mov ecx, 19h\mov ecx, 12h 
mov ecx, 19h
rep movsb
invoke SetWindowText, cl_WP_hWnd, offset clTempString
invoke clSetStatus, clStatusWindowHandle, CL_STAT_OPENED
invoke GetClientRect, cl_WP_hWnd, addr clGlobalRect
invoke InvalidateRect, cl_WP_hWnd, addr clGlobalRect, 0

cl_WP_pOP_End:
retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_WP_pSaveProc:
cmp clFileOpened, 0
jz cl_WP_pSP_BadEnd

cl_WP_pSP_GetFileToSaveIn:
mov eax, clSizeOfFile
mov clSizeOfFile2, eax

invoke clOpenIncrementFile, clFileOffset, 0, addr clSizeOfFile, clIncremenetLenth, 4h, 1
cmp eax, 0
jnz cl_WP_pSP_SavingTheFile

cl_WP_pSP_RSE:
invoke MessageBox, cl_WP_hWnd, offset clRealSaveError, offset clError, MB_ICONERROR
xor eax, eax
retn

cl_WP_pSP_SavingTheFile:
mov ecx, clSizeOfFile
cmp ecx, clSizeOfFile2
je cl_WP_pSP_Copy
ja cl_WP_pSP_DecreaseFile

sub clSizeOfFile2, ecx
mov bl, 1
jmp cl_WP_pSP_IncDecFile

cl_WP_pSP_DecreaseFile:
mov bl, 0
sub ecx, clSizeOfFile2
mov clSizeOfFile2, ecx

cl_WP_pSP_IncDecFile:
invoke clCloseFile,eax 
invoke clOpenIncrementFile, clFileOffset, 0, addr clSizeOfFile, clSizeOfFile2, 3h, bl
cmp eax, 0
jz cl_WP_pSP_RSE
 
mov ecx, clSizeOfFile
sub ecx, clIncremenetLenth
add ecx, clSizeOfFile2

cl_WP_pSP_Copy:
add ecx, clIncremenetLenth
mov edi, eax
mov esi, cllpMappedFile
cld
rep movsb

invoke clCloseFile,eax 
mov clFileSaved, 1h
invoke clSetStatus, clStatusWindowHandle, CL_STAT_SAVED
jmp cl_WP_pSP_End
 
cl_WP_pSP_BadEnd:
invoke MessageBox, cl_WP_hWnd, offset clSaveError, offset clError, MB_ICONERROR
cl_WP_pSP_End:
mov eax, 1
retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_WP_pSaveAsProc:
cmp clFileOpened, 0h
jz cl_WP_pSP_BadEnd

mov edi, clFileOffset

cl_WP_pSAP_Begin:
cmp byte ptr[edi], 0h
jz cl_WP_pSAP_EndOfStringFound

inc edi
jmp cl_WP_pSAP_Begin

cl_WP_pSAP_EndOfStringFound:
cmp byte ptr[edi], "\"
je cl_WP_pSAP_NameFound

dec edi
jmp cl_WP_pSAP_EndOfStringFound

cl_WP_pSAP_NameFound:
inc edi
sub edi, clFileOffset
mov ecx, edi 
mov esi, clFileOffset
mov edi, offset clOneMoreString
cld
rep movsb

mov ecx, 9h
mov esi, offset clTempFile
rep movsb

mov eax, clFileOffset
xchg eax, clFileOffsetTemp
mov clFileOffset, eax

mov  clofn.lpstrFile, eax

mov  clofn.lpstrFilter, offset clFilterString2

mov  clofn.Flags, OFN_LONGNAMES or\
                  OFN_EXPLORER or OFN_HIDEREADONLY

invoke GetSaveFileName, addr clofn

mov  clofn.Flags, OFN_FILEMUSTEXIST or \
                  OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                  OFN_EXPLORER or OFN_HIDEREADONLY

mov  clofn.lpstrFilter, offset clFilterString

cmp eax, 0
jz cl_WP_pSAP_BadEnd

mov clFileSaved, 1


call cl_WP_pSP_GetFileToSaveIn
cmp eax, 0
jne cl_WP_pSAP_CloseAndOpenNew

cl_WP_pSAP_BadEnd:
mov eax, clFileOffset
xchg eax, clFileOffsetTemp
mov clFileOffset, eax

mov  clofn.lpstrFile, eax
retn

cl_WP_pSAP_CloseAndOpenNew:
call cl_WP_pCP_RealCloseFile
invoke DeleteFile, offset clOneMoreString
call cl_WP_pOP_Open

invoke clSetStatus, clStatusWindowHandle, CL_STAT_SAVED

cl_WP_pSAP_End:
retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_WP_pCloseProc:
cmp clFileOpened, 0
jnz cl_WP_pCP_CloseFile

invoke MessageBox, cl_WP_hWnd, offset clCloseError, offset clError, MB_ICONERROR
retn

cl_WP_pCP_CloseFile:
cmp clFileSaved, 0
jnz cl_WP_pCP_RealCloseFile

invoke MessageBox, cl_WP_hWnd, offset clCloseSave, offset clAppName, MB_YESNOCANCEL+40h
mov cl_WP_MBStat, eax
cmp eax, 6
jb cl_WP_pCP_End
ja cl_WP_pCP_RealCloseFile 

call cl_WP_pSaveProc

cl_WP_pCP_RealCloseFile:
invoke SendMessage, clTreeViewHandle, TVM_DELETEITEM, 0, TVI_ROOT
invoke SetWindowText, clFPFileOffsetHandle, 0
invoke SetWindowText, clFPVAHandle, 0
invoke SetWindowText, clFPRVAHandle, 0
invoke SetWindowText, clFPByteHandle, 0
invoke ShowWindow, clScrollForListViewHandle, SW_HIDE
invoke clCloseFile, cllpMappedFile
invoke DeleteFile, offset clTempFile
invoke clSetStatus, clStatusWindowHandle, CL_STAT_CLOSED
invoke SetWindowText, cl_WP_hWnd, offset clAppName
mov clFileOpened, 0
mov clPosition, 0
mov clByteH, 0
mov clByteW, 0
cmp clGTDialogOpened, 0
jz cl_cl_WP_pCP_GetRect

invoke EndDialog, clGTWindowHwnd, 0
mov clGTDialogOpened, 0

cl_cl_WP_pCP_GetRect:
invoke GetClientRect, cl_WP_hWnd, addr clGlobalRect
invoke InvalidateRect, cl_WP_hWnd, addr clGlobalRect, 0
cl_WP_pCP_End:
retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clWndProc endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clAboutDlgProc proc cl_ADP_hWnd:HWND, cl_ADP_uMsg:UINT, cl_ADP_wParam:WPARAM, cl_ADP_lParam:LPARAM
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.if cl_ADP_uMsg==WM_INITDIALOG
	xor eax, eax
	inc eax		

.elseif cl_ADP_uMsg==WM_COMMAND
	jmp cl_ADP_DialogEnd	

.elseif cl_ADP_uMsg==WM_CLOSE
	cl_ADP_DialogEnd:
	mov clADialogOpened, 0
	invoke EndDialog, cl_ADP_hWnd, 0
	
.else
xor eax, eax
ret 
.endif

xor eax, eax
inc eax
ret 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clAboutDlgProc endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clGoToDlgProc proc cl_GTDP_hWnd:HWND, cl_GTDP_uMsg:UINT, cl_GTDP_wParam:WPARAM, cl_GTDP_lParam:LPARAM
LOCAL cl_GTDP_NewPos:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.if cl_GTDP_uMsg==WM_INITDIALOG
	invoke GetDlgItem, cl_GTDP_hWnd,IDC_COMBOBOX10013
	mov clCBHandle, eax
	invoke SendMessage, eax, CB_ADDSTRING, 0, addr clFileOffsetString
	invoke SendMessage, clCBHandle, CB_ADDSTRING, 0, addr clVAString
	invoke SendMessage, clCBHandle, CB_ADDSTRING, 0, addr clRVAString
	invoke SendMessage, clCBHandle, CB_SETCURSEL, 0, 0	
	invoke GetDlgItem, cl_GTDP_hWnd,IDC_EDIT10009
	mov clGThwndEdit, eax
	invoke SetFocus,eax
	mov esi, offset clPosition
	mov edi, [esi]
	mov eax, clByteH
	add [esi], eax
	shl dword ptr [esi], 4
	mov eax, clByteW
	add [esi], eax
	invoke clRealASCII, addr clPosition, addr clGTEditText, 4  
	mov [esi], edi
	INVOKE SetWindowText, clGThwndEdit, addr clGTEditText
	invoke SetWindowLong, clGThwndEdit, GWL_WNDPROC, clGTEditProc
	mov	clGTOldEditProc, eax
	
.elseif cl_GTDP_uMsg==WM_COMMAND
	mov eax, cl_GTDP_wParam
	cmp eax, IDM_GT_OK
	jne cl_GTDP_CANCEL 
	
	invoke SendMessage, clGThwndEdit, WM_KEYDOWN, VK_RETURN, 0
	
	cl_GTDP_CANCEL:
	cmp eax, IDM_GT_CANCEL
	je cl_GTDP_DialogEnd
			
.elseif cl_GTDP_uMsg==WM_CLOSE
	cl_GTDP_DialogEnd:
	mov clGTDialogOpened, 0
	invoke EndDialog, cl_GTDP_hWnd, 0

.else
xor eax, eax
ret 
.endif

cl_GTDP_End:
xor eax, eax
inc eax
ret 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clGoToDlgProc endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clGTEditProc PROC cl_GTEP_hEdit:DWORD,cl_GTEP_uMsg:DWORD,cl_GTEP_wParam:DWORD,cl_GTEP_lParam:DWORD
LOCAL cl_GTEP_NewPos:DWORD
LOCAL cl_GTEP_Null:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.if cl_GTEP_uMsg==WM_PASTE
.elseif cl_GTEP_uMsg==WM_CHAR
	cmp clFileOpened, 0
	jz cl_GTEP_End
	
	mov eax,cl_GTEP_wParam
    .if (al>="0" && al<="9") || (al>="A" && al<="F") || (al>="a" && al<="f") || al==VK_BACK
		invoke GetWindowText, cl_GTEP_hEdit,addr clGTEditText, 10h
		invoke lstrlen, addr clGTEditText
		.if al<=7 || cl_GTEP_wParam==VK_BACK
		mov ebx, clFPByteHandle
		cmp ebx, cl_GTEP_hEdit
		jnz cl_GTEP_CallProc
		
		cmp cl_GTEP_wParam, VK_BACK
		jne cl_GTEP_AL2
		
		cmp al, 0
		jnz cl_GTEP_CallProc
		
		dec clByteW
		cmp clByteW, -1
		jne cl_GTEP_Invalidate2
		
		and clByteW, 0fh				
		cmp clByteH, 0
		jz cl_GTEP_DecPosition
		
		dec clByteH
		jmp cl_GTEP_Invalidate2
		
		cl_GTEP_DecPosition:
		cmp clPosition, 0
		jz cl_GTEP_End
		
		dec clPosition
		jmp cl_GTEP_Invalidate2
		
		cl_GTEP_AL2:
		cmp al, 2
		jb cl_GTEP_CallProc
		
		invoke SendMessage, cl_GTEP_hEdit, WM_KEYDOWN, VK_RETURN, 0
		invoke SetFocus, cl_GTEP_hEdit
		
		inc clByteW
		and clByteW, 0Fh
		mov eax, clPosition
		cmp clByteW, 0h
		jne cl_GTEP_Set_N_Invalidate
		
		inc eax
		shl eax, 4
		mov ebx, clSizeOfFile
		sub ebx, 1Fh
		cmp eax, ebx
		jb cl_GTEP_SetPosition
		
		dec eax
		inc clByteH

		cl_GTEP_SetPosition:
		shr eax, 4
		mov clPosition, eax				
		
		cl_GTEP_Set_N_Invalidate:
		call clSetFastPanelInfo
		mov cl_GTEP_Null, 0
		invoke SetWindowText, cl_GTEP_hEdit, addr cl_GTEP_Null
		jmp cl_GTEP_End
		
		cl_GTEP_CallProc:
		invoke CallWindowProc,clGTOldEditProc,cl_GTEP_hEdit,cl_GTEP_uMsg, cl_GTEP_wParam,cl_GTEP_lParam
    	ret
    	
    	cl_GTEP_Invalidate2:
    	call clInvalidateContent
    	.endif
    .endif
.elseif cl_GTEP_uMsg==WM_KEYDOWN
	mov eax, cl_GTEP_wParam
    .if al==VK_RETURN
		xor eax, eax
		mov edi, offset clGTEditText
		mov [edi], eax
		mov [edi+4], eax
		mov [edi+8], eax
		mov [edi+0Ch], eax
		mov cl_GTEP_NewPos, eax
		
		invoke GetWindowText, cl_GTEP_hEdit,offset clGTEditText, 10h
		invoke clRealHex, offset clGTEditText, addr cl_GTEP_NewPos, 8
		mov ecx, cl_GTEP_hEdit
		cmp ecx, clFPByteHandle
		je cl_GTEP_Byte		
		
		invoke lstrlen, addr clGTEditText
		mov ecx, 8
		sub ecx, eax
		mov eax, cl_GTEP_NewPos
		jz cl_GTEP_EndShr
		
		cl_GTEP_Shr:
		shr eax, 4
		loop cl_GTEP_Shr
	
	 	cl_GTEP_EndShr:
		mov edx, eax
		and edx, 0fh
		mov clByteW, edx
		
		mov ebx, clSizeOfFile
		sub ebx, 1fh

		cl_GTEP_SetScroll:
		mov ecx, cl_GTEP_hEdit
		cmp ecx, clFPFileOffsetHandle
		jz cl_GTEP_EndSetAddr
		
		cl_GTEP_clFPVAHandle:
		cmp ecx, clFPVAHandle
		jnz cl_GTEP_clFPRVAHandle
		
		cl_GTEP_VAAddr:
		invoke clVA2FileOffset, cllpMappedFile, eax
		jmp cl_GTEP_EndSetAddr
		
		cl_GTEP_clFPRVAHandle:
		cmp ecx, clFPRVAHandle
		jnz cl_GTEP_Variant
		
		cl_GTEP_RVAAddr:
		invoke clRVA2FileOffset, cllpMappedFile, eax
			
		cl_GTEP_EndSetAddr:
		mov edx, clByteH
		shl edx, 4
		sub eax, edx
		jnb cl_GTEP_FileSizeCompare
		
		xor eax, eax
		mov clByteH, 0
		
		cl_GTEP_FileSizeCompare:
		mov ebx, clSizeOfFile
		sub ebx, 1fh
		cmp eax, ebx
		jb cl_GTEP_ValidAddress
		
		mov eax, ebx
		
		cl_GTEP_ValidAddress:		
		shr eax, 4
	
		mov clPosition, eax
		
		cl_GTEP_Invalidate:
		invoke clInvalidateContent 
		invoke SetFocus, clMainWindowHandle
		invoke SetScrollPos, clScrollForListViewHandle, SB_CTL, clPosition, 0
						
		cl_GTEP_SetFastPanelNfo:
		call clSetFastPanelInfo
		jmp cl_GTEP_End
		
		cl_GTEP_Byte:
		cmp byte ptr cl_GTEP_NewPos+3, 0
		jz cl_GTEP_Invalidate
		
		mov eax, clPosition
		add eax, clByteH
		shl eax, 4
		add eax, clByteW
		add eax, cllpMappedFile
		mov bl, byte ptr cl_GTEP_NewPos+3
		mov [eax], bl
		mov clFileSaved, 0
		jmp cl_GTEP_Invalidate
		  				
		cl_GTEP_Variant:
		cmp ecx, clGThwndEdit
		jz cl_GTEP_EndSetAddr
;		push eax
;		invoke SendMessage, clCBHandle, CB_GETTOPINDEX, 0, 0
;		mov ebx, eax
;		pop eax 
;		cmp ebx, 0
;		je cl_GTEP_EndSetAddr
;		cmp ebx, 1
;		je cl_GTEP_VAAddr
;		cmp ebx, 2
;		je cl_GTEP_RVAAddr

	.else
		invoke CallWindowProc,clGTOldEditProc,cl_GTEP_hEdit,cl_GTEP_uMsg,cl_GTEP_wParam,cl_GTEP_lParam	
	.endif
.elseif cl_GTEP_uMsg==WM_LBUTTONDOWN
	mov eax, cl_GTEP_hEdit
	cmp eax, clFPByteHandle
	jne cl_GTEP_CallWindowProc
	mov cl_GTEP_Null, 0
	invoke SetWindowText, cl_GTEP_hEdit, addr cl_GTEP_Null
	jmp cl_GTEP_CallWindowProc
.else
	cl_GTEP_CallWindowProc:
    invoke CallWindowProc,clGTOldEditProc,cl_GTEP_hEdit,cl_GTEP_uMsg,cl_GTEP_wParam,cl_GTEP_lParam
    ret
.endif
cl_GTEP_End:
xor eax,eax
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clGTEditProc endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clFillInformationTree proc cl_FIT_lpMappedFile:DWORD, cl_FIT_TreeViewHWND:DWORD, cl_FIT_hInstance:DWORD, cl_FIT_lp_DOS_HEADER_String:DWORD, cl_FIT_lpDirectoryName:DWORD
LOCAL cl_FIT_hImageList:DWORD
LOCAL cl_FIT_hBitmap:DWORD
LOCAL cl_FIT_String:DWORD
LOCAL cl_FIT_Counter:DWORD
LOCAL cl_FIT_hParent_dos_header:DWORD
LOCAL cl_FIT_hParent_res1:DWORD
LOCAL cl_FIT_hParent_res2:DWORD
LOCAL cl_FIT_hParent_nt_headers:DWORD
LOCAL cl_FIT_hParent_file_header:DWORD
LOCAL cl_FIT_hParent_optional_header:DWORD
LOCAL cl_FIT_hParent_data_directory:DWORD
LOCAL cl_FIT_hParent_data_directory2:DWORD
LOCAL cl_FIT_hParent_section_header:DWORD
LOCAL cl_FIT_hParent_name:DWORD
LOCAL cl_FIT_hParent_union:DWORD
LOCAL cl_FIT_SectionCounter:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke ImageList_Create, 10h, 10h, ILC_COLOR16, 2, 0Ah 
mov cl_FIT_hImageList,eax 
invoke LoadBitmap, cl_FIT_hInstance, IDB_TREE
mov cl_FIT_hBitmap,eax 
invoke ImageList_Add, cl_FIT_hImageList,cl_FIT_hBitmap, 0
invoke DeleteObject, cl_FIT_hBitmap  
invoke SendMessage,cl_FIT_TreeViewHWND,TVM_SETIMAGELIST,0,cl_FIT_hImageList 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov edi, cl_FIT_lp_DOS_HEADER_String 
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, 0, TVI_ROOT   
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_hParent_dos_header, eax
add edi, 11h
mov cl_FIT_Counter, 0Eh

cl_FIT_FirstAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_dos_header, TVI_LAST  
add cl_FIT_lpMappedFile, 2h
add edi, 6h
dec cl_FIT_Counter
jnz cl_FIT_FirstAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, cl_FIT_hParent_dos_header, TVI_ROOT 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 4h
mov cl_FIT_hParent_res1, eax 
add edi, 0Fh
mov cl_FIT_String, edi
add edi, 1Ch 

cl_FIT_SecondAdd:

call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_res1, TVI_LAST  
mov byte ptr[edi+4], 0
add cl_FIT_lpMappedFile, 2h
dec  cl_FIT_Counter
jnz cl_FIT_SecondAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 2h
add edi, 6h

cl_FIT_ThirdAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_dos_header, TVI_LAST
add cl_FIT_lpMappedFile, 2h
add edi, 6h
dec cl_FIT_Counter
jnz cl_FIT_ThirdAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, cl_FIT_hParent_dos_header, TVI_ROOT
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 0Ah
mov cl_FIT_hParent_res2, eax 
add edi, 11h
mov cl_FIT_String, edi
add edi, 1Ch

cl_FIT_FourthAdd:
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_res2, TVI_LAST
mov byte ptr [edi+4], 0
add cl_FIT_lpMappedFile, 2h
dec cl_FIT_Counter
jnz cl_FIT_FourthAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
add edi, 6h
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_dos_header, TVI_LAST
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
add edi, 0Ah
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, 0, TVI_ROOT
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_hParent_nt_headers, eax
add edi, 11h
mov cl_FIT_String, edi
add edi, 27h
mov eax, cl_FIT_lpMappedFile
mov eax, [eax]
sub eax, 3ch
add cl_FIT_lpMappedFile, eax
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_nt_headers, TVI_LAST
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
add edi, 0Ah
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, cl_FIT_hParent_nt_headers, TVI_ROOT
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 2
mov cl_FIT_hParent_file_header, eax
add cl_FIT_lpMappedFile, 4
add edi, 12h
mov eax, cl_FIT_lpMappedFile
mov ax, [eax+2]
and eax, 0FFFFh
mov cl_FIT_SectionCounter, eax

cl_FIT_FifthAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_file_header, TVI_LAST
add cl_FIT_lpMappedFile, 2
add edi, 6h
dec cl_FIT_Counter
jnz cl_FIT_FifthAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 3h

cl_FIT_SixthAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_file_header, TVI_LAST
add cl_FIT_lpMappedFile, 4
add edi, 0Ah
dec cl_FIT_Counter
jnz cl_FIT_SixthAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 2h

cl_FIT_SeventhAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_file_header, TVI_LAST
add cl_FIT_lpMappedFile, 2
add edi, 6h
dec cl_FIT_Counter
jnz cl_FIT_SeventhAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, cl_FIT_hParent_nt_headers, TVI_ROOT
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_hParent_optional_header, eax
add edi, 18h
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_optional_header, TVI_LAST
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 2h
add cl_FIT_lpMappedFile, 2
add edi, 6h

cl_FIT_EighthAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertByte
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_optional_header, TVI_LAST
inc cl_FIT_lpMappedFile
add edi, 4h
dec cl_FIT_Counter
jnz cl_FIT_EighthAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 9h

cl_FIT_NinthAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_optional_header, TVI_LAST
add cl_FIT_lpMappedFile, 4
add edi, 0Ah
dec cl_FIT_Counter
jnz cl_FIT_NinthAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 6h

cl_FIT_TenthAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_optional_header, TVI_LAST
add cl_FIT_lpMappedFile, 2
add edi, 6h
dec cl_FIT_Counter
jnz cl_FIT_TenthAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 4h

cl_FIT_EleventhAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_optional_header, TVI_LAST
add cl_FIT_lpMappedFile, 4
add edi, 0Ah
dec cl_FIT_Counter
jnz cl_FIT_EleventhAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 2h

cl_FIT_TwelfthAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_optional_header, TVI_LAST
add cl_FIT_lpMappedFile, 2
add edi, 6h
dec cl_FIT_Counter
jnz cl_FIT_TwelfthAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_FIT_Counter, 6h

cl_FIT_ThirteenAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_optional_header, TVI_LAST
add cl_FIT_lpMappedFile, 4
add edi, 0Ah
dec cl_FIT_Counter
jnz cl_FIT_ThirteenAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, cl_FIT_hParent_optional_header, TVI_ROOT
mov cl_FIT_hParent_data_directory, eax
add edi, 27h

cl_FIT_FourteenthAdd:
call cl_FIT_AddDirectoryName
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, cl_FIT_hParent_data_directory, TVI_ROOT
mov cl_FIT_hParent_data_directory2, eax
add edi, 22h
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_data_directory2, TVI_LAST
add cl_FIT_lpMappedFile, 4
mov byte ptr[edi+8], 0
add edi, 0Ah
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_data_directory2, TVI_LAST
add cl_FIT_lpMappedFile, 4
mov byte ptr[edi+8], 0
add edi, 0Ah
sub edi, 84h
inc cl_FIT_Counter
cmp cl_FIT_Counter, 10h
jne cl_FIT_FourteenthAdd
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
add edi, 84h

cl_FIT_LastAdd:
mov cl_FIT_String, edi
add edi, 15h
call cl_FIT_AddSectionName
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, 0, TVI_ROOT
mov cl_FIT_hParent_section_header, eax
inc edi
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, cl_FIT_hParent_section_header, TVI_ROOT
mov cl_FIT_hParent_name, eax 
add edi, 0Eh
mov cl_FIT_Counter, 8h

cl_FIT_NameAdd:
mov cl_FIT_String, edi
add edi, 27h
call cl_FIT_InsertByte
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_name, TVI_LAST
inc cl_FIT_lpMappedFile
mov byte ptr[edi+2], 0
sub edi, 27h
dec cl_FIT_Counter
jnz cl_FIT_NameAdd

add edi, 2Bh
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, edi, cl_FIT_hParent_section_header, TVI_ROOT
mov cl_FIT_hParent_union, eax
add edi, 6h
mov cl_FIT_Counter, 2

cl_FIT_UnionAdd:
mov cl_FIT_String, edi 
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_union, TVI_LAST
mov byte ptr[edi+8], 0
add edi, 0Ah
dec cl_FIT_Counter
jnz cl_FIT_UnionAdd

add cl_FIT_lpMappedFile, 4
mov cl_FIT_Counter, 5

cl_FIT_MainDwordsIntoSectionHeader:
mov cl_FIT_String, edi 
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_section_header, TVI_LAST
add cl_FIT_lpMappedFile, 4
mov byte ptr[edi+8], 0
add edi, 0Ah
dec cl_FIT_Counter
jnz cl_FIT_MainDwordsIntoSectionHeader 

mov cl_FIT_Counter, 2

cl_FIT_MainWordsIntoSectionHeader:
mov cl_FIT_String, edi 
add edi, 27h
call cl_FIT_InsertWord
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_section_header, TVI_LAST
add cl_FIT_lpMappedFile, 2
mov byte ptr[edi+4], 0
add edi, 6h
dec cl_FIT_Counter
jnz cl_FIT_MainWordsIntoSectionHeader 

mov cl_FIT_String, edi 
add edi, 27h
call cl_FIT_InsertDword
invoke clAddItemIntoTree, cl_FIT_TreeViewHWND, cl_FIT_String, cl_FIT_hParent_section_header, TVI_LAST
add cl_FIT_lpMappedFile, 4
mov byte ptr[edi+8], 0

sub edi, 235h
dec cl_FIT_SectionCounter
jnz cl_FIT_LastAdd
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_FIT_AddSectionName:
mov ecx, 8 
mov eax, cl_FIT_lpMappedFile

cl_FIT_ASN_Clear:
mov byte ptr[edi], 0
inc edi
loop cl_FIT_ASN_Clear

mov ecx, 8
sub edi, 8

cl_FIT_ASN_AddByte:
mov bl, [eax]
mov [edi], bl
inc eax
inc edi
loop cl_FIT_ASN_AddByte

retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_FIT_AddDirectoryName:
mov ebx, edi
add ebx, 14h
mov eax, 0Eh
mov ecx, eax
imul cl_FIT_Counter
add eax, cl_FIT_lpDirectoryName

cl_FIT_ADN_Clear:
mov byte ptr [ebx], 0h
inc ebx
loop cl_FIT_ADN_Clear

sub ebx, 0Eh

cl_FIT_ADN_AddByte:
mov dl,  [eax]
test dl, dl
jz cl_FIT_ADN_End
mov [ebx], dl
inc eax
inc ebx
jmp cl_FIT_ADN_AddByte

cl_FIT_ADN_End:
retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_FIT_InsertDword:
invoke clRealASCII, cl_FIT_lpMappedFile, edi, 4h
retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_FIT_InsertWord:
invoke clRealASCII, cl_FIT_lpMappedFile, edi, 2h
retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_FIT_InsertByte:
invoke clRealASCII, cl_FIT_lpMappedFile, edi, 1h
retn
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clFillInformationTree endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clAddItemIntoTree proc cl_AIIT_TreeViewHWND:DWORD, cl_AIIT_String:DWORD, cl_AIIT_Parent:DWORD, cl_AIIT_InsertAfter:DWORD
LOCAL cl_AIIT_tvinsert:TV_INSERTSTRUCT
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_AIIT_tvinsert.item.iImage,0 
mov cl_AIIT_tvinsert.item.iSelectedImage,1h 
mov eax, cl_AIIT_Parent
mov cl_AIIT_tvinsert.hParent, eax
mov eax, cl_AIIT_InsertAfter
mov cl_AIIT_tvinsert.hInsertAfter, eax 
mov cl_AIIT_tvinsert.item.imask,TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE
mov eax, cl_AIIT_String
mov cl_AIIT_tvinsert.item.pszText, eax
invoke SendMessage, cl_AIIT_TreeViewHWND, TVM_INSERTITEM, 0, addr cl_AIIT_tvinsert 
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clAddItemIntoTree endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clSetFastPanelInfo proc
LOCAL cl_SFPI_Address:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov eax, clPosition
add eax, clByteH
shl eax, 4
add eax, clByteW
mov ebx, clSizeOfFile
dec ebx
cmp eax, ebx
jbe cl_SetAddress

mov eax, ebx
and ebx, 0fh
mov clByteW, ebx
mov ebx, eax
mov edx, clPosition
shl edx, 4
sub ebx, edx
shr ebx, 4
mov clByteH, ebx

cl_SetAddress:
mov cl_SFPI_Address, eax
mov dword ptr clGTEditText, eax
invoke clRealASCII, addr clGTEditText, addr clGTEditText+4, 4
invoke SetWindowText, clFPFileOffsetHandle, addr clGTEditText+4

invoke clFileOffset2VA, cllpMappedFile, cl_SFPI_Address
mov dword ptr clGTEditText, eax
invoke clRealASCII, addr clGTEditText, addr clGTEditText+4, 4
invoke SetWindowText, clFPVAHandle, addr clGTEditText+4

invoke clFileOffset2RVA, cllpMappedFile, cl_SFPI_Address
mov dword ptr clGTEditText, eax
invoke clRealASCII, addr clGTEditText, addr clGTEditText+4, 4
invoke SetWindowText, clFPRVAHandle, addr clGTEditText+4
mov eax, cl_SFPI_Address
add eax, cllpMappedFile
mov al, [eax]
mov clGTEditText, al
invoke clRealASCII, addr clGTEditText, addr clGTEditText+4, 1
mov clGTEditText+6, 00
invoke SetWindowText, clFPByteHandle, addr clGTEditText+4
xor eax, eax
mov dword ptr clGTEditText+8, eax
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clSetFastPanelInfo endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clSetStatus proc cl_SS_hStatusWindow:DWORD, cl_SS_Status:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov edi, offset clStatOpenSmall
cmp cl_SS_Status, CL_STAT_OPEN
je cl_SS_End

cl_SS_StandartStatus:
mov ecx, 6h
mov esi, offset clBeginStat
mov edi, offset clTempString
cld
rep movsb

mov esi, clFileOffset

cl_SS_AddFileName:
mov al, [esi]
cmp al, 0
jz cl_SS_AddHasBeen

mov [edi], al
inc edi
inc esi
jmp cl_SS_AddFileName

cl_SS_AddHasBeen:
mov ecx, 7h
mov ebx, edi
mov edi, offset clHasBeen
add edi, 0Bh 
mov eax, 8h
mul cl_SS_Status
mov esi, offset clOpened
add esi, eax
rep movsb

mov ecx, 12h
mov esi, offset clHasBeen
mov edi, ebx
rep movsb

mov dword ptr[edi], 0
lea edi, clTempString

cl_SS_End:
invoke SendMessage, cl_SS_hStatusWindow,SB_SETTEXT,0, edi
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clSetStatus endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clPaintContent proc cl_PC_lpMappedFile:DWORD, cl_PC_PositionInFile:DWORD, cl_PC_hdc:DWORD, cl_PC_lpFont:DWORD, cl_PC_TextColor:DWORD, cl_PC_BkColor:DWORD, cl_PC_LinePaintFlag:DWORD, cl_PC_BadColor:DWORD, cl_PC_BadTextColor:DWORD 
LOCAL cl_PC2_30:DWORD
LOCAL cl_PC_hfont:DWORD
LOCAL cl_PC_LVH:DWORD
LOCAL cl_PC_LVW:DWORD
LOCAL cl_PC_MainCounter:DWORD
LOCAL cl_PC_SecondCounter:DWORD
LOCAL cl_PC_MainBuf[4]:DWORD
LOCAL cl_PC_HorByte:DWORD
LOCAL cl_PC_CountOfASCIIToPaint:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_PC_LVW, 0
mov cl_PC_MainCounter, 0
mov cl_PC_LVH, 79 ; +25
mov cl_PC2_30, 0
mov cl_PC_SecondCounter, 0

invoke CreateFont,18,0,0,0,400,0,0,0,OEM_CHARSET,\
       OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
       DEFAULT_QUALITY,DEFAULT_PITCH or FF_SCRIPT,\
       cl_PC_lpFont

invoke SelectObject, cl_PC_hdc, eax
mov    cl_PC_hfont,eax
invoke SetTextColor,cl_PC_hdc, cl_PC_TextColor
invoke SetBkColor,cl_PC_hdc, cl_PC_BkColor
invoke TextOut,cl_PC_hdc, 374, 56,ADDR clLVColum1Caption,SIZEOF clLVColum1Caption ; +25

;	invoke GetClientRect,  clListViewHandle, addr clGlobalRect 
;	
;	mov eax, clGlobalRect.left
;	sub eax, clGlobalRect.right
;	;ja cl_WP_LVPaintEnd
;	
;	sub eax, cl_WP_ScrollRect
;	;ja cl_WP_EndMetricsCount
;	
;	sub eax, 784
;	;ja cl_WP_EndMetricsCount
;	
;	cmp cl_WP_LinePaintingFlag, 0
;	jz cl_WP_EndSub 
;	
;	sub eax, 56
;	
;	cl_WP_EndSub:
;	shr eax, 2
;	cl_WP_EndMetricsCount:
;	add eax, 112


mov cl_PC_LVW, 465 

cl_PC_1234nnCDEF:
invoke clRealASCII, addr cl_PC_MainCounter, addr cl_PC_MainBuf, 1 
invoke TextOut,cl_PC_hdc, cl_PC_LVW, 56,ADDR cl_PC_MainBuf,2 ; +25
add cl_PC_LVW, 23 
inc cl_PC_MainCounter
cmp cl_PC_MainCounter, 10h 
jb cl_PC_1234nnCDEF 

add cl_PC_LVW, 10 
invoke TextOut,cl_PC_hdc, cl_PC_LVW, 56,ADDR clLVColum1Caption2,SIZEOF clLVColum1Caption2 ; +25
mov cl_PC_LVW, 465 
lea eax, cl_PC2_30
mov cl_PC_MainCounter, eax
cmp clFileOpened, 0
jz cl_PC_123456789ABCDEFFieldFill

mov eax, clPosition
shl eax, 4
push cl_PC_lpMappedFile
pop cl_PC_MainCounter
add cl_PC_MainCounter, eax

cl_PC_123456789ABCDEFFieldFill: 

cmp clFileOpened, 0
jz cl_PC_Paint

push cl_PC_MainCounter
pop cl_PC_lpMappedFile
inc cl_PC_lpMappedFile
mov eax, clPosition
add eax, cl_PC_SecondCounter
shl eax, 4
mov ebx, cl_PC_LVW
sub ebx, 465

cl_PC_CountByteInString:
cmp ebx, 0
je cl_PC_EndCountByteInString

inc eax
sub ebx, 23
jmp cl_PC_CountByteInString

cl_PC_EndCountByteInString:
mov cl_PC_HorByte, eax
cmp eax, clSizeOfFile
jb cl_PC_Paint

invoke SetBkColor, cl_PC_hdc, cl_PC_BadColor
invoke SetTextColor, cl_PC_hdc, cl_PC_BadTextColor
mov cl_PC_MainCounter, 00401000h

cl_PC_Paint:
invoke GetBkColor, cl_PC_hdc
push eax
mov ebx, cl_PC_HorByte
mov eax, clByteH
cmp eax, cl_PC_SecondCounter
jnz cl_PC_NySelect2

mov eax, clByteW
and ebx, 0fh
cmp eax, ebx 
jnz cl_PC_NyPPaint

invoke GetSysColor, COLOR_APPWORKSPACE
invoke SetBkColor,cl_PC_hdc, eax
jmp cl_PC_NyPaint

cl_PC_NySelect2:
mov eax, clByteW
and ebx, 0fh
cmp eax, ebx
jnz cl_PC_NyPaint

cl_PC_NyPPaint:
mov eax, clPosition
add eax, cl_PC_SecondCounter
shl eax, 4
add eax, cl_PC_HorByte
shr eax, 1
inc eax
cmp eax, clSizeOfFile
jae cl_PC_NyPaint

mov eax, cl_PC_BkColor
sub eax, 202020h
invoke SetBkColor, cl_PC_hdc, eax

cl_PC_NyPaint:
invoke clRealASCII, cl_PC_MainCounter, addr cl_PC_MainBuf, 1
invoke TextOut,cl_PC_hdc, cl_PC_LVW, cl_PC_LVH,ADDR cl_PC_MainBuf, 2
push cl_PC_hdc
call SetBkColor
cmp clFileOpened, 0
jz cl_PC_inc_W

inc cl_PC_MainCounter

cl_PC_inc_W:
add cl_PC_LVW, 23
cmp cl_PC_LVW, 826
jb cl_PC_123456789ABCDEFFieldFill

cl_PC_PreClearBuf:
mov cl_PC_CountOfASCIIToPaint, 10h
cmp clFileOpened, 0
jnz cl_PC_ASCIIRealPainting
xor eax, eax
mov ecx, 4

cl_PC_ClearBuf:
mov [ebp-2ch+ecx*4], eax
loop cl_PC_ClearBuf

jmp cl_PC_PaintASCII

cl_PC_ASCIIRealPainting:
mov eax, clPosition
add eax, cl_PC_SecondCounter
shl eax, 4
mov ebx, clSizeOfFile
and ebx, 0FFFFFFF0h 
cmp eax, ebx
jz cl_PC_Last16
jb cl_PC_GoodColor

cl_PC_BadColor2:
invoke SetBkColor, cl_PC_hdc, cl_PC_BadColor
invoke SetTextColor, cl_PC_hdc, cl_PC_BadTextColor
jmp cl_PC_FillBuf

cl_PC_Last16:
mov ebx, cllpMappedFile
add ebx, eax
add ebx, 10h
mov edx, clSizeOfFile
and edx, 0fh
test dl, dl
jz cl_PC_BadColor2
mov cl_PC_MainCounter, ebx
mov cl_PC_CountOfASCIIToPaint, edx

cl_PC_GoodColor:
invoke SetBkColor, cl_PC_hdc, cl_PC_BkColor
invoke SetTextColor, cl_PC_hdc, cl_PC_TextColor

cl_PC_FillBuf:
mov esi, cl_PC_MainCounter
sub esi, 10h
lea edi, cl_PC_MainBuf
mov ecx, 4
cld
rep movsd

cl_PC_PaintASCII:
add cl_PC_LVW, 0ah
invoke TextOut,cl_PC_hdc, cl_PC_LVW, cl_PC_LVH,addr cl_PC_MainBuf, cl_PC_CountOfASCIIToPaint
inc cl_PC_SecondCounter
add cl_PC_LVH, 13h
mov cl_PC_LVW, 465

cl_PC_ABCDnnLastCompare:
cmp cl_PC_SecondCounter, 30h
jb cl_PC_123456789ABCDEFFieldFill	

cl_PC_PreAddressFieldCreate:
invoke SetBkColor, cl_PC_hdc, cl_PC_BkColor
invoke SetTextColor, cl_PC_hdc, cl_PC_TextColor	
push clPosition
pop cl_PC_MainCounter
shl cl_PC_MainCounter, 4
mov cl_PC_LVH, 60 ; +25

cl_PC_AddressFieldCreate:
add cl_PC_LVH, 19
invoke clRealASCII, addr cl_PC_MainCounter, addr cl_PC_MainBuf, 4
invoke TextOut,cl_PC_hdc, 374, cl_PC_LVH,ADDR cl_PC_MainBuf,8
add cl_PC_MainCounter, 10h
mov ebx, cl_PC_MainCounter
cmp clFileOpened, 0
jz cl_PC_LastAdressPaintCompare
 
cmp ebx, clSizeOfFile
jb cl_PC_LastAdressPaintCompare

invoke SetBkColor, cl_PC_hdc, cl_PC_BadColor
invoke SetTextColor, cl_PC_hdc, cl_PC_BadTextColor

cl_PC_LastAdressPaintCompare:
mov eax, clPosition
shl eax, 4
add eax, 300h
cmp eax, ebx
jae cl_PC_AddressFieldCreate

cl_PC_EndPaint:
invoke SelectObject,cl_PC_hdc, cl_PC_hfont
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clPaintContent endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clInvalidateContent proc
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke GetClientRect, clMainWindowHandle, addr clGlobalRect
mov clGlobalRect.top, 50
mov clGlobalRect.left, 374
sub clGlobalRect.bottom, 25
invoke GetSystemMetrics,SM_CXVSCROLL
add eax, 6
sub clGlobalRect.right, eax
invoke InvalidateRect, clMainWindowHandle, addr clGlobalRect, 0
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clInvalidateContent endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clOpenIncrementFile proc cl_OIF_FileName:DWORD, cl_OIF_NewFileName:DWORD, cl_OIF_lpSizeOfFile:DWORD, cl_OIF_Lenth:DWORD, cl_OIF_CreationDisposition:DWORD, cl_OIF_AddSub:BYTE
LOCAL cl_OIF_Attributes:DWORD
LOCAL cl_OIF_FileHandle:DWORD
LOCAL cl_OIF_FileMappedHandle:DWORD
LOCAL cl_OIF_GeneralOffset:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_OIF_Level0:
cmp cl_OIF_NewFileName, 0
je cl_OIF_Level1

invoke CopyFileA, cl_OIF_FileName, cl_OIF_NewFileName, 0
test eax, eax
je cl_OIF_Level0Bad
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_OIF_Level1:
invoke GetFileAttributesA, cl_OIF_FileName
cmp eax, -1
jne cl_OIF_Level2

cmp cl_OIF_CreationDisposition, 4
je cl_OIF_Level2_2
jmp cl_OIF_Level1Bad
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_OIF_Level2:
mov  cl_OIF_Attributes, eax
cmp cl_OIF_NewFileName, 0
jz cl_OIF_Level2_1

mov eax, cl_OIF_NewFileName
mov cl_OIF_FileName, eax

cl_OIF_Level2_1:
invoke SetFileAttributesA, cl_OIF_FileName, 80h
cl_OIF_Level2_2:
invoke CreateFileA, cl_OIF_FileName, 0C0000000h, 0, 0, cl_OIF_CreationDisposition, 80h, 0
cmp eax, -1
je cl_OIF_Level2Bad
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_OIF_Level3:
mov cl_OIF_FileHandle, eax
cmp cl_OIF_CreationDisposition, 4
jne cl_OIF_Level3_1

mov eax, cl_OIF_lpSizeOfFile
mov eax, [eax]
add eax, cl_OIF_Lenth
jmp cl_OIF_Level3_2

cl_OIF_Level3_1:
cmp cl_OIF_lpSizeOfFile, 0
jz cl_OIF_Level3_3

invoke GetFileSize, eax, 0
cmp eax, 0
jz cl_OIF_Level3Bad

mov ebx, cl_OIF_lpSizeOfFile
mov [ebx], eax
cmp cl_OIF_Lenth, 0
jz cl_OIF_Level3_3

cmp cl_OIF_AddSub, 0
jnz cl_OIF_Sub

add eax, cl_OIF_Lenth
jmp cl_OIF_Level3_2

cl_OIF_Sub:
add eax, cl_OIF_Lenth

cl_OIF_Level3_2:
invoke SetFilePointer, cl_OIF_FileHandle, eax, 0, 0
invoke SetEndOfFile, cl_OIF_FileHandle

cl_OIF_Level3_3:
invoke CreateFileMappingA, cl_OIF_FileHandle, 0, PAGE_READWRITE,0,0,0
test eax, eax
jz cl_OIF_Level3Bad
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_OIF_Level4:
mov cl_OIF_FileMappedHandle, eax
invoke CloseHandle, cl_OIF_FileHandle
invoke MapViewOfFile, cl_OIF_FileMappedHandle, FILE_MAP_WRITE, 0, 0, 0
test eax, eax
jz cl_OIF_Level4Bad
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_OIF_GoodEnd:
mov cl_OIF_GeneralOffset, eax
invoke CloseHandle, cl_OIF_FileMappedHandle
invoke SetFileAttributesA, cl_OIF_FileName, cl_OIF_Attributes
cl_OIF_GoodEnd_RealEnd:
mov eax, cl_OIF_GeneralOffset
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_OIF_Level4Bad:
invoke CloseHandle, cl_OIF_FileMappedHandle
cl_OIF_Level3Bad:
invoke CloseHandle, cl_OIF_FileHandle  
cl_OIF_Level2Bad:
invoke SetFileAttributesA, cl_OIF_FileName, cl_OIF_Attributes
cl_OIF_Level1Bad:
xor eax, eax
cl_OIF_Level0Bad:
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clOpenIncrementFile endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clOpenFile proc cl_OF_FileName:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clOpenIncrementFile, cl_OF_FileName, 0, 0, 0, 3, 0
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clOpenFile endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clCloseFile proc cl_CF_lpMappedFile:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke UnmapViewOfFile, cl_CF_lpMappedFile
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clCloseFile endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clPETest proc cl_PET_lpMappedFile:DWORD, cl_PET_SizeOfFile:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov eax, cl_PET_lpMappedFile
cmp word ptr [eax], 5A4Dh
jne cl_PET_Not_a_PE_File
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov byte ptr[eax+18h], 40h
jb cl_PET_Not_a_PE_File
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov ebx, [eax+3ch]
cmp ebx, cl_PET_SizeOfFile
ja cl_PET_Not_a_PE_File
add ebx, eax 
cmp dword ptr [ebx], 00004550h
jne cl_PET_Not_a_PE_File
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov eax, 1
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_PET_Not_a_PE_File:
xor eax, eax
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clPETest endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clRealHex proc cl_RH_SourceBuf:DWORD, cl_RH_SecondBuf:DWORD, cl_RH_Lenth:BYTE
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
xor ecx, ecx
mov cl, cl_RH_Lenth
mov esi, cl_RH_SourceBuf
add esi, ecx
shr ecx, 1
mov edi, cl_RH_SecondBuf
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_RH_Begin:
dec esi
dec esi
xor eax, eax
xor ebx, ebx
mov al, [esi]
shl ax, 4h
sub ah, 3h
jz cl_RH_BX

sub al, 70h 

cl_RH_BX:
inc esi
mov bl, [esi]
dec esi
shl bx, 4h
sub bh, 3h
jz cl_RH_End

sub bl, 70h

cl_RH_End:
shr bl, 4
or al, bl
mov [edi], al
inc edi
loop cl_RH_Begin                                              
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ret                                                 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clRealHex endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clRealASCII proc cl_RA_SourceBuf:DWORD, cl_RA_SecondBuf:DWORD, cl_RA_Lenth:BYTE
LOCAL cl_RA_InsertNull:BYTE
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov cl_RA_InsertNull, 1
xor ecx, ecx
mov cl, cl_RA_Lenth
mov ebx, cl_RA_SourceBuf
add ebx, ecx
dec ebx
mov edx, cl_RA_SecondBuf
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_RA_Begin:
mov al, [ebx]                                                  
mov ah, al                                                       
shr al, 4h                                                       
cmp al, 9h                                                       
jbe cl_RA_NextNextAL                                                       

cmp cl_RA_InsertNull, 0
jz cl_RA_NextAL 

mov byte ptr[edx], 30h
inc edx

cl_RA_NextAL:
add al, 7h                                                      
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_RA_NextNextAL:
mov cl_RA_InsertNull, 0
add al, 30h
mov [edx], al                                               
inc edx                                                        
and ah, 0Fh                                                      
cmp ah, 9h                                                      
jbe cl_RA_NextAH

add ah, 7h
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_RA_NextAH:
add ah, 30h
mov [edx], ah
inc edx
dec ebx                                                         
loop cl_RA_Begin                                              
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ret                                                 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clRealASCII endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clEnlargeInsertIntoFile proc cl_EIIF_lpMappedFile:DWORD,  cl_EIIF_SizeOfFile:DWORD, cl_EIIF_lpBuf:DWORD, cl_EIIF_Offset:DWORD, cl_EIIF_Lenth:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov ecx, cl_EIIF_SizeOfFile
mov esi, cl_EIIF_lpMappedFile
add esi, ecx
mov edi, esi
sub ecx, cl_EIIF_Offset
add edi, cl_EIIF_Lenth
inc ecx

std
rep movsb
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov edi, esi
inc edi
mov ecx, cl_EIIF_Lenth

cmp cl_EIIF_lpBuf, 0
jz cl_EIIF_InsertNull
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov esi, cl_EIIF_lpBuf
cld
rep movsb
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_EIIF_InsertNull:
mov byte ptr [edi], 00
inc edi
loop cl_EIIF_InsertNull
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clEnlargeInsertIntoFile endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clDecreaseCutFromFile proc cl_DCFF_lpMappedFile:DWORD,  cl_DCFF_SizeOfFile:DWORD, cl_DCFF_Offset:DWORD, cl_DCFF_Lenth:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov esi, cl_DCFF_lpMappedFile
add esi, cl_DCFF_Offset
mov edi, esi
sub edi, cl_DCFF_Lenth
mov ecx, cl_DCFF_SizeOfFile
sub ecx, cl_DCFF_Offset

cld
rep movsb
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_EIIF_End:
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clDecreaseCutFromFile endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clCutInsert proc cl_CI_lpMappedFile:DWORD,  cl_CI_SizeOfFile:DWORD, cl_CI_lpBuf:DWORD, cl_CI_Offset1:DWORD, cl_CI_Offset2:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov eax, cl_CI_Offset1
cmp eax, cl_CI_Offset2
jb cl_CI_Insert
ja cl_CI_Cut

ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_CI_Insert:
sub cl_CI_Offset2, eax
invoke clEnlargeInsertIntoFile, cl_CI_lpMappedFile, cl_CI_SizeOfFile, cl_CI_lpBuf, cl_CI_Offset1, cl_CI_Offset2
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cl_CI_Cut:
sub eax, cl_CI_Offset2
invoke clDecreaseCutFromFile, cl_CI_lpMappedFile, cl_CI_SizeOfFile, cl_CI_Offset1, eax
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clCutInsert endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clGetNTFromDOSHeader proc cl_GNTFDOSH_lpMappedFile:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
mov ebx, cl_GNTFDOSH_lpMappedFile
mov eax, ebx
add eax, 3ch
mov eax, [eax]
add eax, ebx
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clGetNTFromDOSHeader endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clGetISHFromDOSHeader proc cl_GISHFDOSH_lpMappedFile:DWORD, cl_GISHFDOSH_NumberOfSection:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clGetNTFromDOSHeader, cl_GISHFDOSH_lpMappedFile
mov ecx, eax
mov ebx, cl_GISHFDOSH_NumberOfSection
mov eax, [eax+6]
and eax, 0ffffh
cmp ebx, eax
ja cl_GISHFDOSH_BadEnd

mov eax, 28h
mul ebx
add eax, 0d0h
add eax, ecx
ret

cl_GISHFDOSH_BadEnd:
xor eax, eax
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clGetISHFromDOSHeader endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clGetNumberOfSectoins proc cl_GNOS_lpMappedFile:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clGetNTFromDOSHeader, cl_GNOS_lpMappedFile
mov ax, [eax+6]
and eax, 0FFFFh
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clGetNumberOfSectoins endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clGetSectoinFromAddress proc cl_GSFA_lpMappedFile:DWORD, cl_GSFA_Address:DWORD, cl_GSFA_Virtual:DWORD
LOCAL cl_GSFA_NumberOfSections:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clGetNumberOfSectoins, cl_GSFA_lpMappedFile
test eax, eax
jz cl_GSFA_End

mov cl_GSFA_NumberOfSections, eax
invoke clGetISHFromDOSHeader, cl_GSFA_lpMappedFile, 1
xor ecx, ecx

cl_GSFA_BeginFindingSection:
cmp cl_GSFA_Virtual, 0
jne cl_GSFA_VirtualVariant  

mov ebx, [eax+14h] 
jmp cl_GSFA_CompareNow

cl_GSFA_VirtualVariant:
mov ebx, [eax+0Ch]

cl_GSFA_CompareNow:
cmp cl_GSFA_Address, ebx
jb cl_GSFA_NotASection

inc ecx
add ebx, [eax+10h]
cmp cl_GSFA_Address, ebx
jb cl_GSFA_SectionFound

add eax, 28h  
cmp ecx, cl_GSFA_NumberOfSections
jb cl_GSFA_BeginFindingSection

cl_GSFA_NotASection:
mov eax, ecx
shl eax, 1
inc eax
ret

cl_GSFA_SectionFound:
mov eax, ecx
shl eax, 1

cl_GSFA_End:
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clGetSectoinFromAddress endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clCreateData proc cl_CD_lpMappedFile:DWORD, cl_CD_SizeOfFile:DWORD, cl_CD_GeneralOffset:DWORD, cl_CD_SizeOfNewData:DWORD, cl_CD_Buf:DWORD, cl_CD_lpSectionName:DWORD, cl_CD_Characteristics:DWORD 
LOCAL cl_CD_SectionData[20h]:BYTE
LOCAL cl_CD_Lenth:DWORD
LOCAL cl_CD_ISHAdderess:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
cmp cl_CD_Characteristics, 0
jz cl_CD_EndInsertSection

mov ecx, 8

mov esi, cl_CD_lpSectionName
lea edi, cl_CD_SectionData
cld
movsb

mov eax, cl_CD_SizeOfNewData 
mov [edi],eax  
mov [edi+8h],eax
mov eax,cl_CD_GeneralOffset
mov [edi+0Ch],eax
mov eax, cl_CD_Characteristics
mov [edi+14h],eax
invoke clGetNumberOfSectoins, cl_CD_lpMappedFile
mov ecx, eax
invoke clGetISHFromDOSHeader, cl_CD_lpMappedFile, ax
mov cl_CD_ISHAdderess, eax
mov ebx,1000h
jcxz cl_CD_VirtualAddressFound

cl_CD_FindLastVirtualAddress:
add eax, 0Ch
cmp ebx, [eax] 
ja cl_CD_ebxLeads 
mov ebx, [eax]
cl_CD_ebxLeads:
loop cl_CD_VirtualAddressFound
sub eax, 20h
loop cl_CD_FindLastVirtualAddress

cl_CD_VirtualAddressFound:
mov [edi+4h],ebx

mov cl_CD_Lenth, 20h
add cl_CD_ISHAdderess, 20h
invoke clEnlargeInsertIntoFile, cl_CD_lpMappedFile, cl_CD_SizeOfFile, cl_CD_SectionData, cl_CD_ISHAdderess, 20h

cl_CD_EndInsertSection:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cl_CD_RealEnd:
mov eax, 1
ret
cl_CD_BadEnd:
xor eax, eax
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clCreateData endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clGetImageBase proc cl_GSFA_lpMappedFile:DWORD
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clGetNTFromDOSHeader, cl_GSFA_lpMappedFile
mov eax, [eax+34h]
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clGetImageBase endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clFileOffset2RVA proc cl_FO2RVA_lpMappedFile:DWORD, cl_FO2RVA_Address:DWORD 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clGetSectoinFromAddress, cl_FO2RVA_lpMappedFile, cl_FO2RVA_Address, 0
shr eax, 1
test eax, eax
jz cl_FO2RVA_BadEnd

invoke clGetISHFromDOSHeader, cl_FO2RVA_lpMappedFile, eax
mov ebx, cl_FO2RVA_Address
sub ebx, [eax+14h]
add ebx, [eax+0ch]
mov eax, ebx
ret

cl_FO2RVA_BadEnd:
mov eax, cl_FO2RVA_Address
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clFileOffset2RVA  endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clRVA2VA proc cl_RVA2VA_lpMappedFile:DWORD, cl_RVA2VA_Address:DWORD 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clGetImageBase, cl_RVA2VA_lpMappedFile
add eax, cl_RVA2VA_Address
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clRVA2VA  endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clFileOffset2VA proc cl_FO2VA_lpMappedFile:DWORD, cl_FO2VA_Address:DWORD 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clFileOffset2RVA,cl_FO2VA_lpMappedFile, cl_FO2VA_Address
invoke clRVA2VA, cl_FO2VA_lpMappedFile, eax
ret 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clFileOffset2VA  endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clRVA2FileOffset proc cl_RVA2FO_lpMappedFile:DWORD, cl_RVA2FO_Address:DWORD 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clGetSectoinFromAddress, cl_RVA2FO_lpMappedFile, cl_RVA2FO_Address, 1
shr eax, 1
test eax, eax
jz cl_RVA2FO_BadEnd

invoke clGetISHFromDOSHeader, cl_RVA2FO_lpMappedFile, eax
mov ebx, cl_RVA2FO_Address
add ebx, [eax+14h]
sub ebx, [eax+0ch]
mov eax, ebx
ret

cl_RVA2FO_BadEnd:
mov eax, cl_RVA2FO_Address
ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clRVA2FileOffset  endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clVA2RVA proc cl_VA2RVA_lpMappedFile:DWORD, cl_VA2RVA_Address:DWORD 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clGetImageBase, cl_VA2RVA_lpMappedFile
xchg eax, cl_VA2RVA_Address
sub eax, cl_VA2RVA_Address
ret 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clVA2RVA endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

clVA2FileOffset proc cl_VA2FO_lpMappedFile:DWORD, cl_VA2FO_Address:DWORD 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
invoke clVA2RVA, cl_VA2FO_lpMappedFile, cl_VA2FO_Address
invoke clRVA2FileOffset, cl_VA2FO_lpMappedFile, eax
ret 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
clVA2FileOffset endp

;*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/*\_/

end start