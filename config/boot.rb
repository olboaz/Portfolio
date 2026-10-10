ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup'

require 'logger'
require 'bootsnap/setup'

require 'yaml'

module WebpackerPsychCompatibility
  def load(yaml, **options)
    if yaml.is_a?(String) &&
       yaml.include?('source_entry_path: packs') &&
       yaml.include?('public_output_path: packs')
      super(yaml, **options.merge(aliases: true))
    else
      super
    end
  end
end

Psych.singleton_class.prepend(WebpackerPsychCompatibility)
