# My Blog

https://rocast560.github.io

### Command to launch website locally when testing
```bash
bundle exec jekyll s
# open http://127.0.0.1:4000/
```

## Real posts vs. example/demo posts

This site keeps two kinds of posts apart so you can develop and test with fake
data without ever publishing it.

```
_posts/                     <-  REAL posts. These get published.
  2025-12-19-bruh-idk.md
  <your real posts go here>

_posts/examples/            <-  DEMO / example posts. Local testing only.
  2025-09-14-home-soc-wazuh-suricata.md
  2025-10-05-active-directory-attack-path.md
  ...
```

Everything in `_posts/examples/` (post, categories, tags) shows up on the Blog
page and in the Directory **only while you are testing locally**. When the site
is published for real, all of it disappears automatically.

### How the toggle works

The behavior is controlled by `show_examples` in `_config.yml`, checked in this
order:

1. **A single post** can override everything with front matter:
   - `example: true`  -> always treated as demo (hidden in production)
   - `example: false` -> always treated as real (published even from `examples/`)
2. **The `show_examples` flag** in `_config.yml`:
   - `show_examples: true`  -> always show demo posts
   - `show_examples: false` -> always hide demo posts
3. **If the flag is left commented out (the default):**
   - `jekyll serve` / local development -> demo posts **shown**
   - production build (GitHub Pages)    -> demo posts **hidden**

You normally don't touch anything: run it locally and you see the examples; push
it and visitors don't. The flag is just there for when you want to force it.

### Everyday commands

Local preview **with** the example data (the normal case):

```bash
bundle exec jekyll serve
# open http://127.0.0.1:4000/
```

Preview exactly what the **published** site will look like (no examples), without
pushing:

```bash
JEKYLL_ENV=production bundle exec jekyll serve
# or leave JEKYLL_ENV alone and set `show_examples: false` in _config.yml
```

Nothing changes about publishing: your GitHub Actions workflow already builds with
`JEKYLL_ENV: production`, so the live site never includes `_posts/examples/`.

### Adding your own

- **A real post:** create it directly in `_posts/` with the usual
  `YYYY-MM-DD-title.md` filename. It publishes like normal.
- **A throwaway/demo post:** drop it in `_posts/examples/` instead. Same filename
  format, same front matter (`title`, `date`, `categories`, `tags`,
  optional `description`). It will only appear locally.
- **Promoting a demo post to a real one:** move the file from `_posts/examples/`
  up into `_posts/` (or add `example: false` to its front matter). Done.

### How categories and tags fit in

Categories and tags travel with each post's front matter, so they follow the same
rule automatically. A category or tag that only exists on demo posts vanishes from
the Directory in production along with those posts; nothing else to configure.

The gating itself lives in `_plugins/example-posts.rb`.

## License

This work is published under [MIT][mit] License.

[gem]: https://rubygems.org/gems/jekyll-theme-chirpy
[chirpy]: https://github.com/cotes2020/jekyll-theme-chirpy/
[CD]: https://en.wikipedia.org/wiki/Continuous_deployment
[mit]: https://github.com/cotes2020/chirpy-starter/blob/master/LICENSE
