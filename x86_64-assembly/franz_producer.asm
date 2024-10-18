format ELF64 executable

; syscalls
SOCKET = 41
CONNECT = 42

; random constants
STDIN = 0
STDOUT = 1
AF_INET = 2
SOCK_STREAM = 1
IPPROTO_IP = 0
INADDR_ANY = 0

macro read fd, buf, len {
    mov rax, 0
    mov rdi, fd
    mov rsi, buf
    mov rdx, len
    syscall
}

macro write fd, buf, len {
    mov rax, 1
    mov rdi, fd
    mov rsi, buf
    mov rdx, len
    syscall
}

macro exit code {
    mov rax, 60
    mov rdi, code
    syscall
}

; output = ax
macro htons n {
    mov ax, n
    mov cx, ax

    and ax, 0xFF
    shl ax, 8
    and cx, 0xFF00
    shr cx, 8
    or ax, cx
}

segment readable executable
    write STDOUT, start_message, start_message_len

    mov rax, SOCKET
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, IPPROTO_IP
    syscall

    mov r8, rax ; sock

    push 0 ; pad
    mov dword [rsp+4], 0x0100007F ; ip
    htons 8085 ; port
    mov word [rsp+2], ax
    mov word [rsp], AF_INET

    mov rax, CONNECT
    mov rdi, r8 ; sock
    mov rsi, rsp ; sockaddr
    mov rdx, 16 ; sockaddr size
    syscall

    mov edx, handshake_str_len
    bswap edx
    mov dword [handshake_len_buf], edx
    write r8, handshake_len_buf, 4
    write r8, handshake_str, handshake_str_len

    jmp write_loop

write_loop:
    read STDIN, stdin_buffer, stdin_buffer_len

    mov rdx, rax ; read len
    write r8, stdin_buffer, rdx

    jmp write_loop

_exit:
    exit 0

segment readable writeable
    start_message db "frans_asm producer client starting", 0xA
    start_message_len = $ - start_message

    error_exit_message db "Exiting from error", 0xA
    error_exit_message_len = $ - error_exit_message

    handshake_str db "version=1,topic=hi,api=produce"
    handshake_str_len = $ - handshake_str
    handshake_len_buf rd 1 ; u32

    stdin_buffer rb 2048
    stdin_buffer_len = $ - stdin_buffer
