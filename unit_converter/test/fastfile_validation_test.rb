#!/usr/bin/env ruby
# Ruby test suite for Fastfile validation
# Run with: ruby test/fastfile_validation_test.rb

require 'fileutils'
require 'json'

class FastfileValidator
  def initialize(fastfile_path)
    @fastfile_path = fastfile_path
    @content = File.read(fastfile_path)
    @errors = []
    @warnings = []
  end

  def run_all_tests
    test_dotenv_loading_function_exists
    test_dotenv_loading_called_at_startup
    test_hydrate_environment_value_function_exists
    test_admob_config_uses_hydrate_function
    test_check_for_test_ids_uses_hydrate_function
    test_deploy_internal_skips_changelogs
    test_deploy_production_skips_changelogs
    test_deploy_production_has_confirmation
    test_upload_screenshots_uses_temp_metadata
    test_upload_metadata_uses_temp_metadata

    print_results
  end

  private

  def test_dotenv_loading_function_exists
    if @content.include?('def load_project_dotenv')
      pass('load_project_dotenv function exists')
    else
      @errors << 'load_project_dotenv function is missing'
    end
  end

  def test_dotenv_loading_called_at_startup
    if @content.include?('load_project_dotenv')
      # Check if it's called after the function definition
      func_def = @content.index('def load_project_dotenv')
      func_call = @content.rindex('load_project_dotenv')

      if func_call && func_call > func_def
        pass('load_project_dotenv is called at startup')
      else
        @errors << 'load_project_dotenv function is defined but not called at startup'
      end
    else
      @errors << 'load_project_dotenv function does not exist'
    end
  end

  def test_hydrate_environment_value_function_exists
    if @content.include?('def hydrate_environment_value')
      pass('hydrate_environment_value function exists')
    else
      @errors << 'hydrate_environment_value function is missing'
    end
  end

  def test_admob_config_uses_hydrate_function
    if @content.include?('lane :validate_admob_config')
      # Check if the lane uses hydrate_environment_value
      lane_start = @content.index('lane :validate_admob_config')
      lane_end = @content.index('lane :', lane_start + 1) || @content.length

      lane_content = @content[lane_start..lane_end]

      if lane_content.include?('hydrate_environment_value')
        pass('validate_admob_config lane uses hydrate_environment_value')
      else
        @errors << 'validate_admob_config lane does not use hydrate_environment_value'
      end
    else
      @errors << 'validate_admob_config lane does not exist'
    end
  end

  def test_check_for_test_ids_uses_hydrate_function
    if @content.include?('lane :check_for_test_ids')
      lane_start = @content.index('lane :check_for_test_ids')
      lane_end = @content.index('lane :', lane_start + 1) || @content.length

      lane_content = @content[lane_start..lane_end]

      if lane_content.include?('hydrate_environment_value')
        pass('check_for_test_ids lane uses hydrate_environment_value')
      else
        @errors << 'check_for_test_ids lane does not use hydrate_environment_value'
      end
    else
      @errors << 'check_for_test_ids lane does not exist'
    end
  end

  def test_deploy_internal_skips_changelogs
    if @content.include?('lane :deploy_internal')
      lane_start = @content.index('lane :deploy_internal')
      lane_end = @content.index('lane :', lane_start + 1) || @content.length

      lane_content = @content[lane_start..lane_end]

      if lane_content.include?('skip_upload_changelogs: true')
        pass('deploy_internal lane skips changelog upload')
      else
        @errors << 'deploy_internal lane does not skip changelog upload'
      end
    else
      @errors << 'deploy_internal lane does not exist'
    end
  end

  def test_deploy_production_skips_changelogs
    if @content.include?('lane :deploy_production')
      lane_start = @content.index('lane :deploy_production')
      lane_end = @content.index('lane :', lane_start + 1) || @content.length

      lane_content = @content[lane_start..lane_end]

      if lane_content.include?('skip_upload_changelogs: true')
        pass('deploy_production lane skips changelog upload')
      else
        @errors << 'deploy_production lane does not skip changelog upload'
      end
    else
      @errors << 'deploy_production lane does not exist'
    end
  end

  def test_deploy_production_has_confirmation
    if @content.include?('lane :deploy_production')
      lane_start = @content.index('lane :deploy_production')
      lane_end = @content.index('lane :', lane_start + 1) || @content.length

      lane_content = @content[lane_start..lane_end]

      if lane_content.include?('UI.confirm') || lane_content.include?('UI.interactive?')
        pass('deploy_production lane has confirmation logic')
      else
        @errors << 'deploy_production lane does not have confirmation logic'
      end
    else
      @errors << 'deploy_production lane does not exist'
    end
  end

  def test_upload_screenshots_uses_temp_metadata
    if @content.include?('lane :upload_screenshots')
      lane_start = @content.index('lane :upload_screenshots')
      lane_end = @content.index('lane :', lane_start + 1) || @content.length

      lane_content = @content[lane_start..lane_end]

      if lane_content.include?('with_locale_metadata_root')
        pass('upload_screenshots lane uses with_locale_metadata_root helper')
      else
        @errors << 'upload_screenshots lane does not use with_locale_metadata_root helper'
      end
    else
      @errors << 'upload_screenshots lane does not exist'
    end
  end

  def test_upload_metadata_uses_temp_metadata
    if @content.include?('lane :upload_metadata')
      lane_start = @content.index('lane :upload_metadata')
      lane_end = @content.index('lane :', lane_start + 1) || @content.length

      lane_content = @content[lane_start..lane_end]

      if lane_content.include?('with_locale_metadata_root')
        pass('upload_metadata lane uses with_locale_metadata_root helper')
      else
        @errors << 'upload_metadata lane does not use with_locale_metadata_root helper'
      end
    else
      @errors << 'upload_metadata lane does not exist'
    end
  end

  def pass(message)
    puts "✅ PASS: #{message}"
  end

  def fail(message)
    puts "❌ FAIL: #{message}"
  end

  def warn(message)
    puts "⚠️  WARN: #{message}"
    @warnings << message
  end

  def print_results
    puts ''
    puts '=' * 50
    puts 'Fastfile Validation Results'
    puts '=' * 50

    if @errors.empty? && @warnings.empty?
      puts '✅ All tests passed!'
      exit 0
    else
      if !@errors.empty?
        puts ''
        puts "❌ Errors (#{@errors.length}):"
        @errors.each { |err| puts "  - #{err}" }
      end

      if !@warnings.empty?
        puts ''
        puts "⚠️  Warnings (#{@warnings.length}):"
        @warnings.each { |warn| puts "  - #{warn}" }
      end

      exit 1
    end
  end
end

# Main execution
if __FILE__ == $0
  # Determine Fastfile path
  fastfile_path = if File.exist?('android/fastlane/Fastfile')
                    'android/fastlane/Fastfile'
                  elsif File.exist?('fastlane/Fastfile')
                    'fastlane/Fastfile'
                  else
                    puts '❌ Fastfile not found in expected locations'
                    exit 1
                  end

  puts "Validating Fastfile: #{fastfile_path}"
  puts ''

  validator = FastfileValidator.new(fastfile_path)
  validator.run_all_tests
end
