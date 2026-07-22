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

destinations = {}
agent_lanes = {}
installations.each do |entry|
  abort "agent manifest entry must be a map" unless entry.is_a?(Hash)
  abort "agent manifest entry has unsupported fields" unless (entry.keys - %w[agent lane source destination]).empty?

  agent, lane, source, destination = %w[agent lane source destination].map { |key| entry[key].to_s }
  abort "agent manifest entry has an empty field" if [agent, lane, source, destination].any?(&:empty?)
  abort "agent manifest entry contains control characters" if [agent, lane, source, destination].any? { |value| value.match?(/[\t\r\n]/) }
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

  destinations[destination] = true
  agent_lanes[[agent, lane]] = true
end

librarian_lanes = installations.map { |entry| entry["lane"] if entry["agent"] == "knowledge-librarian" }.compact.sort
abort "knowledge-librarian must be declared exactly once for claude, codex, and cursor" unless librarian_lanes == allowed_lanes.sort

if selected_lane
  installations.each do |entry|
    next unless selected_lane == "all" || entry["lane"] == selected_lane

    puts %w[agent lane source destination].map { |key| entry[key] }.join("\t")
  end
end
