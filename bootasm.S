#include "asm.h"
#include "memlayout.h"
#include "mmu.h"

# ---------------------------------------------------------------
# 启动第一个 CPU：从实模式切换到 32 位保护模式，再跳入 C 代码。
# BIOS 会把本扇区加载到物理地址 0x7c00，并以实模式启动：
#    CS = 0, IP = 0x7c00
# ---------------------------------------------------------------

.code16                 # 生成 16 位实模式代码
.globl start
start:
  cli                   # 关中断，避免在切换模式时被打断

  # ---- 初始化段寄存器（实模式下） ----
  xorw %ax,%ax          # AX = 0
  movw %ax,%ds          # DS = 0
  movw %ax,%es          # ES = 0
  movw %ax,%ss          # SS = 0
  # 此时段基址全为 0，线性地址 = 偏移地址，方便访问

  # ---- 开启 A20 地址线 ----
  # A20 线默认被关闭（兼容老式 8086，地址会在 1MB 回绕）
  # 必须通过键盘控制器（端口 0x64/0x60）开启，否则无法访问 1MB 以上内存

seta20.1:
  inb $0x64,%al         # 读键盘控制器状态端口
  testb $0x2,%al        # 检查是否忙（bit1=1 表示忙）
  jnz seta20.1          # 忙则继续等待

  movb $0xd1,%al        # 命令 0xD1：告诉 KBC 下一个字节写入输出端口
  outb %al,$0x64

seta20.2:
  inb $0x64,%al         # 再次等待不忙
  testb $0x2,%al
  jnz seta20.2

  movb $0xdf,%al        # 0xDF = 1101_1111b -> 打开 A20
  outb %al,$0x60        # 写入输出端口（端口 0x60）

  # ---- 切换到保护模式 ----
  # 使用一个临时 GDT，使虚拟地址 == 物理地址（平坦映射）
  lgdt gdtdesc           # 加载 GDT（在下面定义）

  movl %cr0, %eax
  orl  $CR0_PE, %eax     # 设置 CR0.PE = 1 （启用保护模式）
  movl %eax, %cr0

  # ---- 用一次长跳转 (far jump) 完成切换 ----
  # 这会同时刷新 CS 和 EIP，正式进入 32 位寻址
  ljmp $(SEG_KCODE<<3), $start32

# ---------------------------------------------------------------
# 下面开始 32 位代码段
# ---------------------------------------------------------------
.code32
start32:
  # ---- 设置保护模式下的数据段寄存器 ----
  movw $(SEG_KDATA<<3), %ax   # 数据段选择子（KDATA 段）
  movw %ax,%ds
  movw %ax,%es
  movw %ax,%ss
  movw $0,%ax
  movw %ax,%fs
  movw %ax,%gs

  # ---- 设置栈并跳到 C 函数 ----
  movl $start, %esp       # 栈顶放在 0x7c00（引导区内）
  call bootmain           # 跳入 C 代码：加载内核并跳转执行

  # ---- 如果 bootmain 返回（理论上不应发生）----
  # 触发 Bochs 模拟器断点（用于调试）
  movw $0x8a00, %ax
  movw %ax, %dx
  outw %ax, %dx
  movw $0x8ae0, %ax
  outw %ax, %dx

spin:
  jmp spin                # 死循环等待调试器

# ---------------------------------------------------------------
# 启动用 GDT（全局描述符表）
# ---------------------------------------------------------------
.p2align 2                # 4 字节对齐
gdt:
  SEG_NULLASM                             # 第 0 项：空段（必须存在）
  SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   # 代码段：可执行可读，基址0，限长4GB
  SEG_ASM(STA_W,       0x0, 0xffffffff)   # 数据段：可写，基址0，限长4GB

# GDTR 的内容（GDT 的描述符）
gdtdesc:
  .word (gdtdesc - gdt - 1)   # GDT 的长度（字节数 - 1）
  .long gdt                   # GDT 的物理地址
