# Directory and File Structure Generator

A script for automatically creating directory and file structures based on a text description.

## Features

- Create directory and file structures from description
- Support for comments in structure files
- Check existing structure without modifications (`--check-only`)
- Work with root directory (`--use-root`)
- Silent mode (`--silent`)
- Detailed execution statistics
- Support for custom structure files

## Installation

1. Ensure you have Python 3.6+ installed
2. Copy the `create_structure.py` script to your desired directory

## Usage

### Basic Usage

```bash
python create_structure.py [structure_file] [options]
```

If no structure file is specified, `structure.txt` will be used by default.

### Options

| Option        | Description                                                                 |
|--------------|--------------------------------------------------------------------------|
| `--use-root` | Create and use root directory from the first line of the file       |
| `--check-only` | Only check structure existence without creating anything          |
| `--silent`   | Silent mode (suppress creation output)                         |

### Examples

1. Create structure from `structure.txt`:
   ```bash
   python create_structure.py
   ```

2. Create structure with root directory:
   ```bash
   python create_structure.py --use-root
   ```

3. Check structure existence:
   ```bash
   python create_structure.py --check-only my-structure.txt
   ```

4. Silent mode with custom file:
   ```bash
   python create_structure.py custom-structure.txt --silent
   ```

## Structure File Format

The file should contain structure description as a tree. Example:

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
     ├── src/                  # Shared source code for both services
     └── composer.json         # Common dependencies
```

### Rules:
- Directories end with `/`
- Files are specified without `/`
- Symbols `│`, `├──`, `└──` are used for formatting and are ignored
- **Comments**:
  - Can be added after `#` in any line
  - Everything after `#` is ignored by the script
  - Can be used for structure explanations

## Return Codes

- `0` - success
- `1` - error (file not found, creation problems)

## Logging

When `--silent` flag is not used, the script outputs:
- Created/existing directories and files
- Execution statistics
- Check results (in `--check-only` mode)

## 🌍 Available Translations | Доступные переводы | 可用翻译
- 🇬🇧 [English](Readme.md) - English version  
- 🇷🇺 [Русский](Readme_ru.md) - Русская версия  
- 🇨🇳 [中文](Readme_ch.md) - 中文版本

## License

MIT
