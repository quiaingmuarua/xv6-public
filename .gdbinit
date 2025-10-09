set confirm off
set pagination off
set mi-async on
set disassemble-next-line on
set print pretty on
set architecture i386

# 加载符号（比 symbol-file 更稳）
file /mnt/d/code_project/geekrun/native_example/open_source/xv6-public/kernel

# 如果想一 attach 就停在 main，保留下一行；否则删掉，让你手动控制
break main
