# UI 설계 — 입고 관리

| 항목 | 내용 |
|------|------|
| 문서 ID | UI-F1-inbound |
| 버전 | 1.0 |
| 기준 Task | TASK-UI-F1-inbound |
| 기준 요구사항 | REQ-F1-inbound.md §3·§5, REQ-F4-status-transition.md |
| 라우트 | `#/inbound` |
| 기술 스택 | Vue 3 (CDN), Element Plus, Tailwind CSS, Axios |

## 1. 화면 개요

입고 주문 목록을 센터·상태로 필터 조회하고, 행 클릭으로 상세(헤더·라인)를 다이얼로그에서 확인한 뒤, 허용된 다음 상태로만 전이한다. 화면에서 주문을 신규 생성하지 않는다 (시드·외부 수신 전제).

| 항목 | 내용 |
|------|------|
| 주요 사용자 목표 | 입고 진행 상태 확인 및 검수시작→검수완료→입고확정 |
| 진입 | 앱 네비게이션 「입고」 → `#/inbound` |
| 관련 화면 | 대시보드(`#/dashboard`)에서 이력 추적 가능 |

## 2. 레이아웃 (와이어프레임)

```
┌─────────────────────────────────────────────────────────────┐
│ [네비] 대시보드 | 입고* | 출고                                   │
├─────────────────────────────────────────────────────────────┤
│ 입고 주문 관리                                                │
│ ┌─ 필터 ──────────────────────────────────────────────────┐ │
│ │ 센터 [el-select ▼]  상태 [el-select ▼]  [조회] [초기화]   │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌─ el-table ──────────────────────────────────────────────┐ │
│ │ 주문번호 │ 센터 │ 상태(tag) │ 주문일시 │ 담당자 이름 │ 담당자 연락처 │ (행 클릭→상세) │ │
│ │ ...                                                      │ │
│ └─────────────────────────────────────────────────────────┘ │
│ (페이지네이션: 클라이언트 단 선택 — API 미제공 시 전체 표시)   │
└─────────────────────────────────────────────────────────────┘

┌─ el-dialog: 입고 주문 상세 ───────────────────────────────┐
│ 주문번호 / 센터 / 상태(tag) / 주문일시 / 담당자 이름 / 연락처 │
│ ┌─ 라인 el-table ───────────────────────────────────────┐ │
│ │ 라인 │ SKU │ 품목명 │ 주문수량 │ 검수확정수량           │ │
│ └───────────────────────────────────────────────────────┘ │
│            [검수시작] [검수완료] [입고확정]  ← 허용된 것만   │
│                                            [닫기]          │
└────────────────────────────────────────────────────────────┘
```

## 3. 컴포넌트 구성

### 3.1 페이지 — `InboundList` (`views/InboundList.js` 예정)

| 영역 | Element Plus | 설명 |
|------|--------------|------|
| 필터 | `el-select` (센터), `el-select` (상태), `el-button` | 센터·상태 선택 후 조회. 미선택은 전체 |
| 목록 | `el-table`, `el-tag` | 행 클릭 시 상세 다이얼로그 |
| 로딩 | `v-loading` / `el-skeleton` | 목록·상세 조회 중 |

**필터 옵션**

| 필드 | 바인딩 | 옵션 |
|------|--------|------|
| 센터 | `filter.center_no` | 전체(빈 값), `CTR01`, `CTR02` (시드 기준; 마스터 API 없으면 하드코드/상수) |
| 상태 | `filter.status_code` | 전체(빈 값), `00` 주문생성, `10` 검수중, `20` 검수완료, `90` 입고확정 |

**목록 컬럼**

| 컬럼 | 필드 | 표시 |
|------|------|------|
| 주문번호 | `order_no` | 텍스트 |
| 센터 | `center_no` + `center_name` | 예: `CTR01 (서울센터)` |
| 상태 | `status_code` / `status_name` | `el-tag` (§5) |
| 주문일시 | `ordered_at` | 로컬 포맷 (YYYY-MM-DD HH:mm) |
| 담당자 이름 | `partner_contact_name` | 텍스트 (NULL이면 `-`), 연락처와 인접 |
| 담당자 연락처 | `partner_contact_tel` | 텍스트 (NULL이면 `-`) |

### 3.2 다이얼로그 — `InboundDetail` (`components/InboundDetail.js` 예정)

| 영역 | 구성 |
|------|------|
| 헤더 | `order_no`, `center_no`/`center_name`, `status_code`/`status_name`(tag), `ordered_at`, `partner_contact_name`, `partner_contact_tel` |
| 라인 테이블 | `line_no`, `sku_no`, `item_name`, `order_qty`, `inspected_qty` |
| 액션 | 현재 `status_code`에서 허용된 전이 버튼만 노출 |
| 닫기 | `el-dialog` `@close` → 목록 유지 |

**상태별 액션 버튼 (현재 상태에서 허용된 것만)**

| 현재 status_code | 버튼 라벨 | to_status | `el-button` type 권장 |
|------------------|-----------|-----------|----------------------|
| `00` | 검수시작 | `10` | primary |
| `10` | 검수완료 | `20` | primary |
| `20` | 입고확정 | `90` | success |
| `90` | (없음) | — | 종료 — 액션 영역 비활성/안내 문구 |

전이 클릭 시 `ElMessageBox.confirm` 후 Body에 `to_status`, `changed_by`, `change_reason` 전달.  
`changed_by` 기본값: `demo-user` (입력 필드 선택 제공 가능). `change_reason` 기본값: 버튼 라벨과 동일.

### 3.3 공통

- 상태 태그: 공통 헬퍼/컴포넌트 (`status_code` → `el-tag` `type`)
- 피드백: `ElMessage.success` / `ElMessage.error`, 확인: `ElMessageBox.confirm` (coding-standards.md §5.8)

## 4. API 연동 매핑

REQ-F1-inbound.md §5 기준. 임의 경로 사용 금지.

| UI 동작 | Method | Path | 요청 | 성공 후 UI |
|---------|--------|------|------|------------|
| 화면 진입 / [조회] | `GET` | `/api/inbound/orders` | Query: `center_no?`, `status_code?` | `el-table`에 `data[]` 바인딩 |
| [초기화] | — | — | 필터 클리어 후 동일 GET (파라미터 없음) | 전체 목록 |
| 행 클릭 / 상세 오픈 | `GET` | `/api/inbound/orders/{orderNo}` | Path: `orderNo` | 다이얼로그에 헤더·`lines` 표시 |
| 검수시작 / 검수완료 / 입고확정 (확인 후) | `POST` | `/api/inbound/orders/{orderNo}/transition` | Body: `{ to_status, changed_by, change_reason }` | 상세 재조회 + 목록 `refresh` + 성공 토스트 |
| (선택) 버튼 구성용 규칙 | `GET` | `/api/status-transitions/rules?order_kind=INBOUND` | Query: `order_kind=INBOUND` | 현재 상태→허용 to만 버튼 노출 (미구현 시 클라이언트 고정 표 사용) |

**전이 Body 예시** (검수시작)

```json
{
  "to_status": "10",
  "changed_by": "demo-user",
  "change_reason": "검수시작"
}
```

## 5. 상태별 표시 규칙

`project-standards.md` §4.1 / coding-standards 상태 태그 규격.

| status_code | 표시명 | el-tag type |
|-------------|--------|-------------|
| `00` | 주문생성 | `info` |
| `10` | 검수중 | `warning` |
| `20` | 검수완료 | `primary` |
| `90` | 입고확정 | `success` |

- 목록·상세 헤더 모두 동일 매핑
- 태그 텍스트는 API `status_name` 우선, 없으면 위 표시명

## 6. 에러·예외 피드백

| 상황 | HTTP / 응답 | UI 처리 |
|------|-------------|---------|
| 목록 조회 실패 | 500, `{ success:false, message }` | `ElMessage.error(message)` , 테이블 빈 상태 |
| 상세 없음 | 404, 예: `입고 주문을 찾을 수 없습니다: ...` | `ElMessage.error(message)`, 다이얼로그 닫기 또는 빈 상세 |
| 비허용 전이 (건너뛰기·종료 재전이 등) | 400, 예: `허용되지 않은 상태 전이입니다: INBOUND 00 → 20` | confirm 후 호출 → `ElMessage.error(message)`, 상태·버튼 유지 |
| 네트워크/기타 | — | `ElMessage.error` (응답 message 또는 일반 문구) |
| 전이 성공 | 200 | `ElMessage.success` (예: `상태가 '검수중'으로 변경되었습니다`) |

상태 변경 전 확인 문구 예:  
`「검수시작」을 진행하시겠습니까? (00 → 10)`

## 7. 사용자 시나리오

### 7.1 정상 흐름 — 목록 조회 및 검수시작

1. 사용자가 `#/inbound` 진입 → `GET /api/inbound/orders` 호출 → 목록 표시
2. 센터 `CTR01`, 상태 `00` 선택 후 [조회] → `GET /api/inbound/orders?center_no=CTR01&status_code=00`
3. 행 `IB-CTR01-001`(또는 시드 00 주문) 클릭 → `GET /api/inbound/orders/{orderNo}` → 상세 다이얼로그, 라인·`inspected_qty` 표시, **검수시작**만 활성
4. [검수시작] 클릭 → `ElMessageBox.confirm`
5. 확인 → `POST .../transition` Body `to_status:"10"`, `changed_by:"demo-user"`, `change_reason:"검수시작"`
6. 성공 → 성공 토스트, 상세 재조회(상태 `10`·태그 warning), 목록 refresh → 버튼이 **검수완료**로 교체

### 7.2 정상 흐름 — 검수완료 → 입고확정

1. 상태가 `10`인 주문 상세에서 [검수완료] → confirm → `to_status:"20"` → 상태 `20`, 태그 primary, 버튼 **입고확정**
2. [입고확정] → confirm → `to_status:"90"` → 상태 `90`, 태그 success, 전이 버튼 없음

### 7.3 에러 흐름 — 비허용 전이

1. 시드 `IB-INVALID-TRANS`(status `90`) 상세 오픈 → 전이 버튼 없음 (정상 UX)
2. (개발/강제 호출 시) 90→10 등 비허용 POST → HTTP 400 + message → `ElMessage.error`로 사유 표시, 화면 상태 불변
3. 목록에서 존재하지 않는 주문번호로 상세 요청 시 404 → `ElMessage.error`

### 7.4 에러 흐름 — 목록 조회 실패

1. 백엔드 오류로 목록 GET 실패 → 에러 토스트, 테이블 empty / 재시도는 [조회] 재클릭

---

**참조**

- REQ-F1-inbound.md §3 FR-F1-01~06, §5.1~§5.3
- REQ-F4-status-transition.md §5.1(선택 규칙 API), §5.2
- project-standards.md §2.1, §3.1, §4.1, §5
- coding-standards.md §5.6~§5.8
