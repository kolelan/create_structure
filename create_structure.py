import os
import argparse
from pathlib import Path


def parse_structure(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = [line.rstrip() for line in file.readlines() if line.strip()]

    # Игнорируем первые две строки или одна (строки 1 и 2)
    lines = lines[1:]

    structure = {}
    current_dir = []

    for line in lines:
        # Пропускаем пустые строки (строки 5, 10)
        if not line.strip():
            continue

        # Определяем уровень вложенности
        indent = 0
        while line.startswith('│   ') or line.startswith('    '):
            line = line[4:]
            indent += 1

        # Обновляем текущий путь на основе уровня вложенности
        current_dir = current_dir[:indent]

        # Обрабатываем строку
        if '├── ' in line:
            item = line.split('├── ')[1]
        elif '└── ' in line:
            item = line.split('└── ')[1]
        else:
            continue

        if item.endswith('/'):
            # Это директория (добавляем в путь)
            dir_name = item[:-1]
            current_dir.append(dir_name)
            full_path = os.path.join(*current_dir)
            structure[full_path] = 'dir'
        else:
            # Это файл (создаем в текущем пути)
            full_path = os.path.join(*current_dir, item)
            structure[full_path] = 'file'

            # Если это последний элемент в директории (└──), уменьшаем путь
            if '└── ' in line:
                current_dir = current_dir[:-1]

    return structure


def create_structure(structure, silent=False):
    for path, item_type in structure.items():
        if item_type == 'dir':
            os.makedirs(path, exist_ok=True)
            if not silent:
                print(f"Created directory: {path}/")
        elif item_type == 'file':
            Path(path).parent.mkdir(parents=True, exist_ok=True)
            Path(path).touch()
            if not silent:
                print(f"Created file: {path}")


def main():
    parser = argparse.ArgumentParser(description='Create directory structure from structure.txt')
    parser.add_argument('--silent', action='store_true', help='Suppress output')
    args = parser.parse_args()

    structure_file = 'structure.txt'
    if not os.path.exists(structure_file):
        print(f"Error: File '{structure_file}' not found in current directory")
        return

    structure = parse_structure(structure_file)
    create_structure(structure, args.silent)


if __name__ == '__main__':
    main()