# UI 설계 — 상태 현황 대시보드

| 항목 | 내용 |
|------|------|
| 문서 ID | UI-F3-dashboard |
| 버전 | 1.0 |
| 기준 Task | TASK-UI-F3-dashboard |
| 기준 요구사항 | REQ-F3-dashboard.md §3·§5 |
| 라우트 | `#/dashboard` (앱 기본 진입 권장) |
| 기술 스택 | Vue 3 (CDN), Element Plus, Tailwind CSS, Axios |
| 성격 | 읽기 전용 (상태 전이 없음) |

## 1. 화면 개요

입고·출고 상태별 건수 요약, 최근 상태 변경 이력, 특정 주문의 전체 이력 추적을 한 화면에서 제공한다. 요약은 선택적으로 센터로 범위를 좁힌다.

| 항목 | 내용 |
|------|------|
| 주요 사용자 목표 | 입출고 현황 파악 → 최근 변경 확인 → 주문별 이력 추적 |
| 진입 | 네비게이션 「대시보드」 → `#/dashboard` |
| 연계 | 입고(`#/inbound`)·출고(`#/outbound`)로 이동해 전이 작업 가능 (본 화면에서는 전이 버튼 없음) |

## 2. 레이아웃 (와이어프레임)

```
┌─────────────────────────────────────────────────────────────┐
│ [네비] 대시보드* | 입고 | 출고                                 │
├─────────────────────────────────────────────────────────────┤
│ 상태 현황 대시보드                                            │
│                                                              │
│ ┌─ A. 요약 필터 ──────────────────────────────────────────┐ │
│ │ 센터 [el-select ▼ 전체/CTR01/CTR02]  [새로고침]          │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌─ 입고 요약 ─────────────┐  ┌─ 출고 요약 ────────────────┐ │
│ │ [카드/통계]              │  │ [카드/통계]                 │ │
│ │ 00 주문생성   N          │  │ 00 주문생성   N             │ │
│ │ 10 검수중     N          │  │ 10 피킹중     N             │ │
│ │ 20 검수완료   N          │  │ 20 피킹완료   N             │ │
│ │ 90 입고확정   N          │  │ 90 출고확정   N             │ │
│ └──────────────────────────┘  └─────────────────────────────┘ │
│                                                              │
│ ┌─ B. 최근 상태 변경 이력 ────────────────────────────────┐ │
│ │ limit [el-input-number] [조회]                          │ │
│ │ el-table: 유형|주문번호|from→to|변경자|사유|변경일시     │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌─ C. 주문 이력 추적 ─────────────────────────────────────┐ │
│ │ 유형 [INBOUND|OUTBOUND]  주문번호 [____]  [추적]        │ │
│ │ (타임라인 또는 el-table: from→to | 변경자 | 사유 | 일시) │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

영역 A·B·C는 세로 스택. Tailwind로 요약 카드 그리드(md: 2열).

## 3. 컴포넌트 구성

### 3.1 페이지 — `DashboardView` (`views/DashboardView.js` 예정)

단일 페이지에 세 섹션. 필요 시 하위 컴포넌트 분리 가능 (`SummaryCards`, `RecentHistoryTable`, `OrderTracePanel`).

### 3.2 섹션 A — 입출고 상태별 요약

| 요소 | 컴포넌트 | 설명 |
|------|----------|------|
| 센터 필터 | `el-select` | 전체(빈 값) / `CTR01` / `CTR02` → Query `center_no` |
| 새로고침 | `el-button` | 요약·(선택) 최근 이력 재조회 |
| 입고 카드군 | `el-card` 또는 통계 블록 | `data.inbound[]`: status별 `order_count` |
| 출고 카드군 | 동일 | `data.outbound[]` |

각 상태 건수 옆에 `el-tag`로 상태 표시 (입고/출고 각각 §5 색상).

건수 0이어도 상태 슬롯은 표시(API가 0건을 주면 그대로; 누락 시 UI에서 0으로 보정 가능).

### 3.3 섹션 B — 최근 상태 변경 이력

| 요소 | 컴포넌트 | 설명 |
|------|----------|------|
| limit | `el-input-number` | 기본 20, 최소 1, 최대 100 권장 |
| 조회 | `el-button` | `GET .../history/recent?limit=` |
| 테이블 | `el-table` | 시간 역순(서버 정렬) |

**컬럼**

| 컬럼 | 필드 | 표시 |
|------|------|------|
| 유형 | `order_type` | `INBOUND` / `OUTBOUND` (`el-tag` 구분 가능) |
| 주문번호 | `order_no` | 텍스트 (클릭 시 추적 폼에 자동 채움 — Should) |
| 이전→이후 | `from_status_code` → `to_status_code` | 코드 또는 표시명+tag |
| 변경자 | `changed_by` | 텍스트 |
| 사유 | `change_reason` | 텍스트 |
| 변경일시 | `changed_at` | 로컬 포맷 |

### 3.4 섹션 C — 주문 이력 추적

| 요소 | 컴포넌트 | 설명 |
|------|----------|------|
| 주문 유형 | `el-select` / `el-radio-group` | `INBOUND` \| `OUTBOUND` (필수) |
| 주문번호 | `el-input` | 필수, 예: `IB-CTR01-020` |
| 추적 | `el-button` type=primary | 유효성 통과 후 API 호출 |
| 결과 | `el-timeline` 또는 `el-table` | `histories[]` 시간순 |

**이력 행 필드**: `from_status_code`, `to_status_code`, `changed_by`, `change_reason`, `changed_at`

타임라인 사용 시 각 노드에 `from → to` + 사유 + 일시 표시.

## 4. API 연동 매핑

REQ-F3-dashboard.md §5 기준.

| UI 동작 | Method | Path | 요청 | 성공 후 UI |
|---------|--------|------|------|------------|
| 화면 진입 / 센터 변경 / [새로고침] | `GET` | `/api/dashboard/summary` | Query: `center_no?` | 입고·출고 요약 카드 갱신 |
| 진입(기본) / limit 변경 [조회] | `GET` | `/api/dashboard/history/recent` | Query: `limit?` (기본 20) | 최근 이력 테이블 |
| [추적] | `GET` | `/api/dashboard/history/trace` | Query: `order_type`(Y), `order_no`(Y) | 추적 패널에 `histories` |

**진입 시 권장 호출 순서**

1. `GET /api/dashboard/summary` (center 미지정 = 전체)
2. `GET /api/dashboard/history/recent?limit=20`
3. 추적은 사용자 [추적] 시에만 호출

## 5. 상태별 표시 규칙

대시보드는 전이 UI가 없으나, 요약·이력의 상태 표시는 project-standards §4를 따른다.

### 5.1 입고 (`INB_STATUS`) — 요약·이력 태그

| status_code | 표시명 | el-tag type |
|-------------|--------|-------------|
| `00` | 주문생성 | `info` |
| `10` | 검수중 | `warning` |
| `20` | 검수완료 | `primary` |
| `90` | 입고확정 | `success` |

### 5.2 출고 (`OUT_STATUS`)

| status_code | 표시명 | el-tag type |
|-------------|--------|-------------|
| `00` | 주문생성 | `info` |
| `10` | 피킹중 | `warning` |
| `20` | 피킹완료 | `primary` |
| `90` | 출고확정 | `success` |

이력 행의 from/to는 `order_type`에 따라 위 매핑을 적용한다.  
`order_type` 자체: `INBOUND` → `info` 또는 plain text, `OUTBOUND` → `warning` 또는 plain text (구분만 명확하면 됨).

## 6. 에러·예외 피드백

| 상황 | HTTP / 응답 | UI 처리 |
|------|-------------|---------|
| 요약 실패 | 500, `대시보드 요약 조회 중 오류가 발생했습니다` | `ElMessage.error`, 카드 영역 empty/오류 문구 |
| limit 비정상 | 400, `limit은 1 이상이어야 합니다` | `ElMessage.error`, 테이블 유지 |
| 추적 — 주문 없음 | 404, `주문을 찾을 수 없습니다: INBOUND / ...` | `ElMessage.error`, 추적 결과 영역 비움 |
| 추적 — 필수값 누락 | 400, `order_type과 order_no는 필수입니다` | 클라이언트 선검증 + 서버 400 시 `ElMessage.error` |
| 성공 (요약/이력/추적) | 200 | 해당 영역만 갱신 (전역 성공 토스트는 생략 가능; 추적은 선택적 success) |

클라이언트 선검증: `order_type`·`order_no` 비어 있으면 API 미호출, `ElMessage.warning('주문 유형과 주문번호를 입력하세요')`.

## 7. 사용자 시나리오

### 7.1 정상 흐름 — 요약 확인 → 최근 이력 → 주문 추적

1. `#/dashboard` 진입  
   → `GET /api/dashboard/summary`  
   → `GET /api/dashboard/history/recent?limit=20`  
   → 입고/출고 상태별 건수 카드 + 최근 이력 테이블 표시
2. 센터 `CTR01` 선택 → `GET /api/dashboard/summary?center_no=CTR01` → 요약만 갱신
3. limit `10`으로 변경 후 [조회] → `GET /api/dashboard/history/recent?limit=10` → 테이블 갱신
4. 주문 유형 `INBOUND`, 주문번호 `IB-CTR01-020` 입력 후 [추적]  
   → `GET /api/dashboard/history/trace?order_type=INBOUND&order_no=IB-CTR01-020`  
   → 시간순 이력 타임라인/테이블 표시
5. (선택) 최근 이력 행의 주문번호 클릭 → 추적 폼에 `order_type`·`order_no` 채움 → [추적]과 동일 API

### 7.2 에러 흐름 — 404 / 400

1. 존재하지 않는 주문번호로 [추적] → HTTP 404 → `ElMessage.error(message)`, 결과 영역 비움
2. `order_type` 또는 `order_no` 없이 [추적] → 클라이언트 경고 또는 서버 400 → 에러 피드백
3. limit `0` 이하로 최근 이력 조회 → 400 → `ElMessage.error`

### 7.3 에러 흐름 — 요약 조회 실패

1. 요약 API 500 → 에러 토스트, 카드 empty; 최근 이력은 독립적으로 유지 가능  
2. [새로고침]으로 재시도

---

**참조**

- REQ-F3-dashboard.md §3 FR-F3-01~05, §5.1~§5.3
- project-standards.md §4
- coding-standards.md §5.8
- UI-F1-inbound.md / UI-F2-outbound.md (상태 표시·네비 일관성)
