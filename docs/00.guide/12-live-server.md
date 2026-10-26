# 12. Live Server — 프론트엔드 로컬 실행

> 백엔드 CORS·포트는 [backend-config.md](../99.references/backend-config.md), API 주소는 `frontend/js/api.js`의 `API_BASE`를 참고하세요. 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. Live Server란

Live Server는 **정적 HTML/JS/CSS**를 로컬 HTTP로 띄워 주는 Cursor(Visual Studio Code) 확장이다. 이 프로젝트 프론트는 **Vue 3 CDN SPA**(`frontend/index.html` 하나 + `router.js`)이므로 Node.js 빌드 없이 Live Server만으로 화면을 연다.

| 항목 | 내용 |
|------|------|
| 확장 ID | `ritwickdey.LiveServer` |
| 기본 포트 | `5500` (충돌 시 다른 포트) |
| 백엔드 | Spring Boot는 **별도** `8080` 등 — Live Server가 대체하지 않음 |
| 라우팅 | Vue Router **Hash** (`#/inbound`) — 새로고침 시에도 경로 유지 |

브라우저에서 API를 호출하면 Live Server 포트(5500)와 백엔드 포트(8080)가 달라 **CORS**가 적용된다. 백엔드 `SecurityConfig`가 CORS를 허용해야 한다.

---

## 2. 설치 (Cursor)

### 2.1 UI로 설치

1. Cursor에서 **Extensions** (`Ctrl+Shift+X`)를 연다.
2. 검색: `Live Server` (게시자 **Ritwick Dey**).
3. **Install**을 누른다.
4. 설치 후 필요하면 **Reload Window**로 창을 새로고침한다.

### 2.2 CLI로 설치 (선택)

터미널(PowerShell):

```powershell
cursor --install-extension ritwickdey.LiveServer
```

`cursor` 명령이 없으면 Cursor **Command Palette** (`Ctrl+Shift+P`) → `Shell Command: Install 'cursor' command in PATH` 실행 후 다시 시도한다.

---

## 3. 실행 방법

### 3.1 권장 — `frontend/index.html`에서 Go Live

1. 저장소 루트를 Cursor로 연다.
2. 탐색기에서 **`frontend/index.html`** 을 연다.
3. 편집기 **우클릭** → **Open with Live Server**  
   또는 상태 표시줄 우측 **Go Live** 클릭.
4. 브라우저가 열리면 주소에 **Hash 라우트**를 붙인다.

| 화면 | URL 예시 (루트가 저장소 전체일 때) |
|------|-----------------------------------|
| 입고 (F1) | `http://127.0.0.1:5500/frontend/index.html#/inbound` |
| 출고 (F2) | `.../frontend/index.html#/outbound` |
| 대시보드 (F3) | `.../frontend/index.html#/dashboard` |

Live Server가 **어느 폴더를 웹 루트로 쓰는지**에 따라 `/frontend/` 세그먼트가 있거나 없을 수 있다. 주소창에 `index.html`까지 포함된 URL이 맞는지 확인한다.

### 3.2 워크스페이스 설정 (선택)

매번 `/frontend/` 경로가 길면, 프로젝트에 `.vscode/settings.json`을 두고 루트를 `frontend`로 고정할 수 있다.

```json
{
  "liveServer.settings.root": "/frontend",
  "liveServer.settings.port": 5500,
  "liveServer.settings.CustomBrowser": "chrome"
}
```

이후 `frontend/index.html`에서 Go Live하면 예: `http://127.0.0.1:5500/index.html#/inbound`.

> `.vscode/settings.json`은 개인·팀 정책에 따라 Git에 포함하거나 로컬만 둘 수 있다. 실습 저장소에는 예시만 문서로 두고, 필요 시 각자 생성한다.

---

## 4. 백엔드와 함께 쓰기

1. **백엔드 기동** — Gradle `bootRun` 등으로 API 서버 실행 (기본 `http://localhost:8080`). JDK·Wrapper·환경변수는 [Gradle 매뉴얼](13-gradle.md) 참고.
2. **`frontend/js/api.js`** — `API_BASE`가 백엔드 주소·포트와 **일치**하는지 확인한다.

```javascript
const API_BASE = 'http://localhost:8080';
```

3. 브라우저 **개발자 도구(F12)** → **Network** 탭에서 `/api/...` 요청이 200인지, **Console**에 CORS 오류가 없는지 본다.

curl로 API만 성공해도 브라우저는 CORS 때문에 실패할 수 있다. 연동 검증은 **반드시 브라우저**에서 한다 ([coding-standards.md](../99.references/coding-standards.md) §4.4).

---

## 5. 동작 확인 체크리스트

- [ ] Live Server로 `index.html`이 열리고 Vue 화면(입고 제목 등)이 보인다.
- [ ] `#/inbound`에서 필터·목록 UI가 렌더링된다.
- [ ] 백엔드 기동 후 목록 조회 API가 Network에서 200이다.
- [ ] API 실패 시 `ElMessage`로 서버 `message` 또는 연결 오류가 표시된다.
- [ ] JS/CSS 수정 후 저장 시 Live Server **자동 새로고침**이 동작한다(확장 기본 동작).

---

## 6. 문제 해결

| 증상 | 원인 후보 | 조치 |
|------|-----------|------|
| 빈 화면, `#app`만 있음 | `js/`·`components/` 404 | Network에서 스크립트 404 확인. URL에 `frontend/` 경로 누락 여부 확인 |
| `Failed to load resource` (vue/axios) | 오프라인·CDN 차단 | 인터넷·회사망 CDN 허용 확인 |
| `Network Error` / CORS | 백엔드 미기동·CORS 미설정 | `8080` 기동, `SecurityConfig` CORS, `API_BASE` 일치 |
| API 404 | BE 미구현·경로 오타 | Swagger `http://localhost:8080/swagger-ui.html` 와 REQ §5 경로 비교 |
| Go Live 비활성 | 확장 미설치 | §2 설치, Cursor 재시작 |
| 포트 사용 중 | 5500 점유 | Live Server 설정에서 포트 변경 또는 점유 프로세스 종료 |
| `#/inbound` 무시되고 빈 라우트 | Hash 누락 | 주소 끝에 `#/inbound` 명시 |

---

## 7. Live Server 대안 (참고)

Live Server 없이도 **정적 파일 HTTP**만 제공하면 된다.

| 방법 | 명령 예시 |
|------|-----------|
| Python 3 | 저장소 루트: `python -m http.server 5500` → `http://127.0.0.1:5500/frontend/index.html#/inbound` |
| npx serve | `npx serve frontend -p 5500` → `http://127.0.0.1:5500/index.html#/inbound` |

실습 문서·Task 완료 조건은 **Live Server** 기준으로 적혀 있으므로, 가능하면 확장 사용을 권장한다.

---

## 8. 완료 기준

- Live Server 확장이 설치되어 있다.
- `frontend/index.html`을 Go Live로 열고 `#/inbound`(또는 구현된 라우트)로 화면을 확인했다.
- 백엔드와 `API_BASE`·CORS를 맞춘 뒤 브라우저 Network로 API 연동을 확인하는 방법을 안다.

---

## 9. 핵심 포인트

프론트는 **빌드 없이 CDN + Live Server**, 백엔드는 **Spring Boot 별도 포트**다. 두 서버를 동시에 띄우고, 브라우저 기준으로 CORS와 `API_BASE`를 맞추는 것이 WMS 실습의 기본 실행 패턴이다.

→ 이전: [11-mcp.md](11-mcp.md) · 다음: [13-gradle.md](13-gradle.md) · 프론트 구조: [coding-standards.md](../99.references/coding-standards.md) §5 · 순차 개발: [08-sequential-dev.md](08-sequential-dev.md) §4.6
