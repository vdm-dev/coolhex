# CoolHex

Advanced hex viewer\editor with PE header analyser.

```
;;*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*;;
;;  $####$    $####$      $####$    $#       $#   #$  $####$  #X   X#;;     	  
;; $#$       $#    #$    $#    #$   $#       $#   #$  $#       #X X# ;;
;;$#$       $#      #$  $#      #$  $#       $#####$  $####$    #X#  ;;
;; $#$       $#    #$    $#    #$   $#       $#   #$  $#       #X X# ;;
;;  $####$    $####$      $####$    $######  $#   #$  $####$  #X   X#;;	
;;*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*;;
```

## Toolset
Microsoft (R) Macro Assembler Version 6.14.8444

Microsoft (R) Incremental Linker Version 5.12.8078

## Build Commands
**ml** /c /coff /Cp /nologo coolhex.asm

**rc** coolhex.rc

**link** /SUBSYSTEM:WINDOWS /RELEASE /VERSION:0.11 coolhex.obj coolhex.res


**Copyright (c) Free Programmers' Society. All rights reversed.**
