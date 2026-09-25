#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

manifest_path = ARGV[0]
abort "Usage: ruby scripts/validate-agent-manifest.rb <manifest> [lane]" if manifest_path.to_s.empty?

selected_lane = ARGV[1]
allowed_lanes = %w[claude codex cursor].freeze
abort "unsupported lane: #{selected_lane}" if selected_lane && selected_lane != "all" && !allowed_lanes.include?(selected_lane)

begin
  data = YAML.safe_load(File.read(manifest_path), permitted_classes: [], permitted_symbols: [], aliases: false) || {}
rescue Errno::ENOENT, Psych::Exception => e
  abort "invalid agent manifest: #{e.message}"
end
abort "manifest must be a map" unless data.is_a?(Hash)
abort "unsupported agent manifest schema" unless data["schema_version"] == 1
abort "manifest contains unsupported top-level fields" unless (data.keys - %w[schema_version installations]).empty?

installations = data["installations"]
abort "agent manifest installations must be a non-empty array" unless installations.is_a?(Array) && !installations.empty?

layouts = {
  "claude" => [/\Aadapters\/claude\/agents\/([a-z0-9-]+)\.md\z/, /\A\.claude\/agents\/([a-z0-9-]+)\.md\z/],
  "codex" => [/\Aadapters\/codex\/agents\/([a-z0-9-]+)\.toml\z/, /\A\.codex\/agents\/([a-z0-9-]+)\.toml\z/],
  "cursor" => [/\Aadapters\/cursor\/agents\/([a-z0-9-]+)\.md\z/, /\A\.cursor\/agents\/([a-z0-9-]+)\.md\z/]
}.freeze

root_dir = File.expand_path("..", __dir__)

def adapter_identity(path, lane)
  content = File.read(path, encoding: "UTF-8")
  if %w[claude cursor].include?(lane)
    frontmatter = content.match(/\A---[ \t]*\r?\n(.*?)^---[ \t]*\r?$/m)
    return ["missing", "missing frontmatter"] unless frontmatter

    begin
      metadata = YAML.safe_load(frontmatter[1], permitted_classes: [], permitted_symbols: [], aliases: false)
    rescue Psych::Exception => e
      return ["invalid", "invalid frontmatter: #{e.message.lines.first.strip}"]
    end
    return ["invalid", "invalid frontmatter map"] unless metadata.is_a?(Hash)
    return ["missing", "missing name"] unless metadata.key?("name")

    identity = metadata["name"]
  else
    # Codex declares its identity as a top-level TOML name. Stop at tables or
    # multiline values so content inside instructions cannot impersonate it.
    names = []
    content.each_line do |line|
      stripped = line.strip
      next if stripped.empty? || stripped.start_with?("#")
      break if stripped.start_with?("[") || stripped.match?(/=\s*(?:"""|''')/)
      next unless stripped.match?(/\Aname\s*=/)

      match = stripped.match(/\Aname\s*=\s*(?:"([a-z0-9-]+)"|'([a-z0-9-]+)')\s*(?:#.*)?\z/)
      return ["invalid", "invalid name"] unless match

      names << (match[1] || match[2])
    end
    return ["missing", "missing name"] if names.empty?
    return ["invalid", "duplicate name"] if names.length != 1

    identity = names.first
  end

  return ["invalid", "invalid name"] unless identity.is_a?(String) && identity.match?(/\A[a-z0-9][a-z0-9-]*\z/)

  [identity, nil]
rescue Errno::ENOENT, Errno::EACCES => e
  ["missing", e.message]
end

destinations = {}
agent_lanes = {}
installations.each do |entry|
  abort "agent manifest entry must be a map" unless entry.is_a?(Hash)
  abort "agent manifest entry has unsupported fields" unless (entry.keys - %w[agent lane source destination mode]).empty?

  agent, lane, source, destination = %w[agent lane source destination].map { |key| entry[key].to_s }
  mode = entry.fetch("mode", "symlink").to_s
  abort "agent manifest entry has an empty field" if [agent, lane, source, destination].any?(&:empty?)
  abort "agent manifest entry contains control characters" if [agent, lane, source, destination].any? { |value| value.match?(/[\t\r\n]/) }
  abort "unsupported install mode for #{lane}/#{agent}: #{mode}" unless %w[symlink copy].include?(mode)
  abort "invalid agent name: #{agent}" unless agent.match?(/\A[a-z0-9][a-z0-9-]*\z/)

  layout = layouts[lane]
  abort "unsupported agent lane: #{lane}" unless layout
  source_match = layout[0].match(source)
  destination_match = layout[1].match(destination)
  abort "invalid source for #{lane}/#{agent}: #{source}" unless source_match
  abort "invalid destination for #{lane}/#{agent}: #{destination}" unless destination_match
  abort "agent/source/destination names must match for #{lane}/#{agent}" unless source_match[1] == agent && destination_match[1] == agent
  abort "duplicate destination: #{destination}" if destinations[destination]
  abort "duplicate agent/lane: #{agent}/#{lane}" if agent_lanes[[agent, lane]]

  identity, identity_error = adapter_identity(File.join(root_dir, source), lane)
  if identity_error || identity != agent
    abort "adapter identity mismatch for #{lane}/#{agent} at #{source}: internal identity #{identity}#{identity_error ? " (#{identity_error})" : ""}"
  end

  destinations[destination] = true
  agent_lanes[[agent, lane]] = true
end

librarian_lanes = installations.map { |entry| entry["lane"] if entry["agent"] == "knowledge-librarian" }.compact.sort
abort "knowledge-librarian must be declared exactly once for claude, codex, and cursor" unless librarian_lanes == allowed_lanes.sort

if selected_lane
  installations.each do |entry|
    next unless selected_lane == "all" || entry["lane"] == selected_lane

    puts [entry["agent"], entry["lane"], entry["source"], entry["destination"], entry.fetch("mode", "symlink")].join("\t")
  end
end
