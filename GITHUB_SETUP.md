# GitHub 推送指南

## 📋 前提条件

在开始之前，请确保您已完成以下步骤：

1. ✅ 拥有 GitHub 账号
2. ✅ 已安装 Git
3. ✅ 项目代码已提交到本地仓库

## 🚀 推送到 GitHub

### 方法 1: 使用 GitHub CLI（推荐）

如果您安装了 GitHub CLI (`gh`)，可以使用以下命令：

```bash
# 进入项目目录
cd ble_clock_syncer

# 创建 GitHub 仓库
gh repo create ble_clock_syncer --public --source=. --remote=origin --push

# 如果仓库已存在，直接推送
gh repo set-default
git push -u origin main
```

### 方法 2: 手动创建仓库后推送

1. 在 GitHub 上创建新仓库：
   - 访问 https://github.com/new
   - 仓库名称：`ble_clock_syncer`
   - 设置为公开（Public）或私有（Private）
   - **不要**勾选 "Initialize this repository with a README"
   - **不要**添加 .gitignore 或 LICENSE（已包含）

2. 推送代码：

```bash
# 进入项目目录
cd ble_clock_syncer

# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/ble_clock_syncer.git

# 推送代码到 GitHub
git push -u origin main
```

### 方法 3: 使用 SSH（推荐）

如果您已配置 SSH 密钥：

```bash
# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin git@github.com:YOUR_USERNAME/ble_clock_syncer.git

# 推送代码
git push -u origin main
```

## ⚙️ 配置 GitHub 用户信息（首次使用）

如果这是您第一次使用 Git，请配置您的用户信息：

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

建议使用与 GitHub 账号相同的邮箱。

## 🔐 配置 SSH 密钥（可选但推荐）

使用 SSH 可以避免每次推送都输入密码。

### 1. 生成 SSH 密钥

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

按 Enter 接受默认位置，可选设置密码。

### 2. 启动 SSH 代理

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 3. 复制公钥到 GitHub

```bash
cat ~/.ssh/id_ed25519.pub
```

然后：
1. 访问 https://github.com/settings/keys
2. 点击 "New SSH key"
3. 粘贴公钥内容
4. 点击 "Add SSH key"

### 4. 测试连接

```bash
ssh -T git@github.com
```

看到 "Hi username! You've successfully authenticated" 即表示成功。

## 📤 推送后验证

推送成功后，您可以：

1. **访问仓库页面**：
   ```
   https://github.com/YOUR_USERNAME/ble_clock_syncer
   ```

2. **检查 GitHub Actions**：
   - 访问仓库的 "Actions" 标签页
   - 查看自动构建是否正在运行
   - 构建完成后可以下载 APK 文件

3. **创建 Release**（可选）：
   - 访问 "Releases" 页面
   - 点击 "Create a new release"
   - 填写版本号和说明
   - 发布后会自动附加 APK 文件

## 🔄 后续更新代码

修改代码后，使用以下命令推送更新：

```bash
# 查看修改状态
git status

# 添加修改的文件
git add .

# 提交修改
git commit -m "Your commit message"

# 推送到 GitHub
git push
```

## 🐛 常见问题

### Q: 推送失败，提示 "fatal: remote already exists"

A: 移除已存在的远程仓库后重新添加：

```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/ble_clock_syncer.git
git push -u origin main
```

### Q: 提示 "Permission denied (publickey)"

A: 您需要配置 SSH 密钥或使用 HTTPS 方式推送：

```bash
# 切换到 HTTPS
git remote set-url origin https://github.com/YOUR_USERNAME/ble_clock_syncer.git
```

### Q: 推送失败，提示 "Updates were rejected"

A: 远程仓库有新的提交，需要先拉取：

```bash
git pull --rebase origin main
git push -u origin main
```

### Q: 如何修改远程仓库地址？

A:

```bash
# 查看当前远程仓库
git remote -v

# 修改远程仓库地址
git remote set-url origin https://github.com/NEW_USERNAME/ble_clock_syncer.git
```

### Q: 如何克隆已存在的仓库？

A:

```bash
git clone https://github.com/YOUR_USERNAME/ble_clock_syncer.git
cd ble_clock_syncer
```

## 📚 相关资源

- [GitHub 官方文档](https://docs.github.com/)
- [Git 官方文档](https://git-scm.com/doc)
- [GitHub CLI 文档](https://cli.github.com/manual/)

## ✅ 检查清单

推送前确认：

- [ ] 已创建 GitHub 仓库
- [ ] 仓库名称为 `ble_clock_syncer`
- [ ] 仓库是 Public 或 Private（根据需要）
- [ ] 未初始化 README、.gitignore、LICENSE
- [ ] 已配置 Git 用户信息
- [ ] 本地代码已提交
- [ ] 远程仓库地址已正确设置
- [ ] 使用正确的分支名称（main）

推送后确认：

- [ ] 代码成功推送到 GitHub
- [ ] GitHub Actions 自动构建已触发
- [ ] README.md 正确显示
- [ ] 可以访问 Actions 页面
- [ ] 构建 Artifact 可以下载

## 🎉 完成！

代码已成功推送到 GitHub，GitHub Actions 会自动构建 APK 文件。您可以从 Actions 页面下载最新构建的 APK。
