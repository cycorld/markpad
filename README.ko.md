# MarkPad

[![CI](https://github.com/cycorld/markpad/actions/workflows/ci.yml/badge.svg)](https://github.com/cycorld/markpad/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/cycorld/markpad?display_name=tag)](https://github.com/cycorld/markpad/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

[English](README.md) | **한국어**

macOS용 작은 네이티브 마크다운 에디터. 왼쪽에서 편집하고 오른쪽에서 실시간으로 미리 봅니다. SwiftUI + `NSTextView` + `WKWebView`, Electron 아님. 수식·다이어그램·코드 하이라이팅·목차·머리말/꼬리말 인쇄까지 전부 오프라인으로 동작합니다.

![MarkPad](docs/screenshot.png)

## 기능

- **편집기** — `NSTextView`: 고정폭 글꼴, 스마트 따옴표·대시·자동 교정 끔, 찾기 바(⌘F), 실행 취소
- **미리보기** — GitHub 스타일 `WKWebView`, 시스템 다크 모드 자동 추종, 타이핑 중에도 스크롤 위치 유지
- **마크다운** — Apple [swift-markdown](https://github.com/swiftlang/swift-markdown) (CommonMark + GFM 표, 취소선, 체크리스트)
- **수식** — KaTeX로 `$인라인$`, `$$디스플레이$$` 렌더링 (Pandoc/Obsidian 규칙: 여는 `$` 뒤 공백 금지, `\$`는 글자 그대로, 코드 안은 건드리지 않음)
- **다이어그램** — ```` ```mermaid ```` 블록을 Mermaid로 렌더링, 다크 테마 자동
- **코드** — 언어를 지정한 펜스 블록을 highlight.js로 하이라이팅(GitHub 라이트/다크 테마). 기본 번들 밖 언어는 필요할 때 로드
- **목차** — `[TOC]`(또는 `[[toc]]`)만 있는 문단이 문서의 제목들로 만든 중첩 목록으로 바뀜. 모든 제목에 GitHub 방식 anchor id가 붙어 `[링크](#섹션)`이 동작
- **아웃라인 사이드바** — ⌥⌘S로 제목 목록 표시. 클릭하면 편집기와 미리보기가 함께 이동
- **인쇄 & PDF** — ⌘P로 렌더링된 미리보기를 일반 인쇄 패널로 인쇄, ⌥⌘P로 PDF 내보내기. 머리말·꼬리말은 설정(⌘,)에서 `{title}` `{file}` `{page}` `{pages}` `{date}` `{time}` 토큰과 4가지 페이지 번호 스타일로 구성. 용지 크기·방향은 페이지 설정(⇧⌘P)
- **문서** — 새로 만들기 / 열기 / 저장 / 자동 저장 / 창 복원. `.md` `.markdown` `.mdown` `.mkd` 연결
- **보기 모드** — 편집기(⌘1) · 분할(⌘2) · 미리보기(⌘3)
- **로컬 이미지** — 문서 기준 상대 경로 이미지 표시 (`markpad://` URL 스킴 핸들러, 비공개 API 없음)
- KaTeX·Mermaid·highlight.js는 앱에 포함돼 있지만 필요할 때만 로드 — 문서가 쓰는 만큼만 비용을 냅니다

## 설치

### 요구 사항

- macOS 14 Sonoma 이상
- Apple silicon 또는 Intel (릴리스 빌드는 유니버설 바이너리)
- 다른 의존성 없음 — 실행 중 네트워크에서 받아오는 것 없음

### 1. 다운로드

1. [최신 릴리스](https://github.com/cycorld/markpad/releases/latest)에서 `MarkPad-vX.Y.Z.zip`을 받습니다.
2. zip을 더블클릭해 `MarkPad.app`을 꺼냅니다.
3. `MarkPad.app`을 `응용 프로그램` 폴더로 끌어다 놓습니다.

선택 — 다운로드 검증. 같은 릴리스의 `SHA256SUMS.txt`를 zip과 같은 폴더에 두고:

```bash
shasum -a 256 -c SHA256SUMS.txt
```

### 2. 첫 실행

MarkPad는 ad-hoc 서명만 되어 있고 공증(notarization)은 받지 않았습니다(유료 Apple Developer 계정이 없음). 그래서 첫 실행 때 macOS가 *"MarkPad"을(를) 열 수 없습니다. Apple에서 확인할 수 없습니다* 또는 *… 열리지 않았습니다* 라며 막습니다. 아래 방법 중 하나로 한 번만 허용하면 됩니다.

**macOS 15 Sequoia 이상**

1. `MarkPad.app`을 한 번 더블클릭하고 경고를 닫습니다.
2. **시스템 설정 → 개인정보 보호 및 보안**을 열고 아래 **보안** 항목까지 내립니다.
3. *Mac을 보호하기 위해 "MarkPad"이(가) 차단되었습니다* 옆의 **그래도 열기**를 누르고, 한 번 더 **그래도 열기**로 확인합니다(암호나 Touch ID를 물을 수 있음).

**macOS 14 Sonoma**

1. `MarkPad.app`을 Control-클릭(오른쪽 클릭) → **열기**.
2. 대화상자에서 **열기**를 누릅니다.

**터미널 (모든 버전)**

```bash
xattr -d com.apple.quarantine /Applications/MarkPad.app
```

다운로드한 파일에 macOS가 붙이는 격리(quarantine) 플래그를 지우는 명령입니다. 이후에는 다른 앱과 똑같이 열립니다. 새 버전을 설치하면 이 단계를 다시 해야 합니다.

### 3. `.md` 파일을 MarkPad로 열기

마크다운 파일의 기본 앱으로 지정하려면:

1. Finder에서 아무 `.md` 파일을 선택하고 ⌘I(**정보 가져오기**)를 누릅니다.
2. **다음으로 열기**에서 **MarkPad**를 고릅니다.
3. **모두 변경…**을 누르고 확인합니다.

이제 `.md`, `.markdown`, `.mdown`, `.mkd` 파일을 더블클릭하면 MarkPad로 열립니다. 앱 아이콘에 파일을 떨어뜨리거나, 터미널에서 `open -a MarkPad notes.md`로 열 수도 있습니다.

### 업데이트

새 zip을 받아 `응용 프로그램`의 `MarkPad.app`을 교체합니다. 설정(보기 모드, 아웃라인, 인쇄 머리말/꼬리말)은 macOS user defaults에 저장되므로 그대로 유지됩니다. Gatekeeper는 새 복사본을 새 다운로드로 보기 때문에 2단계를 다시 합니다.

### 제거

`MarkPad.app`을 휴지통으로 옮깁니다. 흔적까지 지우려면:

```bash
defaults delete com.cycorld.markpad
rm -rf ~/Library/Saved\ Application\ State/com.cycorld.markpad.savedState
```

### 소스에서 빌드

Xcode 16 이상(Swift 5.9 툴체인)과 macOS 14 이상이 필요합니다.

```bash
git clone https://github.com/cycorld/markpad.git
cd markpad
./build.sh            # → dist/MarkPad.app (유니버설, ad-hoc 서명)
./build.sh --install  # /Applications 에도 복사
```

첫 빌드에서 앱 아이콘을 생성하고(`Scripts/make-icon.swift`) 버전이 고정된 KaTeX / Mermaid / highlight.js 빌드를 `Assets/`에 내려받습니다(`Scripts/fetch-vendor.sh`). 직접 빌드한 앱에는 격리 플래그가 없으므로 Gatekeeper 단계가 필요 없습니다.

## 사용법

| 동작 | 단축키 |
|---|---|
| 새로 만들기 / 열기 / 저장 | ⌘N / ⌘O / ⌘S |
| 편집기만 / 분할 / 미리보기만 | ⌘1 / ⌘2 / ⌘3 |
| 아웃라인 사이드바 토글 | ⌥⌘S |
| 편집기에서 찾기 | ⌘F |
| 인쇄 | ⌘P |
| PDF로 내보내기 | ⌥⌘P |
| 페이지 설정 (용지 크기, 방향) | ⇧⌘P |
| 인쇄 머리말 / 꼬리말 설정 | ⌘, |

### 헤드리스 PDF 내보내기

```bash
/Applications/MarkPad.app/Contents/MacOS/MarkPad --export-pdf notes.md notes.pdf
```

⌘P와 같은 파이프라인(머리말/꼬리말 설정 포함)으로 파일을 렌더링하고 종료합니다. `MARKPAD_DEBUG=1`을 주면 파이프라인 진행을 stderr로 출력합니다.

## 구조

```
Sources/MarkPad/
  MarkPadApp.swift              DocumentGroup 진입점, 보기 모드 메뉴
  AppDelegate.swift             DocumentGroup이 실행 시 여는 빈 "Untitled" 창 정리
  MarkdownDocument.swift        FileDocument (UTF-8 텍스트)
  EditorView.swift              아웃라인 / 편집기 / 미리보기 레이아웃, 툴바, 디바운스 렌더
  OutlineView.swift             제목 사이드바
  MarkdownTextView.swift        NSTextView 래퍼
  PreviewView.swift             WKWebView 래퍼 (셸은 1회 로드, 본문은 JS로 교체)
  PreviewTemplate.swift         HTML 셸, CSS(화면 + 인쇄), KaTeX/Mermaid/highlight.js 지연 로더
  MarkdownRenderer.swift        마크다운 → HTML 파이프라인
  HTMLRenderer.swift            AST → HTML (이스케이프, 고유 제목 id, 제목 목록; swift-markdown에서 파생)
  MathProtector.swift           파싱 전에 $…$ 구간을 빼두고 렌더 후 되돌림
  LocalFileSchemeHandler.swift  markpad:///abs/path → 로컬 파일
  PrintController.swift         WebKit 페이지 분할 → PDF → 머리말/꼬리말 그린 페이지 → 인쇄 패널 / 파일
  PrintOptions.swift            머리말 / 꼬리말 템플릿, 페이지 번호 스타일 (UserDefaults)
  PrintSettingsView.swift       설정 → Print
Scripts/                        make-icon.swift, fetch-vendor.sh
build.sh                        .app 번들 조립
```

## 기여

이슈와 풀 리퀘스트를 환영합니다 — [CONTRIBUTING.md](CONTRIBUTING.md)를 참고하세요. [행동 강령](CODE_OF_CONDUCT.md)을 지켜 주세요. 보안 문제: [SECURITY.md](SECURITY.md). 변경 이력: [CHANGELOG.md](CHANGELOG.md).

## 라이선스

MIT — [LICENSE](LICENSE). 서드파티 구성 요소와 라이선스는 [THIRD_PARTY.md](THIRD_PARTY.md)에 정리돼 있습니다.
