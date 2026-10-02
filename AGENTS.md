# AGENTS.md — MarkPad Development & Release Guidelines

## Project Identity
- **Project:** MarkPad (마크패드)
- **Repository:** `cycorld/markpad`
- **Core Architecture:** Native macOS Markdown Editor (SwiftUI + AppKit `NSTextView` + `WKWebView` + `swift-markdown`)
- **Target OS:** macOS 14.0+ (Universal binary: Apple Silicon + Intel)

## Invariants & Rules

1. **Zero-Network Core Invariant:**
   - Text editing, markdown parsing (`swift-markdown`), live preview, KaTeX math typesetting, Mermaid diagram generation, syntax highlighting (`highlight.js`), and PDF/print export must function 100% offline without remote network dependencies.

2. **Update SSOT Invariant:**
   - GitHub Releases (`https://api.github.com/repos/cycorld/markpad/releases/latest`) is the Single Source of Truth (SSOT) for software versioning and updates.
   - Do not introduce alternative or unverified feed mechanisms (e.g. Sparkle Appcast XML or third-party servers).

3. **Release & Version Bump Approval Gate (Strict Invariant):**
   - **버전 번호 상향(`Info.plist`) 및 배포 태그(`v*`) 생성/푸시는 반드시 사용자(최용철 대표)의 명시적 사전 승인을 거쳐야 한다.**
   - 태그 푸시는 GitHub Actions Release 워크플로우를 즉시 트리거하여 범용 바이너리를 빌드하고 공개 릴리스를 생성하므로, 임의로 태그를 달거나 푸시해서는 안 된다.

4. **Update Notes & Documentation Protocol:**
   - 모든 기능 추가, 변경, 버그 수정 시 `CHANGELOG.md`의 `[Unreleased]` 섹션에 빠짐없이 업데이트 노트를 기록한다 (Keep a Changelog 규격 준수).
   - 영문(`README.md`) 및 국문(`README.ko.md`)의 기능 목록, 단축키/메뉴 표, 소스 레이아웃 트리를 항상 동기화한다.
   - 릴리스 승인 완료 시 `[Unreleased]` 내용을 해당 버전 태그 블록(`## [X.Y.Z] - YYYY-MM-DD`)으로 전환하고 깃 비교 링크를 갱신한다.

5. **macOS Native & IME Integrity:**
   - `MarkdownTextView`의 AppKit 텍스트 시스템은 한글/CJK IME 조합 버퍼 및 macOS 전역 단축키를 손상시키지 않도록 스마트 인용/대시 자동 교체 및 맞춤법 간섭을 원천 차단 상태로 유지한다.

## Release & Workflow Protocol

1. **Feature Branching:**
   - 항상 `main`에서 브랜치를 분기하여 작업한다: `git checkout -b feat/<name>` 또는 `fix/<name>`.
2. **Pre-Flight Validation:**
   - 단위 테스트(`XCTest`) 무결성 확인 및 빌드 스크립트(`build.sh`) 패키징 검증.
3. **Pull Request & Merge:**
   - 작업 완료 후 PR 생성 및 CI 통과 확인 후 머지.
4. **Official Release Steps (Requires Explicit Approval):**
   - 사용자 승인 획득 확인.
   - `Info.plist`의 `CFBundleShortVersionString` 및 `CFBundleVersion` 갱신.
   - `CHANGELOG.md` 버전 확정 및 날짜 명시.
   - Git 태그 생성 및 푸시:
     ```bash
     git tag vX.Y.Z
     git push origin vX.Y.Z
     ```
   - GitHub Actions `release.yml` 정상 완료 및 릴리스 에셋(`MarkPad-vX.Y.Z.zip`, `SHA256SUMS.txt`) 생성 확인.
