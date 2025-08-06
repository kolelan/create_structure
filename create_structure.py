import os
import argparse
from pathlib import Path


def find_root_directory(file_path):
    """Находит имя корневой директории в файле"""
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            line = line.strip()
            if line and not all(c in ['│', ' ', '├', '└', '─', 'в”‚', 'в”њ', 'в”Ђ', 'в”'] for c in line):
                if line.endswith('/'):
                    return line[:-1]
    return None


def parse_structure(file_path, is_root_used=False):
    """Парсит структуру файла с учетом использования корневой директории"""
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = [line.rstrip() for line in file.readlines()]

    structure = {}
    current_dir = []
    root_processed = False

    for line in lines:
        # Пропускаем декоративные строки
        line_stripped = line.strip()
        if not line_stripped or all(c in ['│', ' ', '├', '└', '─', 'в”‚', 'в”њ', 'в”Ђ', 'в”'] for c in line_stripped):
            continue

        # Пропускаем корневую директорию если она уже обработана (при --use-root)
        if not root_processed and line_stripped.endswith('/'):
            root_processed = True
            if not is_root_used:
                continue  # Пропускаем корень если не используем --use-root
            else:
                continue  # Корень уже создан, пропускаем

        # Определяем уровень вложенности
        indent = 0
        while line.startswith('│   ') or line.startswith('    '):
            line = line[4:]
            indent += 1

        current_dir = current_dir[:indent]

        # Обрабатываем элементы структуры
        if '├── ' in line:
            item = line.split('├── ')[1].strip()
        elif '└── ' in line:
            item = line.split('└── ')[1].strip()
        else:
            item = line_stripped
            if not item.endswith('/'):
                continue

        if item.endswith('/'):
            dir_name = item[:-1]
            current_dir.append(dir_name)
            full_path = os.path.join(*current_dir)
            structure[full_path] = 'dir'
        else:
            full_path = os.path.join(*current_dir, item)
            structure[full_path] = 'file'

            if '└── ' in line:
                current_dir = current_dir[:-1]

    return structure


def create_structure(structure, base_dir='', silent=False):
    """Создает файлы и директории с подсчетом статистики"""
    dirs_created = 0
    files_created = 0
    existing_dirs = 0
    existing_files = 0

    for path, item_type in structure.items():
        full_path = os.path.join(base_dir, path) if base_dir else path

        if item_type == 'dir':
            if not os.path.exists(full_path):
                os.makedirs(full_path, exist_ok=True)
                dirs_created += 1
                if not silent:
                    print(f"Created directory: {full_path}/")
            else:
                existing_dirs += 1
                if not silent:
                    print(f"Directory exists: {full_path}/")
        elif item_type == 'file':
            parent_dir = os.path.dirname(full_path)
            if parent_dir and not os.path.exists(parent_dir):
                os.makedirs(parent_dir, exist_ok=True)
                dirs_created += 1
                if not silent:
                    print(f"Created parent directory: {parent_dir}/")

            if not os.path.exists(full_path):
                Path(full_path).touch()
                files_created += 1
                if not silent:
                    print(f"Created file: {full_path}")
            else:
                existing_files += 1
                if not silent:
                    print(f"File exists: {full_path}")

    if not silent:
        print("\nStatistics:")
        print(f"Directories created: {dirs_created}")
        print(f"Files created: {files_created}")
        print(f"Existing directories: {existing_dirs}")
        print(f"Existing files: {existing_files}")

    return dirs_created, files_created


def main():
    parser = argparse.ArgumentParser(description='Create directory structure from file')
    parser.add_argument('structure_file', nargs='?', default='structure.txt',
                        help='File with structure definition (default: structure.txt)')
    parser.add_argument('--silent', action='store_true', help='Suppress output')
    parser.add_argument('--use-root', action='store_true',
                        help='Create root directory and build inside it')
    args = parser.parse_args()

    # Проверяем существование файла со структурой
    if not os.path.exists(args.structure_file):
        print(f"Error: File '{args.structure_file}' not found")
        return

    # Определяем корневую директорию
    root_dir_name = find_root_directory(args.structure_file)
    base_dir = ''

    if args.use_root:
        if not root_dir_name:
            print("Error: Root directory not found in structure file")
            return

        base_dir = root_dir_name
        if not os.path.exists(base_dir):
            os.makedirs(base_dir, exist_ok=True)
            if not args.silent:
                print(f"Created root directory: {base_dir}/")
        else:
            if not args.silent:
                print(f"Using existing root directory: {base_dir}/")

    # Парсим структуру (учитываем использование корня)
    structure = parse_structure(args.structure_file, args.use_root)
    dirs_created, files_created = create_structure(structure, base_dir, args.silent)

    if not args.silent:
        print("\nOperation completed successfully!")


if __name__ == '__main__':
    main()