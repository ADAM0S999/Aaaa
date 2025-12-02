Simple static site for the restaurant mockup.

Preview locally:

1) From repository root run:

```bash
python3 -m http.server 8001 --directory site
```

2) Open in browser:

http://127.0.0.1:8001

Notes:
- The site uses images from `/images/` generated earlier. Ensure `images/` exists at repository root.
- To customize name, texts, or colors, edit `site/index.html` and `site/styles.css`.
