# Archived posts

Markdown files in this folder are **archived**: `_archive` is listed under
`exclude` in `_config.yml`, so Jekyll never builds them and they don't appear on
the site (blog list, directory, categories, tags, or their own URL).

## Put a post back up

Move the file back into `_posts/`:

```bash
git mv _archive/2026-08-08-been-there-conquered-that.md _posts/
```

Then commit and push. That's it. The post's images already live in
`assets/img/posts/btct/` and were left in place, so nothing else needs restoring.

(This README isn't published either, since the whole folder is excluded.)
