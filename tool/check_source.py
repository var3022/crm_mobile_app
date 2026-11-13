"""Dependency-free source checks; this does not replace flutter analyze/test."""
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
errors = []
files = list((root / 'lib').rglob('*.dart')) + list((root / 'test').rglob('*.dart'))

def check_delimiters(source, path):
    def quoted(i, raw=False):
        quote = source[i]
        delim = quote * (3 if source[i:i+3] == quote * 3 else 1)
        i += len(delim)
        while i < len(source):
            if source.startswith(delim, i):
                return i + len(delim)
            if not raw and source[i] == '\\':
                i += 2
            elif not raw and source.startswith('${', i):
                i = code(i+2, '}')
            else:
                i += 1
        raise ValueError('unterminated string')

    def code(i=0, closing=None):
        while i < len(source):
            if source.startswith('//', i):
                end = source.find('\n', i)
                i = len(source) if end < 0 else end + 1
            elif source.startswith('/*', i):
                end = source.find('*/', i+2)
                if end < 0:
                    raise ValueError('unterminated comment')
                i = end+2
            elif source[i] in "'\"":
                i = quoted(i, i > 0 and source[i-1] == 'r')
            elif source[i] in '([{':
                i = code(i+1, {'(':')','[':']','{':'}'}[source[i]])
            elif source[i] in ')]}':
                if source[i] != closing:
                    line = source[:i].count('\n')+1
                    raise ValueError(f'line {line}: expected {closing}, found {source[i]}')
                return i+1
            else:
                i += 1
        if closing:
            raise ValueError(f'missing {closing}')
        return i
    try:
        code()
    except ValueError as e:
        errors.append(f'{path.relative_to(root)}: {e}')

for path in files:
    source = path.read_text(encoding='utf-8')
    check_delimiters(source, path)
    for imp in re.findall(r"(?:import|export)\s+['\"]([^'\"]+)['\"]", source):
        if ':' not in imp and not (path.parent / imp).resolve().is_file():
            errors.append(f'{path.relative_to(root)}: missing import {imp}')
    for asset in re.findall(r"['\"](assets/[^'\"]+\.(?:png|jpg|jpeg|svg))['\"]", source):
        if not (root / asset).is_file() or (root / asset).stat().st_size == 0:
            errors.append(f'{path.relative_to(root)}: missing or empty asset {asset}')

main = (root / 'lib/main.dart').read_text(encoding='utf-8')
routes = (root / 'lib/features/workspace/crm_routes.dart').read_text(encoding='utf-8')
known = set(re.findall(r'case [\'\"](/[^\'\"]+)[\'\"]', routes))
known.update(re.findall(r'[\'\"](/[^\'\"]*)[\'\"]\s*:\s*\(context\)', main))
known.update('/'+v for v in ['offline','syncing','server-error','session-expired','access-restricted','not-found','rate-limit','suspended','subscription-expired','maintenance'])
for path in (root/'lib/features/workspace').glob('*.dart'):
    source = path.read_text(encoding='utf-8')
    for target in re.findall(r"open\([^,]+,\s*['\"](/[^'\"]+)['\"]", source):
        if '$' not in target and target not in known:
            errors.append(f'{path.name}: unresolved route {target}')

print(f'Checked delimiters and local imports in {len(files)} Dart files, and {len(known)} named routes.')
if errors:
    print('\n'.join(errors))
    raise SystemExit(1)
print('Source checks passed. Flutter compilation and runtime tests are still required.')
