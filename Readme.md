# mass cloner

Скрипт для клонирования репозиториев git.
Нужен php8.0

```bash
cat composer.lock | jq -r '.packages[].source.url' | php cloner.php
```

```bash
echo "https://github.com/doctrine/common.git
git@github.com:symfony/symfony.git" | php cloner.php
```
