.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include file-editor.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

;########################################################################

; ������ ��������� �������� ���'��
Mem_Alloc PROC Buf_Size:DWORD
	add Buf_Size,4	; �������� ����� �� 4 ����� ������
	invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT, Buf_Size   ; �������� ������� � ��������� ���'��
	push eax 	; �������� ����� ������ ��������� ������ � ����
	invoke GlobalLock,eax ;������� � ��������
	pop [eax]	;��������� � ����� ��������  � �������� � ����� 4 ����� ��������� ������, 
				;�� �������� � ���� ������ ������� ������
				;�������� Buf_Size ���� ������������� �� �����
	add eax,4	;������� �������� ������� ������ �� 4 �����, ������� ����� 4 ����� 
			;����� ��������� ������ ������
	ret	; �������� � ���������
Mem_Alloc endp

; ������ ��������� �������� ���'��.
Mem_Free PROC DATA:DWORD
	mov eax,DATA	;������� �������� ��������� ��������� � ������ eax, ���������� � 
					;��������� (������) ������ ������ ( ������� + 4 �����)
	sub eax,4	;���'�����, �� ������ 4 ����� ������  - �� ����� ������
	push [eax]	;������ �������� ������ �������� �� �����, �� ������ � ������ eax, �������� ���� � ����
	invoke GlobalUnlock,eax	;������������ ���'��� (��� ������� Buf_Size+4)
	call GlobalFree	;������� �������� ��� � �����, ��������� ��������� ��� ���������, �� ��������� ���������� 
					;call (������� ������ ������)
	ret	;����� � ���������
Mem_Free endp

;########################################################################

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_EDT1
		mov		hText, eax
		
		invoke GetCurrentDirectory, 260, addr initdir
		mov ofn.lStructSize, sizeof OPENFILENAME
		mov ofn.lpstrFile, offset filename
		mov ofn.nMaxFile, 260
		mov ofn.lpstrInitialDir, offset initdir
		
		invoke Mem_Alloc, 4000h 
		mov pmem, eax
		
	.elseif eax==WM_COMMAND
		.if wParam == IDC_BTN1
			invoke GetOpenFileName, offset ofn
			.if eax!=0
			
				invoke CreateFile, addr filename, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
				.if eax!=-1
					mov hFile, eax	
					invoke ReadFile, hFile, pmem, 4000h, readed, 0
					invoke CloseHandle,hFile
					invoke SendMessage, hText, WM_SETTEXT,0,pmem
				.endif
			
			.endif
		.elseif wParam == IDC_BTN2
			invoke GetSaveFileName, offset ofn
			.if eax!=0
				invoke SendMessage, hText, WM_GETTEXT,4000h,pmem
				invoke MessageBox, 0, offset filename, 0, MB_OK
				invoke CreateFile, filename, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_WRITE, 0,CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
				.if eax!=-1
					invoke MessageBox, 0, pmem, 0, MB_OK
					mov hFile, eax	
					invoke WriteFile, hFile, pmem, 4000h, addr readed, 0
					invoke CloseHandle,hFile
				.endif
				
			.endif
			
		.endif
	.elseif eax==WM_CLOSE
		invoke Mem_Free, pmem
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
