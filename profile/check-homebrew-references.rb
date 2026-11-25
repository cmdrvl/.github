#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

profile_dir = Pathname.new(__dir__)
tap_dir = Pathname.new(ARGV.fetch(0) { profile_dir.join("../../homebrew-tap").cleanpath.to_s })
formula_dir = tap_dir.join("Formula")
formulae = formula_dir.glob("*.rb").map { |path| path.basename(".rb").to_s }.sort
raise "No Homebrew formulae found in #{formula_dir}" if formulae.empty?

references = profile_dir.glob("*.md").flat_map do |path|
  path.read.scan(%r{cmdrvl/tap/(?:\{([a-z0-9,-]+)\}|([a-z0-9-]+))}).flat_map do |brace, literal|
    names = brace ? brace.split(",") : [literal]
    names.map { |name| [path.basename.to_s, name] }
  end
end

unknown = references.reject { |_path, name| formulae.include?(name) }
unless unknown.empty?
  details = unknown.map { |path, name| "#{path}: cmdrvl/tap/#{name}" }.join(", ")
  abort "Unknown Homebrew formula references: #{details}"
end

puts "Checked #{references.length} Homebrew formula references against #{formulae.length} tap formulae."
