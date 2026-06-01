#!/usr/bin/env ruby

require "digest"
require "fileutils"

name = "validator-tool"
# system("eval \"$(ssh-agent -s)\" || true && ssh-add ~/.ssh/#{name} || true && git pull origin master")

cache_dir = ".build/deploy"
resolve_stamp = "#{cache_dir}/package-resolve.sha256"
resolve_inputs = ["Package.swift", "Package.resolved"]
package_hash = lambda do
  resolve_inputs
    .select { |path| File.exist?(path) }
    .map { |path| Digest::SHA256.file(path).hexdigest }
    .join(":")
end

FileUtils.mkdir_p(cache_dir)

if !File.exist?(resolve_stamp) || File.read(resolve_stamp) != package_hash.call
  abort("swift package resolve failed") unless system("swift package resolve")
  File.write(resolve_stamp, package_hash.call)
end

abort("swift build failed") unless system("swift build -c release -Xswiftc -Ounchecked -Xcc -O2")
# system("pkill -9 -f #{name}")
# system("/home/devton/swift/#{name}/.build/release/#{name} --env production > /home/devton/swift/#{name}/log.txt 2>&1")
