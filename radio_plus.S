.intel_syntax noprefix

.equ NULL, 0
.equ TRUE, 1
.equ SW_SHOWDEFAULT, 10

.equ WS_OVERLAPPEDWINDOW, 0x00CF0000
.equ WS_VISIBLE, 0x10000000
.equ WS_CHILD, 0x40000000
.equ WS_BORDER, 0x00800000
.equ WS_VSCROLL, 0x00200000
.equ LBS_NOTIFY, 0x00000001
.equ LBS_OWNERDRAWFIXED, 0x00000010
.equ LBS_HASSTRINGS, 0x00000040
.equ BS_PUSHBUTTON, 0x00000000
.equ BS_OWNERDRAW, 0x0000000B
.equ SS_CENTER, 0x00000001
.equ TBS_AUTOTICKS, 0x00000001

.equ WM_CREATE, 0x0001
.equ WM_DESTROY, 0x0002
.equ WM_ERASEBKGND, 0x0014
.equ WM_PAINT, 0x000F
.equ WM_DRAWITEM, 0x002B
.equ WM_COMMAND, 0x0111
.equ WM_LBUTTONDOWN, 0x0201
.equ WM_HSCROLL, 0x0114
.equ WM_CTLCOLORLISTBOX, 0x0134
.equ WM_CTLCOLORBTN, 0x0135
.equ WM_CTLCOLORSTATIC, 0x0138
.equ MM_MCINOTIFY, 0x03B9
.equ MCI_NOTIFY, 0x00000001
.equ MCI_NOTIFY_SUCCESSFUL, 0x0001
.equ LBN_DBLCLK, 2

.equ LB_ADDSTRING, 0x0180
.equ LB_GETCURSEL, 0x0188
.equ LB_SETCURSEL, 0x0186
.equ LB_SETITEMHEIGHT, 0x01A0
.equ TBM_GETPOS, 0x0400
.equ TBM_SETPOS, 0x0405
.equ TBM_SETRANGE, 0x0406
.equ WM_SETFONT, 0x0030
.equ WM_SETTEXT, 0x000C
.equ TRANSPARENT, 1
.equ PS_SOLID, 0
.equ DT_CENTER, 1
.equ DT_VCENTER, 4
.equ DT_SINGLELINE, 0x20
.equ ODS_SELECTED, 1
.equ IMAGE_BITMAP, 0
.equ LR_LOADFROMFILE, 0x0010
.equ SRCCOPY, 0x00CC0020

.equ IDC_LIST, 1001
.equ IDC_PLAY, 1002
.equ IDC_PAUSE, 1003
.equ IDC_STOP, 1004
.equ IDC_PREV, 1005
.equ IDC_NEXT, 1006
.equ IDC_SHUFFLE, 1007
.equ IDC_VOL, 1008
.equ IDC_PITCH, 1009

.section .text
.globl main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 160

    xor ecx, ecx
    call GetModuleHandleA
    mov [rip + hInst], rax

    xor ecx, ecx
    call CreateSolidBrush
    mov [rip + hBrush], rax
    mov [rip + wc + 48], rax

    call InitCommonControls

    xor ecx, ecx
    mov edx, 32512
    call LoadCursorA
    mov [rip + wc + 40], rax

    lea rcx, [rip + wc]
    call RegisterClassExA

    sub rsp, 64
    mov qword ptr [rsp + 32], -2147483648
    mov qword ptr [rsp + 40], -2147483648
    mov qword ptr [rsp + 48], 940
    mov qword ptr [rsp + 56], 660
    mov qword ptr [rsp + 64], 0
    mov qword ptr [rsp + 72], 0
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    xor ecx, ecx
    lea rdx, [rip + className]
    lea r8, [rip + appTitle]
    mov r9d, WS_OVERLAPPEDWINDOW | WS_VISIBLE
    call CreateWindowExA
    add rsp, 64
    mov [rip + hWndMain], rax

msg_loop:
    lea rcx, [rbp - 96]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call GetMessageA
    test eax, eax
    jz msg_done
    lea rcx, [rbp - 96]
    call TranslateMessage
    lea rcx, [rbp - 96]
    call DispatchMessageA
    jmp msg_loop

msg_done:
    xor eax, eax
    leave
    ret

.globl WndProc
WndProc:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    sub rsp, 104
    mov [rbp - 32], rcx
    mov [rbp - 40], rdx
    mov [rbp - 48], r8
    mov [rbp - 56], r9

    cmp edx, WM_CREATE
    je on_create
    cmp edx, WM_ERASEBKGND
    je on_erase
    cmp edx, WM_PAINT
    je on_paint
    cmp edx, WM_DRAWITEM
    je on_drawitem
    cmp edx, WM_COMMAND
    je on_command
    cmp edx, WM_LBUTTONDOWN
    je on_lbutton
    cmp edx, WM_HSCROLL
    je on_scroll
    cmp edx, MM_MCINOTIFY
    je on_notify
    cmp edx, WM_CTLCOLORLISTBOX
    je on_color_list
    cmp edx, WM_CTLCOLORBTN
    je on_color_button
    cmp edx, WM_CTLCOLORSTATIC
    je on_color_static
    cmp edx, WM_DESTROY
    je on_destroy

def_proc:
    mov rcx, [rbp - 32]
    mov rdx, [rbp - 40]
    mov r8, [rbp - 48]
    mov r9, [rbp - 56]
    call DefWindowProcA
    jmp wnd_done

on_create:
    mov rcx, [rbp - 32]
    call CreateControls
    xor eax, eax
    jmp wnd_done

on_erase:
    mov eax, 1
    jmp wnd_done

on_paint:
    mov rcx, [rbp - 32]
    call DrawDecor
    xor eax, eax
    jmp wnd_done

on_drawitem:
    mov rcx, [rbp - 56]
    mov eax, [rcx + 4]
    cmp eax, IDC_LIST
    je draw_list_item
    call DrawOwnerButton
    mov eax, 1
    jmp wnd_done
draw_list_item:
    call DrawOwnerList
    mov eax, 1
    jmp wnd_done

on_command:
    mov rax, [rbp - 48]
    mov ebx, eax
    and ebx, 0xffff
    mov ecx, eax
    shr ecx, 16
    cmp ebx, IDC_PLAY
    je cmd_play
    cmp ebx, IDC_PAUSE
    je cmd_pause
    cmp ebx, IDC_STOP
    je cmd_stop
    cmp ebx, IDC_PREV
    je cmd_prev
    cmp ebx, IDC_NEXT
    je cmd_next
    cmp ebx, IDC_SHUFFLE
    je cmd_shuffle
    cmp ebx, IDC_LIST
    jne command_done
    cmp ecx, LBN_DBLCLK
    jne command_done
cmd_play:
    mov rcx, [rip + hList]
    mov edx, LB_GETCURSEL
    xor r8d, r8d
    xor r9d, r9d
    call SendMessageA
    cmp eax, 0
    jl command_done
    mov ecx, eax
    call PlayIndex
    jmp command_done
cmd_pause:
    call TogglePause
    jmp command_done
cmd_stop:
    call StopRadio
    jmp command_done
cmd_prev:
    call PrevTrack
    jmp command_done
cmd_next:
    call NextTrack
    jmp command_done
cmd_shuffle:
    call ShuffleTrack
command_done:
    xor eax, eax
    jmp wnd_done

on_lbutton:
    mov rax, [rbp - 56]
    mov ebx, eax
    and ebx, 0xffff
    mov ecx, eax
    shr ecx, 16

    cmp ecx, 292
    jl hit_row2
    cmp ecx, 356
    jg hit_row2
    cmp ebx, 622
    jl hit_pause
    cmp ebx, 738
    jle cmd_play
hit_pause:
    cmp ebx, 758
    jl hit_none
    cmp ebx, 874
    jle cmd_pause
    jmp hit_none

hit_row2:
    cmp ecx, 370
    jl hit_row3
    cmp ecx, 434
    jg hit_row3
    cmp ebx, 622
    jl hit_prev
    cmp ebx, 738
    jle cmd_stop
hit_prev:
    cmp ebx, 758
    jl hit_none
    cmp ebx, 874
    jle cmd_prev
    jmp hit_none

hit_row3:
    cmp ecx, 448
    jl hit_knobs
    cmp ecx, 512
    jg hit_knobs
    cmp ebx, 622
    jl hit_scan
    cmp ebx, 738
    jle cmd_next
hit_scan:
    cmp ebx, 758
    jl hit_none
    cmp ebx, 874
    jle cmd_shuffle

hit_knobs:
    cmp ecx, 516
    jl hit_none
    cmp ecx, 604
    jg hit_none
    cmp ebx, 622
    jl hit_tune_knob
    cmp ebx, 710
    jle hit_volume_knob
hit_tune_knob:
    cmp ebx, 786
    jl hit_none
    cmp ebx, 874
    jle hit_pitch_knob
    jmp hit_none

hit_volume_knob:
    mov rcx, [rip + hVol]
    mov edx, TBM_GETPOS
    xor r8d, r8d
    xor r9d, r9d
    call SendMessageA
    cmp ebx, 666
    jl volume_down
    add eax, 8
    cmp eax, 100
    jle volume_set
    mov eax, 100
    jmp volume_set
volume_down:
    sub eax, 8
    cmp eax, 0
    jge volume_set
    xor eax, eax
volume_set:
    mov rcx, [rip + hVol]
    mov edx, TBM_SETPOS
    mov r8d, TRUE
    mov r9d, eax
    call SendMessageA
    call ApplySliders
    xor eax, eax
    jmp wnd_done

hit_pitch_knob:
    mov rcx, [rip + hPitch]
    mov edx, TBM_GETPOS
    xor r8d, r8d
    xor r9d, r9d
    call SendMessageA
    cmp ebx, 830
    jl pitch_down
    add eax, 5
    cmp eax, 150
    jle pitch_set
    mov eax, 150
    jmp pitch_set
pitch_down:
    sub eax, 5
    cmp eax, 50
    jge pitch_set
    mov eax, 50
pitch_set:
    mov rcx, [rip + hPitch]
    mov edx, TBM_SETPOS
    mov r8d, TRUE
    mov r9d, eax
    call SendMessageA
    call ApplySliders
    xor eax, eax
    jmp wnd_done

hit_none:
    xor eax, eax
    jmp wnd_done

on_scroll:
    call ApplySliders
    xor eax, eax
    jmp wnd_done

on_notify:
    mov rax, [rbp - 48]
    cmp eax, MCI_NOTIFY_SUCCESSFUL
    jne notify_done
    mov eax, [rip + isPlaying]
    test eax, eax
    jz notify_done
    call NextTrack
notify_done:
    xor eax, eax
    jmp wnd_done

on_color_static:
    mov rcx, [rbp - 48]
    mov edx, 0x0037AFD4
    call SetTextColor
    mov rcx, [rbp - 48]
    xor edx, edx
    call SetBkColor
    mov rcx, [rbp - 48]
    mov edx, TRANSPARENT
    call SetBkMode
    mov rax, [rip + hBrush]
    jmp wnd_done

on_color_list:
    mov rcx, [rbp - 48]
    mov edx, 0x0037AFD4
    call SetTextColor
    mov rcx, [rbp - 48]
    xor edx, edx
    call SetBkColor
    mov rax, [rip + hBrush]
    jmp wnd_done

on_color_button:
    mov rcx, [rbp - 48]
    mov edx, 0x0037AFD4
    call SetTextColor
    mov rcx, [rbp - 48]
    xor edx, edx
    call SetBkColor
    mov rax, [rip + hBrush]
    jmp wnd_done

on_destroy:
    call StopRadio
    mov rcx, [rip + hTitleFont]
    test rcx, rcx
    jz destroy_skip_title_font
    call DeleteObject
destroy_skip_title_font:
    mov rcx, [rip + hUiFont]
    test rcx, rcx
    jz destroy_skip_ui_font
    call DeleteObject
destroy_skip_ui_font:
    mov rcx, [rip + hBgBmp]
    test rcx, rcx
    jz destroy_skip_bg
    call DeleteObject
destroy_skip_bg:
    xor ecx, ecx
    call PostQuitMessage
    xor eax, eax

wnd_done:
    add rsp, 104
    pop rdi
    pop rsi
    pop rbx
    leave
    ret

DrawDecor:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 168
    mov rbx, rcx

    lea rdx, [rbp - 112]
    call BeginPaint
    mov [rbp - 8], rax

    mov rax, [rip + hBgBmp]
    test rax, rax
    jz draw_decor_fallback
    mov rcx, [rbp - 8]
    call CreateCompatibleDC
    mov [rbp - 40], rax
    mov rcx, [rbp - 40]
    mov rdx, [rip + hBgBmp]
    call SelectObject
    mov [rbp - 48], rax
    mov rcx, [rbp - 8]
    xor edx, edx
    xor r8d, r8d
    mov r9d, 920
    mov qword ptr [rsp + 32], 620
    mov rax, [rbp - 40]
    mov qword ptr [rsp + 40], rax
    mov qword ptr [rsp + 48], 0
    mov qword ptr [rsp + 56], 0
    mov qword ptr [rsp + 64], SRCCOPY
    call BitBlt
    mov rcx, [rbp - 40]
    mov rdx, [rbp - 48]
    call SelectObject
    mov rcx, [rbp - 40]
    call DeleteDC
    jmp draw_decor_finish

draw_decor_fallback:

    mov rcx, [rbp - 8]
    mov edx, TRANSPARENT
    call SetBkMode
    mov rcx, [rbp - 8]
    mov edx, 0x0037AFD4
    call SetTextColor

    mov ecx, 5
    call GetStockObject
    mov rcx, [rbp - 8]
    mov rdx, rax
    call SelectObject

    mov ecx, PS_SOLID
    mov edx, 3
    mov r8d, 0x0037AFD4
    call CreatePen
    mov [rbp - 16], rax
    mov rcx, [rbp - 8]
    mov rdx, rax
    call SelectObject
    mov [rbp - 24], rax

    mov rcx, [rbp - 8]
    mov edx, 12
    mov r8d, 12
    mov r9d, 910
    mov qword ptr [rsp + 32], 610
    call Rectangle

    mov rcx, [rbp - 8]
    mov edx, 28
    mov r8d, 102
    mov r9d, 586
    mov qword ptr [rsp + 32], 586
    call Rectangle

    mov rcx, [rbp - 8]
    mov edx, 604
    mov r8d, 102
    mov r9d, 884
    mov qword ptr [rsp + 32], 586
    call Rectangle

    mov rcx, [rbp - 8]
    mov edx, 40
    mov r8d, 146
    mov r9d, 560
    mov qword ptr [rsp + 32], 442
    call Rectangle

    mov rcx, [rbp - 8]
    mov edx, 40
    mov r8d, 462
    mov r9d, 560
    mov qword ptr [rsp + 32], 568
    call Rectangle

    mov rcx, [rbp - 8]
    mov edx, 178
    mov r8d, 118
    lea r9, [rip + lcdText]
    mov qword ptr [rsp + 32], 34
    call TextOutA

    mov rcx, [rbp - 8]
    mov edx, 620
    mov r8d, 270
    xor r9d, r9d
    call MoveToEx
    mov rcx, [rbp - 8]
    mov edx, 868
    mov r8d, 270
    call LineTo

    mov rcx, [rbp - 8]
    mov edx, 620
    mov r8d, 462
    xor r9d, r9d
    call MoveToEx
    mov rcx, [rbp - 8]
    mov edx, 868
    mov r8d, 462
    call LineTo

    mov rcx, [rbp - 8]
    mov edx, 620
    mov r8d, 488
    mov r9d, 704
    mov qword ptr [rsp + 32], 572
    call Ellipse

    mov rcx, [rbp - 8]
    mov edx, 786
    mov r8d, 488
    mov r9d, 870
    mov qword ptr [rsp + 32], 572
    call Ellipse

    mov rcx, [rbp - 8]
    mov edx, 648
    mov r8d, 528
    lea r9, [rip + knobVolText]
    mov qword ptr [rsp + 32], 3
    call TextOutA

    mov rcx, [rbp - 8]
    mov edx, 812
    mov r8d, 528
    lea r9, [rip + knobTuneText]
    mov qword ptr [rsp + 32], 4
    call TextOutA

    mov rcx, [rbp - 8]
    mov edx, 642
    mov r8d, 286
    lea r9, [rip + scaleText]
    mov qword ptr [rsp + 32], 27
    call TextOutA

    mov rcx, [rbp - 8]
    mov edx, 670
    mov r8d, 470
    lea r9, [rip + badgeText]
    mov qword ptr [rsp + 32], 17
    call TextOutA

    mov dword ptr [rbp - 32], 58
speaker_v_loop:
    mov eax, [rbp - 32]
    cmp eax, 548
    jg speaker_v_done
    mov rcx, [rbp - 8]
    mov edx, eax
    mov r8d, 472
    xor r9d, r9d
    call MoveToEx
    mov rcx, [rbp - 8]
    mov edx, [rbp - 32]
    mov r8d, 560
    call LineTo
    add dword ptr [rbp - 32], 16
    jmp speaker_v_loop
speaker_v_done:

    mov dword ptr [rbp - 36], 476
speaker_h_loop:
    mov eax, [rbp - 36]
    cmp eax, 560
    jg speaker_h_done
    mov rcx, [rbp - 8]
    mov edx, 48
    mov r8d, eax
    xor r9d, r9d
    call MoveToEx
    mov rcx, [rbp - 8]
    mov edx, 552
    mov r8d, [rbp - 36]
    call LineTo
    add dword ptr [rbp - 36], 16
    jmp speaker_h_loop
speaker_h_done:

    mov rcx, [rbp - 8]
    mov edx, 56
    mov r8d, 112
    lea r9, [rip + shineText]
    mov qword ptr [rsp + 32], 19
    call TextOutA

    mov rcx, [rbp - 8]
    mov rdx, [rbp - 24]
    call SelectObject
    mov rcx, [rbp - 16]
    call DeleteObject

draw_decor_finish:
    mov rcx, rbx
    lea rdx, [rbp - 112]
    call EndPaint
    add rsp, 168
    pop rbx
    leave
    ret

DrawOwnerButton:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 168
    mov rbx, rcx

    mov rcx, [rbx + 24]
    lea rdx, [rbp - 96]
    mov r8d, 64
    call GetWindowTextA

    mov eax, [rbx + 16]
    and eax, ODS_SELECTED
    test eax, eax
    jz button_not_pressed
    mov ecx, 0x00161408
    jmp button_fill
button_not_pressed:
    xor ecx, ecx
button_fill:
    call CreateSolidBrush
    mov [rbp - 8], rax
    mov rcx, [rbx + 32]
    lea rdx, [rbx + 40]
    mov r8, rax
    call FillRect

    mov rcx, [rbx + 32]
    mov edx, TRANSPARENT
    call SetBkMode
    mov rcx, [rbx + 32]
    mov edx, 0x008AE2F8
    call SetTextColor

    mov ecx, PS_SOLID
    mov edx, 3
    mov r8d, 0x0037AFD4
    call CreatePen
    mov [rbp - 16], rax
    mov rcx, [rbx + 32]
    mov rdx, rax
    call SelectObject
    mov [rbp - 24], rax

    mov rcx, [rbx + 32]
    mov edx, [rbx + 40]
    mov r8d, [rbx + 44]
    mov r9d, [rbx + 48]
    mov eax, [rbx + 52]
    mov [rsp + 32], rax
    call Rectangle

    mov ecx, PS_SOLID
    mov edx, 1
    mov r8d, 0x008AE2F8
    call CreatePen
    mov [rbp - 32], rax
    mov rcx, [rbx + 32]
    mov rdx, rax
    call SelectObject

    mov rcx, [rbx + 32]
    mov edx, [rbx + 40]
    add edx, 6
    mov r8d, [rbx + 44]
    add r8d, 6
    xor r9d, r9d
    call MoveToEx
    mov rcx, [rbx + 32]
    mov edx, [rbx + 48]
    sub edx, 8
    mov r8d, [rbx + 44]
    add r8d, 6
    call LineTo

    mov rcx, [rbx + 32]
    lea rdx, [rbp - 96]
    mov r8d, -1
    lea r9, [rbx + 40]
    mov qword ptr [rsp + 32], DT_CENTER | DT_VCENTER | DT_SINGLELINE
    call DrawTextA

    mov rcx, [rbx + 32]
    mov rdx, [rbp - 24]
    call SelectObject
    mov rcx, [rbp - 16]
    call DeleteObject
    mov rcx, [rbp - 32]
    call DeleteObject
    mov rcx, [rbp - 8]
    call DeleteObject

    mov eax, 1
    add rsp, 168
    pop rbx
    leave
    ret

DrawOwnerList:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    sub rsp, 128
    mov rbx, rcx

    mov esi, [rbx + 8]
    cmp esi, -1
    je draw_list_done

    mov eax, [rbx + 16]
    and eax, ODS_SELECTED
    test eax, eax
    jz list_not_selected
    mov ecx, 0x002B2110
    jmp list_fill
list_not_selected:
    xor ecx, ecx
list_fill:
    call CreateSolidBrush
    mov [rbp - 8], rax
    mov rcx, [rbx + 32]
    lea rdx, [rbx + 40]
    mov r8, rax
    call FillRect

    mov rcx, [rbx + 32]
    mov edx, TRANSPARENT
    call SetBkMode

    mov eax, [rbx + 16]
    and eax, ODS_SELECTED
    test eax, eax
    jz list_gold_text
    mov edx, 0x00F5E6AA
    jmp list_set_text
list_gold_text:
    mov edx, 0x0037AFD4
list_set_text:
    mov rcx, [rbx + 32]
    call SetTextColor

    lea rax, [rip + tracks]
    mov rdx, [rax + rsi*8]
    mov rcx, [rbx + 32]
    mov r8d, -1
    lea r9, [rbx + 40]
    mov eax, [r9]
    add eax, 8
    mov [r9], eax
    mov qword ptr [rsp + 32], DT_VCENTER | DT_SINGLELINE
    call DrawTextA

    mov rcx, [rbp - 8]
    call DeleteObject

draw_list_done:
    mov eax, 1
    add rsp, 128
    pop rsi
    pop rbx
    leave
    ret

CreateControls:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 120
    mov rbx, rcx

    xor ecx, ecx
    call CreateSolidBrush
    mov [rip + hBrush], rax

    xor ecx, ecx
    lea rdx, [rip + bgBmpPath]
    mov r8d, IMAGE_BITMAP
    xor r9d, r9d
    mov qword ptr [rsp + 32], 0
    mov qword ptr [rsp + 40], LR_LOADFROMFILE
    call LoadImageA
    mov [rip + hBgBmp], rax

    mov ecx, 38
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    mov qword ptr [rsp + 32], 800
    mov qword ptr [rsp + 40], 0
    mov qword ptr [rsp + 48], 0
    mov qword ptr [rsp + 56], 0
    mov qword ptr [rsp + 64], 0
    mov qword ptr [rsp + 72], 0
    mov qword ptr [rsp + 80], 0
    mov qword ptr [rsp + 88], 0
    mov qword ptr [rsp + 96], 0
    lea rax, [rip + titleFace]
    mov qword ptr [rsp + 104], rax
    call CreateFontA
    mov [rip + hTitleFont], rax

    mov ecx, 16
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    mov qword ptr [rsp + 32], 600
    mov qword ptr [rsp + 40], 0
    mov qword ptr [rsp + 48], 0
    mov qword ptr [rsp + 56], 0
    mov qword ptr [rsp + 64], 0
    mov qword ptr [rsp + 72], 0
    mov qword ptr [rsp + 80], 0
    mov qword ptr [rsp + 88], 0
    mov qword ptr [rsp + 96], 0
    lea rax, [rip + uiFace]
    mov qword ptr [rsp + 104], rax
    call CreateFontA
    mov [rip + hUiFont], rax

    xor ecx, ecx
    lea rdx, [rip + staticClass]
    lea r8, [rip + headerText]
    mov r9d, WS_CHILD | SS_CENTER
    mov qword ptr [rsp + 32], 300
    mov qword ptr [rsp + 40], 18
    mov qword ptr [rsp + 48], 320
    mov qword ptr [rsp + 56], 52
    mov qword ptr [rsp + 64], rbx
    mov qword ptr [rsp + 72], 0
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    xor ecx, ecx
    call CreateWindowExA
    mov [rip + hHeader], rax
    mov rcx, [rip + hList]
    mov edx, WM_SETFONT
    mov r8, [rip + hTitleFont]
    mov r9d, TRUE
    call SendMessageA

    xor ecx, ecx
    lea rdx, [rip + staticClass]
    lea r8, [rip + subtitleText]
    mov r9d, WS_CHILD | SS_CENTER
    mov qword ptr [rsp + 32], 300
    mov qword ptr [rsp + 40], 84
    mov qword ptr [rsp + 48], 320
    mov qword ptr [rsp + 56], 24
    mov qword ptr [rsp + 64], rbx
    mov qword ptr [rsp + 72], 0
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    call CreateWindowExA
    mov rcx, rax
    mov edx, WM_SETFONT
    mov r8, [rip + hUiFont]
    mov r9d, TRUE
    call SendMessageA

    lea rdx, [rip + listClass]
    lea r8, [rip + emptyText]
    mov r9d, WS_CHILD | WS_VISIBLE | WS_BORDER | LBS_NOTIFY | LBS_OWNERDRAWFIXED | LBS_HASSTRINGS
    mov qword ptr [rsp + 32], 92
    mov qword ptr [rsp + 40], 198
    mov qword ptr [rsp + 48], 420
    mov qword ptr [rsp + 56], 118
    mov qword ptr [rsp + 64], rbx
    mov qword ptr [rsp + 72], IDC_LIST
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    xor ecx, ecx
    call CreateWindowExA
    mov [rip + hList], rax
    mov rcx, rax
    mov edx, LB_SETITEMHEIGHT
    xor r8d, r8d
    mov r9d, 20
    call SendMessageA
    mov rcx, [rip + hList]
    mov edx, WM_SETFONT
    mov r8, [rip + hUiFont]
    mov r9d, TRUE
    call SendMessageA

    xor esi, esi
add_loop:
    cmp esi, 20
    jge controls_after_list
    lea rax, [rip + tracks]
    mov r9, [rax + rsi*8]
    mov rcx, [rip + hList]
    mov edx, LB_ADDSTRING
    xor r8d, r8d
    call SendMessageA
    inc esi
    jmp add_loop

controls_after_list:
    mov rcx, [rip + hList]
    mov edx, LB_SETCURSEL
    xor r8d, r8d
    xor r9d, r9d
    call SendMessageA

    xor esi, esi
btn_loop:
    cmp esi, 6
    jge sliders
    lea rax, [rip + btnDefs]
    mov rdi, [rax + rsi*8]
    xor ecx, ecx
    lea rdx, [rip + buttonClass]
    mov r8, [rdi]
    mov r9d, WS_CHILD | BS_PUSHBUTTON | BS_OWNERDRAW
    mov eax, [rdi + 8]
    mov [rsp + 32], rax
    mov eax, [rdi + 12]
    mov [rsp + 40], rax
    mov eax, [rdi + 16]
    mov [rsp + 48], rax
    mov eax, [rdi + 20]
    mov [rsp + 56], rax
    mov qword ptr [rsp + 64], rbx
    mov eax, [rdi + 24]
    mov [rsp + 72], rax
    mov rax, [rip + hInst]
    mov [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    call CreateWindowExA
    mov rcx, rax
    mov edx, WM_SETFONT
    mov r8, [rip + hUiFont]
    mov r9d, TRUE
    call SendMessageA
    inc esi
    jmp btn_loop

sliders:
    xor ecx, ecx
    lea rdx, [rip + staticClass]
    lea r8, [rip + volText]
    mov r9d, WS_CHILD
    mov qword ptr [rsp + 32], 625
    mov qword ptr [rsp + 40], 575
    mov qword ptr [rsp + 48], 84
    mov qword ptr [rsp + 56], 18
    mov qword ptr [rsp + 64], rbx
    mov qword ptr [rsp + 72], 0
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    call CreateWindowExA

    xor ecx, ecx
    lea rdx, [rip + trackbarClass]
    lea r8, [rip + emptyText]
    mov r9d, WS_CHILD | TBS_AUTOTICKS
    mov qword ptr [rsp + 32], 625
    mov qword ptr [rsp + 40], 598
    mov qword ptr [rsp + 48], 84
    mov qword ptr [rsp + 56], 24
    mov qword ptr [rsp + 64], rbx
    mov qword ptr [rsp + 72], IDC_VOL
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    call CreateWindowExA
    mov [rip + hVol], rax
    mov rcx, rax
    mov edx, TBM_SETRANGE
    mov r8d, TRUE
    mov r9d, 0x00640000
    call SendMessageA
    mov rcx, [rip + hVol]
    mov edx, TBM_SETPOS
    mov r8d, TRUE
    mov r9d, 75
    call SendMessageA

    xor ecx, ecx
    lea rdx, [rip + staticClass]
    lea r8, [rip + pitchText]
    mov r9d, WS_CHILD
    mov qword ptr [rsp + 32], 790
    mov qword ptr [rsp + 40], 575
    mov qword ptr [rsp + 48], 84
    mov qword ptr [rsp + 56], 18
    mov qword ptr [rsp + 64], rbx
    mov qword ptr [rsp + 72], 0
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    call CreateWindowExA

    xor ecx, ecx
    lea rdx, [rip + trackbarClass]
    lea r8, [rip + emptyText]
    mov r9d, WS_CHILD | TBS_AUTOTICKS
    mov qword ptr [rsp + 32], 790
    mov qword ptr [rsp + 40], 598
    mov qword ptr [rsp + 48], 84
    mov qword ptr [rsp + 56], 24
    mov qword ptr [rsp + 64], rbx
    mov qword ptr [rsp + 72], IDC_PITCH
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    call CreateWindowExA
    mov [rip + hPitch], rax
    mov rcx, rax
    mov edx, TBM_SETRANGE
    mov r8d, TRUE
    mov r9d, 0x00960032
    call SendMessageA
    mov rcx, [rip + hPitch]
    mov edx, TBM_SETPOS
    mov r8d, TRUE
    mov r9d, 100
    call SendMessageA

    xor ecx, ecx
    lea rdx, [rip + staticClass]
    lea r8, [rip + readyText]
    mov r9d, WS_CHILD
    mov qword ptr [rsp + 32], 88
    mov qword ptr [rsp + 40], 136
    mov qword ptr [rsp + 48], 420
    mov qword ptr [rsp + 56], 24
    mov qword ptr [rsp + 64], rbx
    mov qword ptr [rsp + 72], 0
    mov rax, [rip + hInst]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    call CreateWindowExA
    mov [rip + hStatus], rax

    add rsp, 120
    pop rbx
    leave
    ret

PlayIndex:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 88
    mov ebx, ecx
    cmp ebx, 0
    jl play_done
    cmp ebx, 20
    jge play_done
    mov [rip + currentIndex], ebx
    call CloseRadio
    lea rax, [rip + paths]
    mov r8, [rax + rbx*8]
    lea rcx, [rip + cmdBuf]
    lea rdx, [rip + fmtOpen]
    call wsprintfA
    lea rcx, [rip + cmdBuf]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call mciSendStringA
    test eax, eax
    jnz play_error
    mov dword ptr [rip + isOpen], 1
    mov dword ptr [rip + isPaused], 0
    call ApplySliders
    lea rcx, [rip + cmdPlay]
    xor edx, edx
    xor r8d, r8d
    mov r9, [rip + hWndMain]
    call mciSendStringA
    mov dword ptr [rip + isPlaying], 1
    mov rcx, [rip + hList]
    mov edx, LB_SETCURSEL
    mov r8d, ebx
    xor r9d, r9d
    call SendMessageA
    lea rax, [rip + tracks]
    mov r8, [rax + rbx*8]
    lea rcx, [rip + statusBuf]
    lea rdx, [rip + fmtNow]
    call wsprintfA
    mov rcx, [rip + hStatus]
    mov edx, WM_SETTEXT
    xor r8d, r8d
    lea r9, [rip + statusBuf]
    call SendMessageA
    jmp play_done
play_error:
    mov rcx, [rip + hStatus]
    mov edx, WM_SETTEXT
    xor r8d, r8d
    lea r9, [rip + errorText]
    call SendMessageA
play_done:
    add rsp, 88
    pop rbx
    leave
    ret

ApplySliders:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov rcx, [rip + hVol]
    test rcx, rcx
    jz sliders_done
    mov edx, TBM_GETPOS
    xor r8d, r8d
    xor r9d, r9d
    call SendMessageA
    mov [rbp - 4], eax
    imul eax, eax, 65535
    mov ecx, 100
    xor edx, edx
    div ecx
    mov edx, eax
    shl eax, 16
    or edx, eax
    xor ecx, ecx
    call waveOutSetVolume
    mov eax, [rbp - 4]
    imul eax, eax, 10
    mov r8d, eax
    lea rcx, [rip + cmdBuf]
    lea rdx, [rip + fmtVolume]
    call wsprintfA
    lea rcx, [rip + cmdBuf]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call mciSendStringA

    mov rcx, [rip + hPitch]
    mov edx, TBM_GETPOS
    xor r8d, r8d
    xor r9d, r9d
    call SendMessageA
    imul eax, eax, 10
    mov r8d, eax
    lea rcx, [rip + cmdBuf]
    lea rdx, [rip + fmtSpeed]
    call wsprintfA
    lea rcx, [rip + cmdBuf]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call mciSendStringA
sliders_done:
    leave
    ret

TogglePause:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    cmp dword ptr [rip + isPlaying], 0
    je pause_done
    cmp dword ptr [rip + isPaused], 0
    je do_pause
    lea rcx, [rip + cmdResume]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call mciSendStringA
    mov dword ptr [rip + isPaused], 0
    jmp pause_done
do_pause:
    lea rcx, [rip + cmdPause]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call mciSendStringA
    mov dword ptr [rip + isPaused], 1
pause_done:
    leave
    ret

StopRadio:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov dword ptr [rip + isPlaying], 0
    mov dword ptr [rip + isPaused], 0
    lea rcx, [rip + cmdStop]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call mciSendStringA
    call CloseRadio
    leave
    ret

CloseRadio:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    cmp dword ptr [rip + isOpen], 0
    je close_done
    lea rcx, [rip + cmdClose]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call mciSendStringA
    mov dword ptr [rip + isOpen], 0
close_done:
    leave
    ret

NextTrack:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov ecx, [rip + currentIndex]
    inc ecx
    cmp ecx, 20
    jl next_ok
    xor ecx, ecx
next_ok:
    call PlayIndex
    leave
    ret

PrevTrack:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov ecx, [rip + currentIndex]
    dec ecx
    cmp ecx, 0
    jge prev_ok
    mov ecx, 19
prev_ok:
    call PlayIndex
    leave
    ret

ShuffleTrack:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    call GetTickCount
    xor edx, edx
    mov ecx, 20
    div ecx
    mov ecx, edx
    call PlayIndex
    leave
    ret

.section .data
.equ TRACK_COUNT, 20

className: .asciz "RadioPlusAsmClass"
appTitle: .asciz "SCARFACE Radio"
headerText: .asciz ""
subtitleText: .asciz ""
bgBmpPath: .asciz "C:\\Users\\user\\OneDrive - mmu.edu.my\\Desktop\\radio of\\assets\\stickers\\scarface-radio-ui-background.bmp"
emptyText: .asciz ""
staticClass: .asciz "STATIC"
buttonClass: .asciz "BUTTON"
listClass: .asciz "LISTBOX"
trackbarClass: .asciz "msctls_trackbar32"
titleFace: .asciz "Georgia"
uiFace: .asciz "Consolas"
volText: .asciz "MASTER VOLUME"
pitchText: .asciz "TONE / SPEED"
readyText: .asciz "ON AIR STANDBY - SELECT A TAPE."
errorText: .asciz "Could not play this WAV file."
scaleText: .asciz "AM 80s | FM LUX | GOLD BAND"
badgeText: .asciz "GOLD PLATED PANEL"
lcdText: .asciz "ILLUMINATED CASSETTE / WAV DISPLAY"
knobVolText: .asciz "VOL"
knobTuneText: .asciz "TUNE"
shineText: .asciz "BRUSHED GOLD TRIM"

btnPlay: .asciz "PLAY"
btnPause: .asciz "PAUSE"
btnStop: .asciz "STOP"
btnPrev: .asciz "PREV"
btnNext: .asciz "NEXT"
btnShuffle: .asciz "SCAN"

fmtOpen: .asciz "open \"%s\" type waveaudio alias radio"
cmdPlay: .asciz "play radio notify"
cmdPause: .asciz "pause radio"
cmdResume: .asciz "resume radio"
cmdStop: .asciz "stop radio"
cmdClose: .asciz "close radio"
fmtVolume: .asciz "setaudio radio volume to %u"
fmtSpeed: .asciz "set radio speed %u"
fmtNow: .asciz "Now playing: %s"

btnDefs:
    .quad bdPlay, bdPause, bdStop, bdPrev, bdNext, bdShuffle
bdPlay:    .quad btnPlay;    .long 622, 292, 116, 64, IDC_PLAY
bdPause:   .quad btnPause;   .long 758, 292, 116, 64, IDC_PAUSE
bdStop:    .quad btnStop;    .long 622, 370, 116, 64, IDC_STOP
bdPrev:    .quad btnPrev;    .long 758, 370, 116, 64, IDC_PREV
bdNext:    .quad btnNext;    .long 622, 448, 116, 64, IDC_NEXT
bdShuffle: .quad btnShuffle; .long 758, 448, 116, 64, IDC_SHUFFLE

tracks:
    .quad t00,t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19
paths:
    .quad p00,p01,p02,p03,p04,p05,p06,p07,p08,p09,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19

t00:.asciz "ID 01"; p00:.asciz "ID_01\\ID_01.wav"
t01:.asciz "ID 02"; p01:.asciz "ID_02\\ID_02.wav"
t02:.asciz "ID 03"; p02:.asciz "ID_03\\ID_03.wav"
t03:.asciz "ID 04"; p03:.asciz "ID_04\\ID_04.wav"
t04:.asciz "ID 05"; p04:.asciz "ID_05\\ID_05.wav"
t05:.asciz "ID 06"; p05:.asciz "ID_06\\ID_06.wav"
t06:.asciz "ID 07"; p06:.asciz "ID_07\\ID_07.wav"
t07:.asciz "ID 08"; p07:.asciz "ID_08\\ID_08.wav"
t08:.asciz "ID 09"; p08:.asciz "ID_09\\ID_09.wav"
t09:.asciz "ID 10"; p09:.asciz "ID_10\\ID_10.wav"
t10:.asciz "ID 11"; p10:.asciz "ID_11\\ID_11.wav"
t11:.asciz "SOLO 01"; p11:.asciz "SOLO_01\\SOLO_01.wav"
t12:.asciz "SOLO 02"; p12:.asciz "SOLO_02\\SOLO_02.wav"
t13:.asciz "SOLO 03"; p13:.asciz "SOLO_03\\SOLO_03.wav"
t14:.asciz "SOLO 04"; p14:.asciz "SOLO_04\\SOLO_04.wav"
t15:.asciz "SOLO 05"; p15:.asciz "SOLO_05\\SOLO_05.wav"
t16:.asciz "SOLO 06"; p16:.asciz "SOLO_06\\SOLO_06.wav"
t17:.asciz "SOLO 07"; p17:.asciz "SOLO_07\\SOLO_07.wav"
t18:.asciz "SOLO 08"; p18:.asciz "SOLO_08\\SOLO_08.wav"
t19:.asciz "SOLO 09"; p19:.asciz "SOLO_09\\SOLO_09.wav"

.balign 8
wc:
    .long 80
    .long 0
    .quad WndProc
    .long 0
    .long 0
    .quad 0
    .quad 0
    .quad 0
    .quad 6
    .quad 0
    .quad className
    .quad 0

.section .bss
.balign 8
hInst: .skip 8
hWndMain: .skip 8
hList: .skip 8
hVol: .skip 8
hPitch: .skip 8
hStatus: .skip 8
hBrush: .skip 8
hBgBmp: .skip 8
hHeader: .skip 8
hTitleFont: .skip 8
hUiFont: .skip 8
currentIndex: .skip 4
isOpen: .skip 4
isPlaying: .skip 4
isPaused: .skip 4
cmdBuf: .skip 512
statusBuf: .skip 256
