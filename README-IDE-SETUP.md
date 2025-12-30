# xv6 IDE 配置指南

这个配置专门为 **Windows + WSL** 环境下的 xv6 开发优化。

## ✅ 配置完成清单

- [x] `compile_commands.json` - 从实际 Makefile 生成的编译数据库
- [x] `.vscode/c_cpp_properties.json` - VSCode C/C++ 配置
- [x] `.vscode/settings.json` - 项目设置
- [x] `.vscode/tasks.json` - 构建任务配置
- [x] `.clangd` - Clang Language Server 配置

## 🚀 如何使用

### 1. 重启 VSCode
关闭并重新打开 VSCode，让新配置生效。

### 2. 测试代码跳转
在 `proc.c` 中：
- **Ctrl+Click** 或 **F12** 点击函数名（如 `scheduler`、`yield`）
- 应该能跳转到定义处
- **Ctrl+Shift+O** 查看文件内符号列表

### 3. 测试智能补全
- 输入 `proc->` 应该显示结构体成员提示
- 输入函数名应该有自动补全

### 4. 构建和运行
- **Ctrl+Shift+P** → "Tasks: Run Task"
  - `build-xv6` - 编译项目
  - `clean-xv6` - 清理
  - `run-qemu` - 运行 xv6
  - `regenerate-compile-db` - 重新生成编译数据库

## 🔧 故障排除

### 如果跳转不工作：

1. **重启 IntelliSense**：
   ```
   Ctrl+Shift+P → "C/C++: Restart IntelliSense"
   ```

2. **检查输出**：
   - 查看 "C/C++" 输出窗口是否有错误
   - 查看 "clangd" 输出窗口（如果使用 clangd 扩展）

3. **重新生成编译数据库**：
   ```
   Ctrl+Shift+P → "Tasks: Run Task" → "regenerate-compile-db"
   ```

4. **检查路径**：
   - 确保 `compile_commands.json` 中的路径是 Windows 格式 (`D:\...`)
   - 如果不是，运行：`python3 fix-paths.py`

### 如果构建失败：

1. **检查 WSL**：
   ```bash
   wsl -e gcc --version
   wsl -e make --version
   ```

2. **手动构建测试**：
   ```bash
   wsl -e make clean
   wsl -e make
   ```

## 📋 推荐的 VSCode 扩展

- **C/C++** (Microsoft) - 必需
- **C/C++ Themes** (Microsoft) - 语法高亮
- **WSL** (Microsoft) - WSL 支持

可选：
- **clangd** - 替代 C/C++ IntelliSense（更准确但需要配置）

## 🎯 支持的功能

✅ **代码导航**：
- 跳转到定义 (F12)
- 跳转到声明 (Ctrl+F12)
- 查找所有引用 (Shift+F12)
- 符号搜索 (Ctrl+T)

✅ **代码补全**：
- 函数/变量名自动补全
- 结构体成员补全
- 头文件包含补全

✅ **错误检查**：
- 实时语法检查
- 类型检查
- 未使用变量警告

✅ **调试支持**：
- GDB 调试配置已设置
- 断点支持（需要 QEMU-GDB 模式）

## 🛠 自定义配置

如果需要修改编译参数：

1. 编辑 `Makefile` 中的 `CFLAGS`
2. 运行 "regenerate-compile-db" 任务
3. 重启 IntelliSense

---

现在你的 xv6 项目应该有完整的 IDE 智能感知功能了！
