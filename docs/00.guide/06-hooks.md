# 06. Hooks

> 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. Hooks란

Hooks는 에이전트의 특정 동작 시점에 자동으로 실행되는 셸 스크립트이다. `.cursor/hooks.json`에 이벤트와 스크립트를 매핑하고, 실제 스크립트는 `.cursor/hooks/` 폴더에 저장한다.

Rules가 "무엇을 지켜야 하는지", Commands가 "어떤 순서로 실행하는지", Skills가 "어떤 형식으로 만드는지", Agents가 "누가 하는지"를 정의한다면, Hooks는 "언제 자동으로 개입하는지"를 정의한다. 에이전트가 파일을 읽거나, 수정하거나, 셸 명령을 실행하거나, 작업을 완료하는 시점에 사람의 개입 없이 검증·차단·후처리를 수행한다.

## 2. 파일 구조

```
.cursor/
├── hooks.json          ← 이벤트-스크립트 매핑 설정
└── hooks/
    ├── auto-format.sh      ← 파일 수정 후 자동 포맷팅
    ├── block-dangerous.sh  ← 위험 셸 명령 차단
    ├── block-secrets.sh    ← 민감 파일 읽기 차단
    └── notify-done.sh      ← 작업 완료 알림 + 로그
```

`hooks.json`이 이벤트별로 어떤 스크립트를 실행할지 결정하고, 각 스크립트는 stdin으로 JSON을 받아 처리한 뒤 stdout으로 JSON을 반환한다.

## 3. hooks.json 설정

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": ".cursor/hooks/auto-format.sh"
      }
    ],
    "beforeShellExecution": [
      {
        "command": ".cursor/hooks/block-dangerous.sh"
      }
    ],
    "beforeReadFile": [
      {
        "command": ".cursor/hooks/block-secrets.sh"
      }
    ],
    "stop": [
      {
        "command": ".cursor/hooks/notify-done.sh"
      }
    ]
  }
}
```

네 가지 이벤트 시점과 매핑된 스크립트의 역할은 다음과 같다.


| 이벤트                    | 시점                  | 스크립트                 | 역할                                                      |
| ---------------------- | ------------------- | -------------------- | ------------------------------------------------------- |
| `afterFileEdit`        | 에이전트가 파일을 수정한 직후    | `auto-format.sh`     | Java는 google-java-format, JS/HTML/CSS는 prettier로 자동 포맷팅 |
| `beforeShellExecution` | 에이전트가 셸 명령을 실행하기 직전 | `block-dangerous.sh` | `rm -rf /`, `drop database`, 프로덕션 DB 접속 등 위험 명령 차단      |
| `beforeReadFile`       | 에이전트가 파일을 읽기 직전     | `block-secrets.sh`   | `.env`, `id_rsa`, `.pem`, `credentials` 등 민감 파일 접근 차단   |
| `stop`                 | 에이전트 작업 완료 시        | `notify-done.sh`     | macOS 알림 표시 + `.cursor/logs/agent-history.log`에 이력 기록   |


## 4. 스크립트 상세

### 4.1 `block-dangerous.sh` — 위험 명령 차단

에이전트가 셸 명령을 실행하기 전에 호출된다. stdin으로 `{"command": "실행할 명령"}` 형태의 JSON을 받아 명령 문자열을 검사한다. `rm -rf /`, `drop database`, `truncate table`, 포크 폭탄 패턴이 감지되면 `{"permission":"deny"}` 를 반환하여 실행을 차단한다. `mysql.*prod`, `psql.*prod` 등 프로덕션 DB 접속 명령도 차단 대상이다. 위험하지 않은 명령은 `{"permission":"allow"}`를 반환하여 정상 실행한다.

### 4.2 `block-secrets.sh` — 민감 파일 읽기 차단

에이전트가 파일을 읽기 전에 호출된다. stdin으로 `{"file_path": "파일 경로"}` 형태의 JSON을 받아 파일명을 검사한다. `.env`, `id_rsa`, `.pem`, `credentials`, `secrets` 패턴에 매칭되면 `{"permission":"deny"}` 를 반환하고 "민감 파일 접근 차단" 메시지를 표시한다.

### 4.3 `auto-format.sh` — 파일 수정 후 자동 포맷팅

에이전트가 파일을 수정한 직후 호출된다. stdin으로 `{"file_path": "파일 경로"}` 형태의 JSON을 받아 확장자를 판별한다. `.java` 파일이면 google-java-format으로, `.js`/`.html`/`.css`/`.vue` 파일이면 prettier로 포맷팅한다. 해당 도구가 설치되어 있지 않으면 아무 작업 없이 넘어간다.

### 4.4 `notify-done.sh` — 작업 완료 알림

에이전트 작업이 완료되면 호출된다. stdin으로 `{"status": "상태"}` 형태의 JSON을 받아 macOS `osascript`로 데스크톱 알림을 표시하고, `.cursor/logs/agent-history.log` 파일에 타임스탬프·상태·상세 정보를 기록한다.

### 스크립트 입출력 요약


| 스크립트                 | stdin 주요 필드 | 허용 시 stdout              | 차단 시 stdout                                  |
| -------------------- | ----------- | ------------------------ | -------------------------------------------- |
| `block-dangerous.sh` | `command`   | `{"permission":"allow"}` | `{"permission":"deny","user_message":"..."}` |
| `block-secrets.sh`   | `file_path` | `{"permission":"allow"}` | `{"permission":"deny","user_message":"..."}` |
| `auto-format.sh`     | `file_path` | `{}`                     | — (차단 없음)                                    |
| `notify-done.sh`     | `status`    | `{}`                     | — (차단 없음)                                    |


## 5. 실습 — 위험 명령 차단 체험

Hooks는 에이전트 동작 시점에 자동 실행되므로 직접 확인하기 어렵다. 여기서는 `block-dangerous.sh`의 차단 동작을 직접 체험한다.

### 5.1 스크립트 실행 권한 확인

먼저 `.cursor/hooks/` 안의 스크립트에 실행 권한이 있는지 확인한다. 터미널에서 다음을 실행한다.

```bash
ls -l .cursor/hooks/*.sh
```

`-rwxr-xr-x` 형태가 아니면 실행 권한을 부여한다.

```bash
chmod +x .cursor/hooks/*.sh
```

### 5.2 차단 동작 테스트

터미널에서 `block-dangerous.sh`에 위험 명령을 직접 입력하여 차단되는지 확인한다.

```bash
echo '{"command":"rm -rf /"}' | .cursor/hooks/block-dangerous.sh
```

출력이 다음과 같으면 정상 동작이다.

```json
{"permission":"deny","user_message":"⛔ 위험한 명령이 차단되었습니다."}
```

안전한 명령도 테스트한다.

```bash
echo '{"command":"ls -la"}' | .cursor/hooks/block-dangerous.sh
```

출력이 다음과 같으면 허용이 정상 동작하는 것이다.

```json
{"permission":"allow"}
```

### 5.3 에이전트에서 차단 확인

채팅에서 에이전트에게 다음과 같이 요청한다.

```
터미널 프로젝트 루트 위치에서 rm -rf / 명령을 실행해 줘
```

에이전트가 명령을 실행하려 할 때 "위험한 명령이 차단되었습니다" 메시지가 표시되면 `beforeShellExecution` 훅이 정상 작동하는 것이다.

### 5.4 Hook 로그 확인

Cursor 설정에서 Hook 실행 로그를 확인할 수 있다. Settings → Features → Hooks 항목에서 "Enable hooks"가 켜져 있는지 확인하고, 하단의 로그 영역에서 각 훅의 실행 이력과 결과(allow/deny)를 볼 수 있다.

`notify-done.sh`가 기록하는 로그는 다음 경로에서 직접 확인할 수 있다.

```bash
cat .cursor/logs/agent-history.log
```

## 6. 완료 기준

- `before` 계열 훅은 `permission` 필드로 허용/차단을 제어하고, `after`/`stop` 계열 훅은 후처리만 수행한다는 차이를 이해한다
- `block-dangerous.sh`를 터미널에서 직접 실행하여 차단/허용 동작을 확인했다
- Cursor 설정에서 Hook 로그를 확인하는 방법을 알고 있다

## 7. 핵심 포인트

Hooks는 에이전트의 행동에 대한 "자동 안전장치"이다. Rules가 에이전트에게 "하지 마라"고 텍스트로 지시하는 것이라면, Hooks는 실제로 실행을 차단하거나 후처리를 강제하는 코드 수준의 개입이다. Rules를 무시할 수 있는 에이전트도 Hooks는 우회할 수 없다는 점에서, 프로젝트의 최후 방어선 역할을 한다.

→ 다음: [07-verification.md](07-verification.md)
