task :statsetup do
    require 'code_statistics'
    ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
    ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
    ::STATS_DIRECTORIES << %w(Observer\ specs spec/observers) if File.exist?('spec/observers')
    ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
    ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
    ::STATS_DIRECTORIES << %w(Cucumber\ features features) if File.exist?('features')
    ::CodeStatistics::TEST_TYPES << "Cucumber features" if File.exist?('features')
    ::STATS_DIRECTORIES << %w(Factory\ specs lib/test/factories) if File.exist?('lib/test/factories')
    ::CodeStatistics::TEST_TYPES << "Factory specs" if File.exist?('lib/test/factories')
end