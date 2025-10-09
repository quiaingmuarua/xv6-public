cmake_minimum_required(VERSION 3.10)
project(xv6 C ASM)

set(CMAKE_C_STANDARD 99)

# 设置编译器（与 Makefile 保持一致）
set(CMAKE_C_COMPILER gcc)
set(CMAKE_ASM_COMPILER gcc)

# 编译标志（与 Makefile 保持一致）
set(CMAKE_C_FLAGS "-fno-pic -static -fno-builtin -fno-strict-aliasing -O2 -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer -fno-stack-protector")
set(CMAKE_ASM_FLAGS "-m32 -gdwarf-2 -Wa,-divide")

# 内核源文件
set(KERNEL_SOURCES
    bio.c
    console.c
    exec.c
    file.c
    fs.c
    ide.c
    ioapic.c
    kalloc.c
    kbd.c
    lapic.c
    log.c
    main.c
    mp.c
    picirq.c
    pipe.c
    proc.c
    sleeplock.c
    spinlock.c
    string.c
    syscall.c
    sysfile.c
    sysproc.c
    trap.c
    uart.c
    vm.c
    entry.S
    swtch.S
    trapasm.S
)

# 用户程序源文件
set(USER_SOURCES
    cat.c
    echo.c
    forktest.c
    grep.c
    init.c
    kill.c
    ln.c
    ls.c
    mkdir.c
    rm.c
    sh.c
    stressfs.c
    usertests.c
    wc.c
    zombie.c
    ulib.c
    usys.S
    printf.c
    umalloc.c
)

# 创建内核目标（仅用于 IDE 分析）
add_executable(kernel ${KERNEL_SOURCES})
target_include_directories(kernel PRIVATE .)

# 创建用户程序目标（仅用于 IDE 分析）
add_executable(user_programs ${USER_SOURCES})
target_include_directories(user_programs PRIVATE .)

# 添加头文件以便 IDE 识别
file(GLOB HEADERS "*.h")
target_sources(kernel PRIVATE ${HEADERS})
target_sources(user_programs PRIVATE ${HEADERS})

# 自定义目标：实际编译（使用原始 Makefile）
add_custom_target(build_xv6
    COMMAND make
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Building xv6 using original Makefile"
)

add_custom_target(run_qemu
    COMMAND make qemu
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running xv6 in QEMU"
    DEPENDS build_xv6
)

add_custom_target(debug_qemu
    COMMAND make qemu-gdb
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running xv6 in QEMU with GDB support"
    DEPENDS build_xv6
)
