<!--
[사용법] Agent 입력창에서 /my-create 입력 — 등록(생성) 기능 체인의 입구만 안내. 구현 금지
[목적] 주문·헤더+라인 등 「화면에서 신규 입력」기능을 도메인 불문(입고·출고·후속)으로 동일 절차로 진행
[체인] my-create-plan → (선택 my-create-db-*) → my-create-app → my-create-verify
[비교] /my-cr = 기존 테이블에 컬럼 추가. /my-create = 등록 API·입력 UI·전역 진입점
-->

# 데이터 등록 기능 — 허브 (`/my-create`)

화면에서 **신규 데이터를 입력·저장**하는 기능(입고 등록, 출고 등록 등)은 **한 번에 끝까지 실행하지 않는다.**
아래 순서로 **Command를 하나씩** 실행한다. 각 Command는 끝나면 멈추고 다음을 안내한다.

| 순서 | Command | 하는 일 | 하지 않는 일 |
|------|---------|---------|--------------|
| 1 | `/my-create-plan` | PRD·요청 기반 **영향 문서**(ALLOWED_PATHS, 도메인 파라미터) | 코드·SQL·DB |
| 2 | `/my-create-db-files` | (IMPACT에 DB 변경이 있을 때만) migration·DDL·사전 | DB 실행·앱 |
| 3 | `/my-create-db-apply` | (있을 때만) `DB 적용 승인:` 후 본인 DB 적용 | 앱 |
| 4 | `/my-create-app` | ALLOWED 안 백엔드·프론트·REQ/UI | 목록 밖·무단 DDL |
| 5 | `/my-create-verify` | 등록 스모크·전역 버튼·회귀 | 새 범위 확대 |

테이블이 이미 있고 INSERT만 하면 되는 경우(입고 등록 PRD 등)는 **2·3을 건너뛰고** plan 승인 후 `/my-create-app`으로 간다. IMPACT § DB에 `불필요`라고 적는다.

## 도메인 파라미터 (매번 채팅 또는 IMPACT에 명시)

| 키 | 예 (입고) | 예 (출고) |
|----|-----------|-----------|
| `domain` | inbound | outbound |
| `label` | 입고 등록 | 출고 등록 |
| `order_kind` | INBOUND | OUTBOUND |
| `api_create` | `POST /api/inbound/orders` | `POST /api/outbound/orders` |
| `detail_ui` | InboundDetail 유사 | OutboundDetail 유사 |
| `nav_entry` | 전역 `[입고 등록]` | 전역 `[출고 등록]` (또는 공통 등록 메뉴) |
| `prd` | `wms_prd-inbound-create.md` 등 | 출고용 추가 PRD |

입고용 예시를 출고·다른 입력에 **그대로 복사하지 않는다.** IMPACT의 파라미터·ALLOWED_PATHS를 따른다.

## 승인 규칙

- **영향 승인:** `영향 승인: <IMPACT경로>` 없으면 plan 이후 중단.
- DB가 필요하면 `/my-create-db-apply`에서 `DB 적용 승인: <migration경로>` 별도 필요.
- 예: `영향 승인: docs/01.analysis/05.change-requests/IMPACT-inbound-create.md`

## 지금 할 일

1. 추가 PRD(또는 동등 요청)와 도메인 파라미터를 준비한 뒤 **`/my-create-plan`** 을 실행한다.
2. 이 허브에서는 파일을 만들거나 DB·코드를 수정하지 않는다.

참조: `docs/01.analysis/01.rfp/wms_prd-inbound-create.md`, `wms_prd-inventory-flow.md` F5/F7, `.cursor/rules/01-project-context.mdc`
