---
Title: Git
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-05-17
Modified: 2026-10-14
---

# Overview
## install git
```shell
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
```
## repository
### create repository
```shell
mkdir -p ~/selfRepository
cd ~/selfRepository
git init
```
### add items and update version
```shell
git add Readme.md
git commit -m "wrote a readme file"
```
### view git status to cheak items were be modified or not
```shell
git status
```
### view difference of new version with old version
```shell
git diff Readme.md
# view difference of Working Directory with stage
git diff HEAD -- Readme.md
```
### view history of version
```shell
git log
git log --pretty=oneline
```
### come back old version
```shell
git reset --hard HEAD^
git reset --hard <version id>
```
### view history of command line
```shell
git reflog
```
### 
* Working Directory
* Repository
	* stage / index
	* master
### unod Working Directory file modification
```shell
git checkout -- Readme.md
```
### undo stage file
```shell
git reset HEAD Readme.md
```
### delete file
```shell
git rm text,txt
git commit -m "remove test.txt"
```
### restore file that it was deleted
```shell
git checkout -- test.txt
```


```shell
# 配置用户名和email
git config --global user.name "XXXX XXX"
git config --global user.email XXXXX@gmail.com
# 保存账号及密码
git config --global credential.helper store
查看配置信息
git config --global --list
```
新建仓库
```shell
# 创建新仓库
git init [Repo name]
git clone https://..com
# 查看仓库状态
git status
# 添加新文件到暂存区
git add <filename>
# 添加当前文件夹下所有文件
git add .
# 将暂存区文件提交到仓库中
git commit -m "t提交信息（备注）"
# 查看提交记录
git log
# 查看操作记录
git reflog
# 查看暂存区文件
git ls-files
```
回退版本信息
```shell
# 回退版本并保留工作区和暂存区文件
git reset --soft
# 回退版本不保留工作区和暂存区文件
git reset --hard
# 回退版本并保留工作区文件，不保留暂存区（默认）
git reset --mixed
# ?
git reset --keep
# 回退到上一个版本
git reset --hard HEAD^
```
文件差异（常用GUI工具，git自带适合服务器）
```shell
# 默认比较工作区和暂存区差异
git diff
# 比较工作区+暂存区和本地仓库
git diff HEAD
# 比较暂存区和本地仓库
git diff --cached
# 提交版本差异
git diff xxxid1 xxxid2
git diff HEAD~2 HEAD
# 仅查看单个文件
git diff HEAD~2 HEAD <filename>
```
删除文件
```shell
# method 1
rm <filename>
git add .
git commoit -m "xxx"
# method 2
git rm <filename>
git commoit -m "xxx"

# 仅删除暂存区
git rm <filename> --cached
# 递归删除文件夹
git rm <filepath> -r
```
仓库忽略文件
创建".gitignore"文件，并将需要忽略的文件加入该文件
```shell
*.log
temp/
```
