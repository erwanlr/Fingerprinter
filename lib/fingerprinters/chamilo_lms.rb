
# Chamilo LMS
class ChamiloLms < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('chamilo/chamilo-lms')
  end
end
