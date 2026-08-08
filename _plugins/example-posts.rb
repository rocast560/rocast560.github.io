# frozen_string_literal: true
#
# Example / demo post gating
# ==========================
#
# Any post whose file lives under `_posts/examples/` is treated as demo data:
# something you want to look at while building the site locally, but that should
# never appear on the real, published site.
#
# Whether those demo posts are kept or dropped is decided here, in this order:
#
#   1. A post can force its own state with front matter `example: true`
#      (always demo) or `example: false` (always real), overriding everything
#      below. Handy for toggling a single post without moving the file.
#
#   2. The site-wide `show_examples` flag in _config.yml:
#        show_examples: true   -> always show demo posts
#        show_examples: false  -> always hide demo posts
#
#   3. If the flag is not set (the default), it follows the build environment:
#        `jekyll serve`  / local dev  (JEKYLL_ENV=development) -> shown
#        production build (JEKYLL_ENV=production)               -> hidden
#
# Dropping the posts here, in a `:site, :post_read` hook, means it happens
# before categories, tags, archives, the blog page and the directory are built,
# so demo data disappears from ALL of them at once - not just the post list.

module ExamplePosts
  EXAMPLE_DIR = "_posts/examples/"

  # Is this document one of the demo posts?
  def self.example?(post)
    return post.data["example"] if post.data.key?("example")

    # relative_path can use "\" on Windows; normalise before matching.
    post.relative_path.to_s.tr("\\", "/").include?(EXAMPLE_DIR)
  end

  # Should demo posts be included in this build?
  def self.keep?(site)
    flag = site.config["show_examples"]
    return flag if flag == true || flag == false

    Jekyll.env != "production"
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  next if ExamplePosts.keep?(site)

  docs = site.posts.docs
  before = docs.size
  docs.reject! { |post| ExamplePosts.example?(post) }
  removed = before - docs.size

  if removed.positive?
    Jekyll.logger.info "Examples:",
                       "hid #{removed} demo post(s) " \
                       "(show_examples=#{site.config['show_examples'].inspect}, env=#{Jekyll.env})"
  end
end
