module FeaturesHelper

  def self.feature_enabled?(feature)
    case feature
      when 'features.anacapa_repos'
        FeaturesHelper.anacapa_repos?
      else
        Setting["features.#{feature}"]
    end
  end

  def self.anacapa_repos?
    Setting['features.anacapa_repos']
  end
  def anacapa_repos?
    FeaturesHelper.anacapa_repos?
  end
end