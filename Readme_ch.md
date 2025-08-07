# 目录和文件结构生成器

基于文本描述自动创建目录和文件结构的脚本工具

## 功能特点

- 根据描述自动创建目录和文件结构
- 支持在结构文件中添加注释
- 仅检查现有结构而不修改 (`--check-only`)
- 支持根目录操作 (`--use-root`)
- 静默模式 (`--silent`)
- 详细的执行统计信息
- 支持自定义结构文件

## 安装要求

1. 确保已安装 Python 3.6+ 版本
2. 将 `create_structure.py` 脚本复制到目标目录

## 使用说明

### 基本用法

```bash
python create_structure.py [结构文件] [选项]
```

若不指定结构文件，默认使用 `structure.txt`

### 选项参数

| 选项        | 说明                                                                 |
|--------------|----------------------------------------------------------------------|
| `--use-root` | 使用文件中第一行指定的根目录创建结构       |
| `--check-only` | 仅检查结构是否存在，不执行创建操作          |
| `--silent`   | 静默模式 (不显示创建过程信息)                         |

### 使用示例

1. 使用默认文件创建结构:
   ```bash
   python create_structure.py
   ```

2. 使用根目录创建结构:
   ```bash
   python create_structure.py --use-root
   ```

3. 仅检查结构是否存在:
   ```bash
   python create_structure.py --check-only my-structure.txt
   ```

4. 静默模式使用自定义文件:
   ```bash
   python create_structure.py custom-structure.txt --silent
   ```

## 结构文件格式

文件应采用树状结构描述，例如：

```
project-root/
│
├── docker-compose.yml
├── .env
│
├── db/
│   ├── Dockerfile
│   ├── init.sql
│   └── postgresql.conf
│
└── php/
     ├── src/                  # 两个服务共用的源代码
     └── composer.json         # 公共依赖项
```

### 格式规则:
- 目录以 `/` 结尾
- 文件不添加 `/` 
- 符号 `│`, `├──`, `└──` 仅用于格式化显示，会被忽略
- **注释说明**:
  - 可在任意行 `#` 后添加注释
  - `#` 后的所有内容将被忽略
  - 可用于结构说明

## 返回代码

- `0` - 执行成功
- `1` - 执行错误 (文件未找到，创建问题等)

## 日志输出

非静默模式下将显示:
- 已创建/已存在的目录和文件
- 执行统计信息
- 检查结果 (使用 `--check-only` 时)

## 🌍 Available Translations | Доступные переводы | 可用翻译
- 🇬🇧 [English](Readme.md) - English version  
- 🇷🇺 [Русский](Readme_ru.md) - Русская версия  
- 🇨🇳 [中文](Readme_ch.md) - 中文版本

## 开源许可

MIT 许可证
