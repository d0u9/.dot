function ensure_directory_exists(dir_path)
    local command = string.format("mkdir -p %s", dir_path)
    os.execute(command)
end
