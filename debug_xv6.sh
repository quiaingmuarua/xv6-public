#!/bin/bash

# xv6 一键调试脚本
# 使用方法: ./debug_xv6.sh

echo "=== xv6 调试启动脚本 ==="

# 检查是否在正确目录
if [ ! -f "Makefile" ] || [ ! -f "main.c" ]; then
    echo "错误: 请在 xv6 项目根目录下运行此脚本"
    exit 1
fi

# 编译项目
echo "1. 编译 xv6..."
make clean > /dev/null 2>&1
make

if [ $? -ne 0 ]; then
    echo "编译失败，请检查错误信息"
    exit 1
fi

# 配置 GDB 自动加载
echo "2. 配置 GDB..."
mkdir -p ~/.config/gdb
if ! grep -q "set auto-load safe-path /" ~/.config/gdb/gdbinit 2>/dev/null; then
    echo "set auto-load safe-path /" >> ~/.config/gdb/gdbinit
    echo "已配置 GDB 自动加载"
fi

# 启动 QEMU (后台)
echo "3. 启动 QEMU 调试模式..."
make qemu-gdb > /dev/null 2>&1 &
QEMU_PID=$!

# 等待 QEMU 启动
sleep 2

# 创建 GDB 命令文件
cat > /tmp/gdb_commands << 'EOF'
# 连接到 QEMU
target remote localhost:25000

# 加载符号
symbol-file kernel

# 在 main 函数设置断点
b main

# 显示帮助信息
echo \n=== 调试已就绪 ===\n
echo 常用命令:\n
echo   c     - 继续执行\n
echo   n     - 单步执行(不进入函数)\n
echo   s     - 单步执行(进入函数)\n
echo   list  - 查看代码\n
echo   p var - 打印变量值\n
echo   bt    - 查看调用栈\n
echo   info registers - 查看寄存器\n
echo   quit  - 退出调试\n
echo \n现在输入 'c' 开始执行到 main 函数\n

EOF

# 启动 GDB
echo "4. 启动 GDB 调试器..."
echo "提示: 输入 'c' 开始执行到 main 函数"
gdb -x /tmp/gdb_commands

# 清理
echo "5. 清理进程..."
kill $QEMU_PID 2>/dev/null
rm -f /tmp/gdb_commands

echo "调试结束"
