# MarkPad

macOS용 간편 마크다운 에디터. 왼쪽 편집, 오른쪽 실시간 미리보기.

- 편집기: `NSTextView` (고정폭, 스마트 따옴표/대시 끔, 찾기 바, 실행 취소)
- 미리보기: `WKWebView` + GitHub 스타일 CSS, 다크 모드 자동
- 파서: Apple [swift-markdown](https://github.com/swiftlang/swift-markdown) (GFM 표, 취소선, 체크박스)
- 문서 기반 앱: 새 문서/열기/저장/자동 저장/탭, `.md` `.markdown` 연결
- 보기 모드: 편집(⌘1) · 분할(⌘2) · 미리보기(⌘3)
- 문서 기준 상대 경로 이미지 표시 (`markpad://` 스킴 핸들러)

## 빌드

```bash
./build.sh            # dist/MarkPad.app
./build.sh --install  # + /Applications 에 복사
```

요구: Xcode 16+ (Swift 5.9 toolchain), macOS 14+. 앱 아이콘은 `Scripts/make-icon.swift`로 생성해 `Assets/AppIcon.icns`에 캐시.

## 구조

```
Sources/MarkPad/
  MarkPadApp.swift          DocumentGroup 진입점, 보기 모드 메뉴
  AppDelegate.swift         파일 열며 실행 시 Untitled 창 억제
  MarkdownDocument.swift    FileDocument (UTF-8 텍스트)
  EditorView.swift          분할 레이아웃, 툴바, 디바운스 렌더
  MarkdownTextView.swift    NSTextView 래퍼
  PreviewView.swift         WKWebView 래퍼 (셸 1회 로드, 본문은 JS로 교체)
  PreviewTemplate.swift     HTML 셸 + CSS
  MarkdownRenderer.swift    swift-markdown → HTML
  LocalFileSchemeHandler.swift  markpad:///abs/path → 로컬 파일
```
