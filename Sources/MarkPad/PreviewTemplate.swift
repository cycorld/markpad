import Foundation

enum PreviewTemplate {
    /// The page shell. `vendorURL` is the `markpad://` directory holding katex/, mermaid/ and highlight/.
    static func page(vendorURL: String) -> String {
        let json = (try? JSONEncoder().encode(vendorURL)).flatMap { String(data: $0, encoding: .utf8) } ?? "\"\""
        return template.replacingOccurrences(of: "__VENDOR__", with: json)
    }

    private static let template = """
    <!doctype html>
    <html>
    <head>
    <meta charset="utf-8">
    <style>
    :root {
      color-scheme: light dark;
      --fg: #1f2328; --bg: #ffffff; --muted: #59636e; --border: #d8dee4;
      --code-bg: #f6f8fa; --link: #0969da; --quote: #57606a; --mark: #fff8c5; --error: #d1242f;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --fg: #e6edf3; --bg: #1e1e1e; --muted: #9198a1; --border: #3d444d;
        --code-bg: #2a2a2a; --link: #4493f8; --quote: #9198a1; --mark: #5a4a00; --error: #ff7b72;
      }
    }
    * { box-sizing: border-box; }
    html, body { margin: 0; background: var(--bg); color: var(--fg); }
    body {
      font: 15px/1.65 -apple-system, BlinkMacSystemFont, "SF Pro Text", "Apple SD Gothic Neo", "Helvetica Neue", sans-serif;
      -webkit-font-smoothing: antialiased;
      word-wrap: break-word;
    }
    #c { max-width: 780px; margin: 0 auto; padding: 28px 36px 96px; }
    #c > :first-child { margin-top: 0; }
    h1, h2, h3, h4, h5, h6 { margin: 1.6em 0 .6em; line-height: 1.3; font-weight: 650; letter-spacing: -0.01em; }
    h1 { font-size: 2em; padding-bottom: .3em; border-bottom: 1px solid var(--border); }
    h2 { font-size: 1.5em; padding-bottom: .25em; border-bottom: 1px solid var(--border); }
    h3 { font-size: 1.25em; } h4 { font-size: 1.05em; } h5, h6 { font-size: 1em; color: var(--muted); }
    p, ul, ol, blockquote, pre, table { margin: 0 0 1em; }
    a { color: var(--link); text-decoration: none; }
    a:hover { text-decoration: underline; }
    ul, ol { padding-left: 1.8em; }
    li + li { margin-top: .2em; }
    li > p { margin: 0 0 .3em; }
    li:has(> input[type=checkbox]) { list-style: none; margin-left: -1.4em; }
    li > input[type=checkbox] { margin: 0 .5em 0 0; vertical-align: -1px; }
    li > input[type=checkbox] + p { display: inline; }
    blockquote { margin-left: 0; padding: .1em 1em; border-left: 4px solid var(--border); color: var(--quote); }
    blockquote > :last-child { margin-bottom: 0; }
    hr { border: 0; height: 1px; background: var(--border); margin: 2em 0; }
    code, pre { font-family: "SF Mono", Menlo, ui-monospace, monospace; font-size: 13px; }
    code { background: var(--code-bg); padding: .15em .4em; border-radius: 5px; }
    pre { background: var(--code-bg); padding: 14px 16px; border-radius: 8px; overflow-x: auto; line-height: 1.5; }
    pre code { background: none; padding: 0; }
    table { border-collapse: collapse; display: block; overflow-x: auto; max-width: 100%; }
    th, td { border: 1px solid var(--border); padding: 6px 12px; text-align: left; }
    th { font-weight: 600; background: var(--code-bg); }
    img { max-width: 100%; height: auto; border-radius: 6px; }
    mark { background: var(--mark); color: inherit; }
    del { color: var(--muted); }
    ::selection { background: rgba(9, 105, 218, .25); }
    .math-display { display: block; text-align: center; margin: 1em 0; overflow-x: auto; }
    .katex-display { margin: 0; }
    .mermaid { margin: 0 0 1em; text-align: center; }
    .mermaid svg { max-width: 100%; height: auto; }
    .mermaid-error { margin: 0 0 1em; padding: 14px 16px; border-radius: 8px; background: var(--code-bg);
      color: var(--error); font-family: "SF Mono", Menlo, ui-monospace, monospace; font-size: 13px; white-space: pre-wrap; }
    pre code.hljs { padding: 0; background: transparent; }
    nav.toc { margin: 0 0 1.5em; padding: 12px 18px; background: var(--code-bg); border-radius: 8px; font-size: .95em; }
    nav.toc ul { list-style: none; margin: 0; padding-left: 1.2em; }
    nav.toc > ul { padding-left: 0; }
    nav.toc li { margin: .2em 0; }
    nav.toc:empty { display: none; }
    @media print {
      :root { --fg: #1f2328; --bg: #ffffff; --muted: #59636e; --border: #d8dee4; --code-bg: #f6f8fa;
              --link: #0969da; --quote: #57606a; --mark: #fff8c5; --error: #d1242f; }
      body { -webkit-print-color-adjust: exact; print-color-adjust: exact; font-size: 11pt; }
      #c { max-width: none; padding: 0; }
      pre, table, blockquote, img, .mermaid, .math-display, nav.toc { break-inside: avoid; }
      h1, h2, h3, h4 { break-after: avoid; }
      a { color: inherit; }
    }
    </style>
    </head>
    <body>
    <div id="c"></div>
    <script>
    var VENDOR = __VENDOR__;
    var loading = {};
    function loadScript(src) {
      if (!loading[src]) loading[src] = new Promise(function (resolve, reject) {
        var s = document.createElement('script');
        s.src = src; s.onload = resolve; s.onerror = reject;
        document.head.appendChild(s);
      });
      return loading[src];
    }
    function loadStyle(href, media) {
      if (document.querySelector('link[href="' + href + '"]')) return;
      var l = document.createElement('link');
      l.rel = 'stylesheet'; l.href = href;
      if (media) l.media = media;
      document.head.appendChild(l);
    }

    var generation = 0, lastHTML = '';
    // Resolves once math, diagrams, code and images have settled (used by the print pipeline).
    window.__set = function (html) {
      lastHTML = html;
      var gen = ++generation;
      var root = document.getElementById('c');
      root.innerHTML = html;
      var images = Array.prototype.map.call(root.querySelectorAll('img'), function (img) {
        return img.complete ? null : new Promise(function (r) { img.onload = img.onerror = r; });
      });
      return Promise.all([renderMath(root, gen), renderDiagrams(root, gen), renderCode(root, gen)].concat(images))
        .then(function () { return document.fonts.ready; });
    };
    window.__jump = function (id) {
      var el = document.getElementById(id);
      if (el) el.scrollIntoView({ block: 'start' });
    };

    // KaTeX: loaded the first time a document contains a math span.
    async function renderMath(root, gen) {
      var nodes = root.querySelectorAll('.math');
      if (!nodes.length) return;
      loadStyle(VENDOR + 'katex/katex.min.css');
      try { await loadScript(VENDOR + 'katex/katex.min.js'); } catch (e) { return; }
      if (gen !== generation) return;
      nodes.forEach(function (el) {
        katex.render(el.textContent, el, { displayMode: el.classList.contains('math-display'), throwOnError: false });
      });
    }

    // Mermaid: loaded the first time a document contains a ```mermaid block. Rendered SVG is cached per source.
    var diagramCache = new Map(), diagramSeq = 0;
    async function renderDiagrams(root, gen) {
      var blocks = root.querySelectorAll('pre > code.language-mermaid');
      if (!blocks.length) return;
      try { await loadScript(VENDOR + 'mermaid/mermaid.min.js'); } catch (e) { return; }
      if (gen !== generation) return;
      var dark = matchMedia('(prefers-color-scheme: dark)').matches;
      mermaid.initialize({ startOnLoad: false, theme: dark ? 'dark' : 'default' });
      for (var i = 0; i < blocks.length; i++) {
        var code = blocks[i], src = code.textContent, key = (dark ? 'd' : 'l') + src;
        var svg = diagramCache.get(key);
        if (svg === undefined) {
          var id = 'mmd' + (++diagramSeq);
          try { svg = (await mermaid.render(id, src)).svg; }
          catch (e) { svg = null; var stray = document.getElementById('d' + id); if (stray) stray.remove(); }
          diagramCache.set(key, svg);
        }
        if (gen !== generation) return;
        var host = document.createElement('div');
        if (svg) { host.className = 'mermaid'; host.innerHTML = svg; }
        else { host.className = 'mermaid-error'; host.textContent = src; }
        code.parentElement.replaceWith(host);
      }
    }

    // highlight.js: loaded the first time a document has a fenced block with a language. Languages outside the
    // common bundle are fetched on demand from highlight/languages/. Highlighted markup is cached per source.
    var codeCache = new Map();
    function languageOf(code) {
      for (var i = 0; i < code.classList.length; i++) {
        var cls = code.classList[i];
        if (cls.indexOf('language-') === 0) return cls.slice(9);
      }
      return null;
    }
    async function renderCode(root, gen) {
      var blocks = root.querySelectorAll('pre > code[class*="language-"]:not(.language-mermaid)');
      if (!blocks.length) return;
      loadStyle(VENDOR + 'highlight/github.min.css', '(prefers-color-scheme: light)');
      loadStyle(VENDOR + 'highlight/github-dark.min.css', '(prefers-color-scheme: dark)');
      try { await loadScript(VENDOR + 'highlight/highlight.min.js'); } catch (e) { return; }
      if (gen !== generation) return;
      for (var i = 0; i < blocks.length; i++) {
        var code = blocks[i], lang = languageOf(code);
        if (!lang) continue;
        if (!hljs.getLanguage(lang)) {
          try { await loadScript(VENDOR + 'highlight/languages/' + encodeURIComponent(lang) + '.min.js'); } catch (e) {}
          if (gen !== generation) return;
          if (!hljs.getLanguage(lang)) continue;
        }
        var key = lang + '|' + code.textContent;
        var cached = codeCache.get(key);
        if (cached === undefined) {
          cached = hljs.highlight(code.textContent, { language: lang }).value;
          codeCache.set(key, cached);
        }
        code.innerHTML = cached;
        code.classList.add('hljs');
      }
    }

    matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function () {
      if (lastHTML) window.__set(lastHTML);
    });
    </script>
    </body>
    </html>
    """
}
