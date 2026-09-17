enum PreviewTemplate {
    static let page = """
    <!doctype html>
    <html>
    <head>
    <meta charset="utf-8">
    <style>
    :root {
      color-scheme: light dark;
      --fg: #1f2328; --bg: #ffffff; --muted: #59636e; --border: #d8dee4;
      --code-bg: #f6f8fa; --link: #0969da; --quote: #57606a; --mark: #fff8c5;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --fg: #e6edf3; --bg: #1e1e1e; --muted: #9198a1; --border: #3d444d;
        --code-bg: #2a2a2a; --link: #4493f8; --quote: #9198a1; --mark: #5a4a00;
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
    </style>
    </head>
    <body>
    <div id="c"></div>
    <script>
    window.__set = function (html) { document.getElementById('c').innerHTML = html; };
    </script>
    </body>
    </html>
    """
}
