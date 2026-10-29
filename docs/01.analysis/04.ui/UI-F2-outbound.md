# UI 설계 — 출고 관리

| 항목 | 내용 |
|------|------|
| 문서 ID | UI-F2-outbound |
| 버전 | 1.0 |
| 기준 Task | TASK-UI-F2-outbound |
| 기준 요구사항 | REQ-F2-outbound.md §3·§5, REQ-F4-status-transition.md |
| 라우트 | `#/outbound` |
| UX 패턴 | UI-F1-inbound과 대칭 (목록→상세→확인 후 전이) |
| 기술 스택 | Vue 3 (CDN), Element Plus, Tailwind CSS, Axios |

## 1. 화면 개요

출고 주문 목록을 센터·상태로 필터 조회하고, 상세 다이얼로그에서 라인(품목·주문수량·피킹수량)을 확인한 뒤 피킹시작→피킹완료→출고확정만 순서대로 전이한다. 화면에서 주문 신규 생성은 없다.

| 항목 | 내용 |
|------|------|
| 주요 사용자 목표 | 출고 피킹·확정 진행 및 상태 확인 |
| 진입 | 앱 네비게이션 「출고」 → `#/outbound` |
| F1과의 차이 | 상태명·액션 라벨·라인 필드 `picked_qty`·API 경로 `/api/outbound/...` |

## 2. 레이아웃 (와이어프레임)

```
┌─────────────────────────────────────────────────────────────┐
│ [네비] 대시보드 | 입고 | 출고*                                 │
├─────────────────────────────────────────────────────────────┤
│ 출고 주문 관리                                                │
│ ┌─ 필터 ──────────────────────────────────────────────────┐ │
│ │ 센터 [el-select ▼]  상태 [el-select ▼]  [조회] [초기화]   │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌─ el-table ──────────────────────────────────────────────┐ │
│ │ 주문번호 │ 센터 │ 상태(tag) │ 주문일시 │ 담당자 이름 │ 담당자 연락처 │ (행 클릭→상세) │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

┌─ el-dialog: 출고 주문 상세 ───────────────────────────────┐
│ 주문번호 / 센터 / 상태(tag) / 주문일시 / 담당자 이름 / 연락처 │
│ ┌─ 라인 el-table ───────────────────────────────────────┐ │
│ │ 라인 │ SKU │ 품목명 │ 주문수량 │ 피킹수량(picked_qty)  │ │
│ └───────────────────────────────────────────────────────┘ │
│            [피킹시작] [피킹완료] [출고확정]  ← 허용된 것만   │
│                                            [닫기]          │
└────────────────────────────────────────────────────────────┘
```

## 3. 컴포넌트 구성

### 3.1 페이지 — `OutboundList` (`views/OutboundList.js` 예정)

| 영역 | Element Plus | 설명 |
|------|--------------|------|
| 필터 | `el-select` (센터·상태), `el-button` | F1과 동일 레이아웃 |
| 목록 | `el-table`, `el-tag` | 행 클릭 → 상세 |
| 로딩 | `v-loading` | 목록·상세 조회 중 |

**필터 옵션**

| 필드 | 바인딩 | 옵션 |
|------|--------|------|
| 센터 | `filter.center_no` | 전체, `CTR01`, `CTR02` |
| 상태 | `filter.status_code` | 전체, `00` 주문생성, `10` 피킹중, `20` 피킹완료, `90` 출고확정 |

**목록 컬럼**

| 컬럼 | 필드 | 표시 |
|------|------|------|
| 주문번호 | `order_no` | 텍스트 |
| 센터 | `center_no` + `center_name` | 예: `CTR01 (서울센터)` |
| 상태 | `status_code` / `status_name` | `el-tag` (§5) |
| 주문일시 | `ordered_at` | 로컬 포맷 |
| 담당자 이름 | `partner_contact_name` | 텍스트 (NULL이면 `-`), 연락처와 인접 |
| 담당자 연락처 | `partner_contact_tel` | 텍스트 (NULL이면 `-`) |

### 3.2 다이얼로그 — `OutboundDetail` (`components/OutboundDetail.js` 예정)

| 영역 | 구성 |
|------|------|
| 헤더 | `order_no`, `center_no`/`center_name`, `status_code`/`status_name`(tag), `ordered_at`, `partner_contact_name`, `partner_contact_tel` |
| 라인 테이블 | `line_no`, `sku_no`, `item_name`, `order_qty`, **`picked_qty`** |
| 액션 | 현재 상태에서 허용된 전이 버튼만 노출 |
| 닫기 | `@close` → 목록 유지 |

**상태별 액션 버튼**

| 현재 status_code | 버튼 라벨 | to_status | `el-button` type 권장 |
|------------------|-----------|-----------|----------------------|
| `00` | 피킹시작 | `10` | primary |
| `10` | 피킹완료 | `20` | primary |
| `20` | 출고확정 | `90` | success |
| `90` | (없음) | — | 종료 — 액션 없음 (예: 시드 `OB-DONE`) |

전이 전 `ElMessageBox.confirm`. Body: `to_status`, `changed_by`(기본 `demo-user`), `change_reason`(기본 버튼 라벨).

### 3.3 공통

- F1과 동일한 피드백·태그 헬퍼 패턴
- 컴포넌트/메서드명은 outbound 도메인으로만 구분

## 4. API 연동 매핑

REQ-F2-outbound.md §5 기준.

| UI 동작 | Method | Path | 요청 | 성공 후 UI |
|---------|--------|------|------|------------|
| 진입 / [조회] | `GET` | `/api/outbound/orders` | Query: `center_no?`, `status_code?` | 목록 바인딩 |
| [초기화] | — | — | 필터 클리어 후 GET | 전체 목록 |
| 행 클릭 | `GET` | `/api/outbound/orders/{orderNo}` | Path: `orderNo` | 헤더·`lines`(포함 `picked_qty`) |
| 피킹시작 / 피킹완료 / 출고확정 | `POST` | `/api/outbound/orders/{orderNo}/transition` | Body: `{ to_status, changed_by, change_reason }` | 상세 재조회 + 목록 refresh + 성공 토스트 |
| (선택) 규칙 | `GET` | `/api/status-transitions/rules?order_kind=OUTBOUND` | `order_kind=OUTBOUND` | 허용 버튼만 노출 |

**전이 Body 예시** (피킹시작)

```json
{
  "to_status": "10",
  "changed_by": "demo-user",
  "change_reason": "피킹시작"
}
```

## 5. 상태별 표시 규칙

`project-standards.md` §4.2.

| status_code | 표시명 | el-tag type |
|-------------|--------|-------------|
| `00` | 주문생성 | `info` |
| `10` | 피킹중 | `warning` |
| `20` | 피킹완료 | `primary` |
| `90` | 출고확정 | `success` |

## 6. 에러·예외 피드백

| 상황 | HTTP / 응답 | UI 처리 |
|------|-------------|---------|
| 목록 실패 | 500, `출고 주문 목록 조회 중 오류가 발생했습니다` 등 | `ElMessage.error(message)` |
| 상세 없음 | 404, `출고 주문을 찾을 수 없습니다: ...` | `ElMessage.error`, 다이얼로그 처리 |
| 비허용 전이 | 400, `허용되지 않은 상태 전이입니다: OUTBOUND 00 → 20` 등 | `ElMessage.error(message)`, 상태 유지 |
| 전이 성공 | 200 | `ElMessage.success` |

확인 문구 예: `「피킹시작」을 진행하시겠습니까? (00 → 10)`

## 7. 사용자 시나리오

### 7.1 정상 흐름 — 피킹시작

1. `#/outbound` 진입 → `GET /api/outbound/orders`
2. 상태 `00` 필터 [조회] → `GET ...?status_code=00`
3. 주문 행 클릭 → `GET /api/outbound/orders/{orderNo}` → 라인에 `picked_qty` 표시, **피킹시작**만 활성
4. [피킹시작] → confirm → `POST .../transition` (`to_status:"10"`)
5. 성공 → 상태 `피킹중`(warning), 버튼 **피킹완료**, 목록 refresh

### 7.2 정상 흐름 — 피킹완료 → 출고확정

1. `10` 상세에서 [피킹완료] → `to_status:"20"` → 태그 primary
2. [출고확정] → `to_status:"90"` → 태그 success, 전이 버튼 없음

### 7.3 에러 흐름 — 확정 주문·비허용 전이

1. `OB-DONE`(status `90`) 상세 → 전이 버튼 없음
2. 비허용 POST(예: 00→20, 90 재전이) → 400 message → `ElMessage.error`
3. 존재하지 않는 `orderNo` 상세 → 404 → 에러 토스트

### 7.4 에러 흐름 — 목록 실패

1. 목록 GET 실패 → 에러 토스트 + empty 테이블, [조회]로 재시도

---

**참조**

- REQ-F2-outbound.md §3 FR-F2-01~06, §5.1~§5.3
- REQ-F4-status-transition.md §5.1~§5.2
- UI-F1-inbound.md (UX 대칭)
- project-standards.md §2.2, §3.2, §4.2, §5
- coding-standards.md §5.6~§5.8
