<?php

$baseDir = 'vendor-bak' . DIRECTORY_SEPARATOR;

while($line = fgets(STDIN)){
    $line = strtolower(trim($line));

    $repo = '';
    $dir = '';

    if (str_starts_with($line, 'http')) {
        echo "https: ", $line, PHP_EOL;

        $parts = parse_url($line);

        $host = trim($parts['host'], '/');
        $path = trim($parts['path'], '/');

        $dir = $host . DIRECTORY_SEPARATOR . substr($path, 0, -4);

        $repo = "git@{$host}:$path";

    } elseif (str_starts_with($line, 'git@')) {
        echo "git: ", $line, PHP_EOL;

        $repo = $line;

        $dir = str_replace(':', DIRECTORY_SEPARATOR, substr($line, 4, -4));
    } else {
        echo "error: {$line}", PHP_EOL;
        continue;
    }

    if (empty($repo) || empty($dir)) {
        echo "error: {$line}", PHP_EOL;
    }

    $fullPath = $baseDir . $dir;
    if (! is_dir($fullPath)) {

        $containDir = substr($fullPath, 0, strrpos($fullPath, '/'));
        if (! @mkdir($containDir, 0777, true) && ! @is_dir($containDir)) {
            throw new \RuntimeException(sprintf('Directory "%s" was not created', $containDir));
        }
        echo "Cloning repo ${repo}", PHP_EOL;
        shell_exec("cd ${containDir} && git clone ${repo}");
    } else {
        echo "Fetching repo ${repo}", PHP_EOL;
        shell_exec("cd ${fullPath} && git fetch --all --prune");
    }
}