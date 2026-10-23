# 산출물 표준 — 네이밍·구조·참조 규칙

## 1. 산출물 경로

| 산출물 | 경로 |
|--------|------|
| PRD 원문 | `docs/01.analysis/01.rfp/wms_prd.md` |
| 요구사항 정의서 | `docs/01.analysis/02.requirements/` |
| Task 정의서 | `docs/01.analysis/03.tasks/` |
| UI 설계서 | `docs/01.analysis/04.ui/` |
| 참조 문서 | `docs/99.references/` |
| DDL·초기 데이터 | `database/schemas/` |
| 백엔드 소스 | `backend/src/main/java/com/execnt/wms/` |
| MyBatis XML | `backend/src/main/resources/mapper/` |
| 프론트엔드 | `frontend/` |
| 테스트 리포트 | `docs/test-reports/` |
| 헬퍼 스크립트 | `scripts/` |

---

## 2. 파일 네이밍 규칙

### 2.1 요구사항 정의서

패턴: `REQ-{기능ID}-{영문도메인}.md`

| 파일명 | 대상 |
|--------|------|
| `REQ-F1-inbound.md` | F1 입고 관리 |
| `REQ-F2-outbound.md` | F2 출고 관리 |
| `REQ-F3-dashboard.md` | F3 대시보드 |
| `REQ-F4-status-transition.md` | F4 상태 전이 |

기능이 밀접하게 연관된 경우 하나로 합칠 수 있다. 예: `REQ-F1-F4-inbound.md` (입고 + 입고 상태 전이)

### 2.2 Task 정의서

패턴: `TASK-{에이전트약어}-{기능ID}-{영문도메인}.md`

에이전트 약어:

| 약어 | 에이전트 |
|------|---------|
| DB | db-architect |
| BE | backend-developer |
| FE | frontend-developer |
| UI | ui-designer |
| TEST-BE | test-backend |
| TEST-INT | test-integration |

예시:

| 파일명 | 대상 |
|--------|------|
| `TASK-DB-F1-inbound.md` | DB — 입고 |
| `TASK-DB-F2-outbound.md` | DB — 출고 |
| `TASK-BE-F1-inbound.md` | 백엔드 — 입고 |
| `TASK-BE-F2-outbound.md` | 백엔드 — 출고 |
| `TASK-BE-F3-dashboard.md` | 백엔드 — 대시보드 |
| `TASK-FE-F1-inbound.md` | 프론트 — 입고 |
| `TASK-FE-F2-outbound.md` | 프론트 — 출고 |
| `TASK-FE-F3-dashboard.md` | 프론트 — 대시보드 |
| `TASK-UI-F1-inbound.md` | UI설계 — 입고 |
| `TASK-UI-F2-outbound.md` | UI설계 — 출고 |
| `TASK-UI-F3-dashboard.md` | UI설계 — 대시보드 |
| `TASK-TEST-BE-F1-inbound.md` | 백엔드테스트 — 입고 |
| `TASK-TEST-BE-F2-outbound.md` | 백엔드테스트 — 출고 |
| `TASK-TEST-BE-F3-dashboard.md` | 백엔드테스트 — 대시보드 |
| `TASK-TEST-INT-all.md` | 통합테스트 — 전체 |

기능 간 공통 Task는 도메인을 `common`으로 한다. 예: `TASK-BE-F4-common.md` (상태 전이 공통 서비스)

### 2.3 UI 설계서

패턴: `UI-{기능ID}-{영문도메인}.md`

| 파일명 | 대상 |
|--------|------|
| `UI-F1-inbound.md` | 입고 화면 |
| `UI-F2-outbound.md` | 출고 화면 |
| `UI-F3-dashboard.md` | 대시보드 화면 |

### 2.4 테스트 리포트

패턴: `REPORT-{테스트유형}-{날짜}.md`

| 파일명 | 대상 |
|--------|------|
| `REPORT-BE-20260513.md` | 백엔드 테스트 리포트 |
| `REPORT-INT-20260513.md` | 통합 테스트 리포트 |

### 2.5 DDL·초기 데이터

패턴: `{순번}_{설명}.sql`

| 파일명 | 내용 |
|--------|------|
| `schemas/wms_ddl.sql` | 기준 DDL (전체 스키마, source of truth) |
| `init/00_roles.sql` | 롤·권한 (관리자가 1회 실행) |
| `seeds/seed_common_code.sql` | 공통코드 |
| `seeds/seed_master.sql` | 센터·상품 기준정보 |
| `seeds/seed_transition_rule.sql` | 상태 전이 규칙 |
| `seeds/seed_sample_order.sql` | 샘플 주문·라인·이력 |
| `migrations/YYYYMMDD_NNN_설명.sql` | 기준 모델 확정 후 변경 이력 |
| `tools/std_check.sql`, `reset_schema.sql`, `verify_schema.sql` | 표준 점검·초기화·적용 확인 |

---

## 3. 문서 표준 구조

### 3.1 요구사항 정의서

```
# 요구사항 정의서 — {기능명}

| 항목 | 내용 |
|------|------|
| 문서 ID | REQ-{기능ID}-{도메인} |
| 버전 | 1.0 |
| 기준 PRD | docs/01.analysis/01.rfp/wms_prd.md — §4 {기능ID} |

## §1. 추적성 (PRD 매핑)
## §2. 상태 모델 (해당 시)
## §3. 기능 요구사항
## §4. 데이터·도메인
## §5. API 설계 초안
### §5.1 ~ §5.N (API별)
  - Method, Path
  - 파라미터 (Query 또는 Body)
  - 성공 응답 예시 (JSON)
  - 에러 응답 예시 (상태 코드 + JSON)
### §5.시드 테스트 시드 전제
## §6. 비기능
## §7. 다음 산출물
```

### 3.2 Task 정의서

```
---
task_id: TASK-{에이전트약어}-{기능ID}-{도메인}
agent: {에이전트 name}
title: "{제목}"
---

# Task: {제목}

## 선행 조건
## 목표
## 상세 작업
## 산출물 경로
## 완료 조건
## 의존성
```

### 3.3 UI 설계서

```
# UI 설계 — {화면명}

## 1. 화면 개요
## 2. 레이아웃 (와이어프레임)
## 3. 컴포넌트 구성
## 4. API 연동 매핑
  - 어떤 버튼/동작이 어떤 API를 호출하는지
## 5. 상태별 표시 규칙
## 6. 에러·예외 피드백
## 7. 사용자 시나리오
  - 정상 흐름 (step by step)
  - 에러 흐름
```

### 3.4 테스트 리포트

```
# 테스트 리포트 — {테스트유형}

| 항목 | 내용 |
|------|------|
| 실행일 | YYYY-MM-DD |
| 대상 | {테스트 범위} |
| 결과 | 통과 N건 / 실패 N건 |

## 테스트 결과 요약

| No | 시나리오 | 기대 결과 | 실제 결과 | 상태 |
|----|---------|-----------|-----------|------|

## 실패 항목 상세 (있을 경우)
## 재현 명령
```

---

## 4. 산출물 간 참조 규칙

| 산출물 | 참조하는 입력 |
|--------|-------------|
| 프로젝트 표준 | PRD (analyst가 생성) |
| 요구사항 정의서 | PRD |
| Task 정의서 | 요구사항 정의서 |
| UI 설계서 | 요구사항 정의서 §3(기능) + §5(API) |
| DDL·초기 데이터 | 요구사항 정의서 §2(상태모델) + §4(데이터) |
| 데이터 딕셔너리 | DDL (db-architect가 DDL과 함께 생성) |
| 백엔드 코드 | Task + DDL + 요구사항 §5 |
| 프론트엔드 코드 | Task + UI 설계서 + 요구사항 §5 |
| 백엔드 테스트 | 요구사항 §5 |
| 통합 테스트 | UI 설계서 (화면 시나리오 기준) |

---

## 5. 문서 갱신 규칙

- 백엔드 개발 시 실제 구현이 요구사항 §5와 다르면, backend-developer가 §5를 갱신한다
- db-architect가 DDL을 변경하면 data-dictionary.md도 함께 갱신한다
- 갱신된 문서가 후속 에이전트의 최신 기준이 된다
