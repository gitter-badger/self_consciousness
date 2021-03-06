require 'moneta'
require 'fileutils'
require 'colorize'

module SelfConsciousness
  def self.without_self_identity
    begin
      previously_enabled = SelfIdentity.enabled?
      SelfIdentity.disable
      yield if block_given?
      SelfIdentity.enable if previously_enabled
    rescue NameError => e
      yield if block_given?
    end
  end

  def self.normalize
    without_self_identity do
      FileUtils.mkdir_p '.self_consciousness'
      FileUtils.cp '.self_identity/dependencies', '.self_consciousness/dependencies'
    end
  end

  def self.clear
    without_self_identity do
      conscious = Moneta.new :File, dir: '.self_consciousness'
      conscious['dependencies'] = []
    end
  end

  def self.introspect
    without_self_identity do
      latest = Moneta.new :File, dir: '.self_identity'
      conscious = Moneta.new :File, dir: '.self_consciousness'
      conscious['removals'] = conscious['dependencies'] - latest['dependencies']
      conscious['additions'] = latest['dependencies'] - conscious['dependencies']
    end
  end

  def self.report
    without_self_identity do
      introspect
      conscious = Moneta.new :File, dir: '.self_consciousness'
      conscious['removals'].each { |item| puts "- #{item.to_s}".colorize(:red) }
      conscious['additions'].each { |item| puts "+ #{item.to_s}".colorize(:green) }
      puts 'Nothing has changed' if conscious['removals'].concat(conscious['additions']).empty?
    end
  end
end
