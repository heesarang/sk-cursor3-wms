<!--
[사용법] Agent 입력창에서 /my-cr 입력 — 전체 체인의 입구(허브)만 안내한다. 구현은 하지 않는다.
[목적] 10-change-request.md §1 단순 컬럼 추가를 게이트형 Command 체인으로 안내
[체인] my-cr-plan → my-cr-db-files → my-cr-db-apply → my-cr-app → my-cr-verify
-->

# 운영 변경 대응 — 허브 (`/my-cr`)

단순 컬럼 추가(입고 주문 속성 → 목록·상세 표시)는 **한 번에 끝까지 실행하지 않는다.**
아래 순서로 **Command를 하나씩** 실행한다. 각 Command는 끝나면 멈추고 다음을 안내한다.

| 순서 | Command | 하는 일 | 하지 않는 일 |
|------|---------|---------|--------------|
| 1 | `/my-cr-plan` | 명세 + **영향 문서**(수정 허용 파일 목록) | 코드·SQL·DB |
| 2 | `/my-cr-db-files` | migration 파일 + 기준 DDL·데이터 사전 | DB 실행 |
| 3 | `/my-cr-db-apply` | 접속 확인 후 **본인 DB에** migration 실행 | 앱 코드 |
| 4 | `/my-cr-app` | 허용 목록 안 백엔드·프론트(·REQ/UI 최소) | 목록 밖 파일·DB |
| 5 | `/my-cr-verify` | 조회·회귀 스모크 + 영향 목록 대조 | 새 기능 추가 |

## 승인 규칙 (전 체인 공통)

- **영향 문서 승인 전**에는 `/my-cr-db-files` 이후를 실행하지 않는다.
- 승인 방법: 채팅에 아래 형식을 **한 줄로** 보낸다.  
  `영향 승인: <영향문서경로>`  
  예: `영향 승인: docs/01.analysis/05.change-requests/IMPACT-inbound-partner-contact-tel.md`
- DB 실행은 `/my-cr-db-apply`에서 **별도 승인**이 필요하다 (해당 Command 본문 참고).

## 지금 할 일

1. 변경 요청 문구와 컬럼 후보를 준비한 뒤 **`/my-cr-plan`** 을 실행한다.
2. 이 허브(`/my-cr`)에서는 파일을 만들거나 DB·코드를 수정하지 않는다.

참조: `docs/00.guide/10-change-request.md`, `.cursor/rules/06-database.mdc`
