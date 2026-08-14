#!/usr/bin/env ruby
# Validates optional per-skill sidecar metadata (skills/<name>/metadata.yaml)
# and eval cases (skills/<name>/evals/cases.yaml) against the v1 contract in
# docs/specs/2026-08-14-skill-metadata-evals-design.md.
#
# Called from scripts/validate-skills.sh. Prints one problem per line to
# stdout (prefixed with the offending path); prints nothing when everything
# is valid. Exit 0 = scan completed (problems, if any, were printed);
# exit 2 = infrastructure error (bad root, unreadable tree).
require "yaml"
require "date"

root = File.expand_path(ARGV[0] || File.join(__dir__, ".."))
skills_dir = File.join(root, "skills")
adapters_dir = File.join(root, "adapters")

unless Dir.exist?(skills_dir) && Dir.exist?(adapters_dir)
  warn "validate-skill-metadata: missing skills/ or adapters/ under #{root}"
  exit 2
end

allowed_lanes = Dir.children(adapters_dir).select { |c| File.directory?(File.join(adapters_dir, c)) }.sort

METADATA_KEYS = %w[schema_version owner version supported_lanes maturity evaluation known_failure_modes].freeze
EVALUATION_KEYS = %w[case_file last_evaluated status pass_rate].freeze
CASE_KEYS = %w[id dimension scenario expected].freeze
MATURITIES = %w[experimental beta stable].freeze
EVAL_STATUSES = %w[not_run passing failing partial].freeze
DIMENSIONS = %w[
  activation_correctness
  instruction_compliance
  false_completion
  evidence_quality
  unnecessary_invocation
].freeze

problems = []

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date], aliases: false)
rescue Psych::SyntaxError => e
  e
end

def date_like?(value)
  return true if value.is_a?(Date)
  value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}\z/) && (Date.iso8601(value) rescue nil)
end

Dir.children(skills_dir).sort.each do |skill_name|
  skill_dir = File.join(skills_dir, skill_name)
  next unless File.directory?(skill_dir)

  rel = "skills/#{skill_name}"
  metadata_path = File.join(skill_dir, "metadata.yaml")
  evals_dir = File.join(skill_dir, "evals")
  has_metadata = File.file?(metadata_path)

  # Orphan rules: evals/ and metadata.yaml are paired.
  if Dir.exist?(evals_dir) && !has_metadata
    problems << "#{rel}/evals: present without metadata.yaml (orphan eval directory)"
  end
  next unless has_metadata

  meta = load_yaml(metadata_path)
  if meta.is_a?(Psych::SyntaxError)
    problems << "#{rel}/metadata.yaml: unparseable YAML (#{meta.message})"
    next
  end
  unless meta.is_a?(Hash)
    problems << "#{rel}/metadata.yaml: top level must be a mapping"
    next
  end

  (meta.keys - METADATA_KEYS).each { |k| problems << "#{rel}/metadata.yaml: unknown key '#{k}'" }
  (METADATA_KEYS - meta.keys).each { |k| problems << "#{rel}/metadata.yaml: missing key '#{k}'" }

  unless meta["schema_version"] == 1
    problems << "#{rel}/metadata.yaml: schema_version must be 1 (got #{meta["schema_version"].inspect})"
  end
  unless meta["owner"].is_a?(String) && !meta["owner"].strip.empty?
    problems << "#{rel}/metadata.yaml: owner must be a non-empty string"
  end
  unless meta["version"].is_a?(String) && meta["version"].match?(/\A\d+\.\d+\.\d+\z/)
    problems << "#{rel}/metadata.yaml: version must be semver x.y.z (got #{meta["version"].inspect})"
  end

  lanes = meta["supported_lanes"]
  if !lanes.is_a?(Array) || lanes.empty? || lanes.any? { |l| !l.is_a?(String) }
    problems << "#{rel}/metadata.yaml: supported_lanes must be a non-empty list of strings"
  else
    (lanes - allowed_lanes).each do |lane|
      problems << "#{rel}/metadata.yaml: lane '#{lane}' has no adapters/#{lane}/ directory (allowed: #{allowed_lanes.join(", ")})"
    end
    problems << "#{rel}/metadata.yaml: duplicate lanes" if lanes.uniq.length != lanes.length
  end

  maturity = meta["maturity"]
  unless MATURITIES.include?(maturity)
    problems << "#{rel}/metadata.yaml: maturity must be one of #{MATURITIES.join("|")} (got #{maturity.inspect})"
  end

  failure_modes = meta["known_failure_modes"]
  if !failure_modes.is_a?(Array) || failure_modes.any? { |m| !m.is_a?(String) || m.strip.empty? }
    problems << "#{rel}/metadata.yaml: known_failure_modes must be a list of non-empty strings (may be empty)"
  end

  evaluation = meta["evaluation"]
  unless evaluation.is_a?(Hash)
    problems << "#{rel}/metadata.yaml: evaluation must be a mapping"
    next
  end
  (evaluation.keys - EVALUATION_KEYS).each { |k| problems << "#{rel}/metadata.yaml: unknown evaluation key '#{k}'" }
  (EVALUATION_KEYS - evaluation.keys).each { |k| problems << "#{rel}/metadata.yaml: missing evaluation key '#{k}'" }

  status = evaluation["status"]
  unless EVAL_STATUSES.include?(status)
    problems << "#{rel}/metadata.yaml: evaluation.status must be one of #{EVAL_STATUSES.join("|")} (got #{status.inspect})"
  end

  last_evaluated = evaluation["last_evaluated"]
  pass_rate = evaluation["pass_rate"]
  if status == "not_run"
    problems << "#{rel}/metadata.yaml: status not_run requires last_evaluated: null" unless last_evaluated.nil?
    problems << "#{rel}/metadata.yaml: status not_run requires pass_rate: null" unless pass_rate.nil?
  elsif EVAL_STATUSES.include?(status)
    unless date_like?(last_evaluated)
      problems << "#{rel}/metadata.yaml: status #{status} requires last_evaluated as YYYY-MM-DD"
    end
    unless pass_rate.is_a?(Numeric) && pass_rate >= 0 && pass_rate <= 1
      problems << "#{rel}/metadata.yaml: status #{status} requires pass_rate in [0, 1]"
    end
  end

  if maturity == "stable" && status != "passing"
    problems << "#{rel}/metadata.yaml: maturity stable requires evaluation.status passing (a stable claim needs a recorded passing eval)"
  end

  case_file = evaluation["case_file"]
  unless case_file.is_a?(String) && !case_file.strip.empty?
    problems << "#{rel}/metadata.yaml: evaluation.case_file must be a non-empty relative path"
    next
  end
  cases_path = File.expand_path(case_file, skill_dir)
  unless cases_path.start_with?(skill_dir + File::SEPARATOR) && File.file?(cases_path)
    problems << "#{rel}/metadata.yaml: evaluation.case_file '#{case_file}' does not resolve to a file inside the skill directory"
    next
  end

  # Every yaml under evals/ must be the referenced case file (v1: one file).
  if Dir.exist?(evals_dir)
    Dir.glob(File.join(evals_dir, "**", "*.{yaml,yml}")).sort.each do |f|
      next if File.identical?(f, cases_path)
      problems << "#{rel}/evals/#{File.basename(f)}: not referenced by metadata.yaml evaluation.case_file (orphan)"
    end
  end

  cases_doc = load_yaml(cases_path)
  cases_rel = "#{rel}/#{case_file}"
  if cases_doc.is_a?(Psych::SyntaxError)
    problems << "#{cases_rel}: unparseable YAML (#{cases_doc.message})"
    next
  end
  unless cases_doc.is_a?(Hash)
    problems << "#{cases_rel}: top level must be a mapping"
    next
  end

  (cases_doc.keys - %w[schema_version skill cases]).each { |k| problems << "#{cases_rel}: unknown key '#{k}'" }
  unless cases_doc["schema_version"] == 1
    problems << "#{cases_rel}: schema_version must be 1 (got #{cases_doc["schema_version"].inspect})"
  end
  unless cases_doc["skill"] == skill_name
    problems << "#{cases_rel}: skill must be '#{skill_name}' (got #{cases_doc["skill"].inspect})"
  end

  cases = cases_doc["cases"]
  unless cases.is_a?(Array) && !cases.empty?
    problems << "#{cases_rel}: cases must be a non-empty list"
    next
  end

  seen_ids = {}
  covered_dimensions = []
  cases.each_with_index do |kase, idx|
    label = "#{cases_rel}: cases[#{idx}]"
    unless kase.is_a?(Hash)
      problems << "#{label}: must be a mapping"
      next
    end
    (kase.keys - CASE_KEYS).each { |k| problems << "#{label}: unknown key '#{k}'" }

    id = kase["id"]
    if !id.is_a?(String) || !id.match?(/\A[a-z0-9-]+\z/)
      problems << "#{label}: id must match ^[a-z0-9-]+$ (got #{id.inspect})"
    elsif seen_ids[id]
      problems << "#{label}: duplicate id '#{id}'"
    else
      seen_ids[id] = true
    end

    dimension = kase["dimension"]
    if DIMENSIONS.include?(dimension)
      covered_dimensions << dimension
    else
      problems << "#{label}: dimension must be one of #{DIMENSIONS.join("|")} (got #{dimension.inspect})"
    end

    %w[scenario expected].each do |field|
      value = kase[field]
      unless value.is_a?(String) && !value.strip.empty?
        problems << "#{label}: #{field} must be a non-empty string"
      end
    end
  end

  (DIMENSIONS - covered_dimensions.uniq).each do |dim|
    problems << "#{cases_rel}: no case covers dimension '#{dim}' (v1 requires all five)"
  end
end

puts problems unless problems.empty?
