# 반입 내역 (BASELINE)

3차수 저장소의 출발점이 어디서 왔고 무엇을 바꿨는지 기록한다. 기준: 2차수 저장소 `skax-cusror-agent-wms` main HEAD(2026-06-30).

## 가져온 것

| 영역 | 내용 | 변경 |
|---|---|---|
| `.cursor/rules/` | 2차수 Rule 6종 | 확장자 `.md` → `.mdc`. `05`·`06`은 3차수 DB 표준으로 재작성. `00-rule-authoring.mdc` 추가(mySUNI 자산) |
| `.cursor/commands/` | 5종 | `run-sql-check`에 std_check 항목 추가. `update-rule` 추가(mySUNI 자산, Rule 목록 교체) |
| `.cursor/skills/`, `agents/`, `hooks/` | 그대로 | `hooks.json`·`mcp.json`은 `.example`로만 배포. `status-workflow`·`db-architect`의 테이블명·파일명 참조 갱신 |
| `docs/00.guide/00~09` | 2차수 실습 가이드 | 참고용. 테이블명·DDL 파일명 참조만 3차수 표준으로 갱신. 3차수 진행 순서는 `START-HERE.md`와 `database/README.md` |
| `docs/01.analysis/01.rfp/wms_prd.md` | 기본 PRD | 접두어 문구 갱신. `wms_prd-inventory-flow.md`(F5~F7)는 선택 과제용으로 제외 |
| `docs/99.references/` | 표준 5종 | `coding-standards §6`·`project-standards`·`document-standards` DDL 항목을 3차수 표준으로 갱신. `data-dictionary.md`는 뼈대만 |
| `backend/` | Gradle 래퍼·`build.gradle`·`settings.gradle` | group `com.carfix` → `com.execnt.wms`, Java 17 → 21, JWT 의존성 제거, `application.yml` → `.example` |
| `database/` | — | 2차수 DDL·시드·검증 SQL은 반입하지 않음(강사용 보관). `tools/std_check.sql`·`reset_schema.sql`, `init/00_roles.sql` 추가 |
| `scripts/` | 3종 | `run-be-api-tests.sh`의 `status_cd` → `status_code` |

## 반입하지 않은 것 (강사용 보관)

- 2차수 완주 결과물: `backend/src`, `frontend/`, `docs/01.analysis/02~04`, `test-reports` (2차수 저장소 `result/2nd-cohort` 브랜치)
- 정답 DDL·시드·검증: 3차수 표준으로 재작성한 `wms_ddl.sql`, `seeds/*.sql`, `tools/verify_schema.sql` (강사 폴더)
- 2차수 강의자료 pdf, 데이터 사전 본문

## DB 표준 전환 요지

2차수 DDL(업무키 PK, `_cd`·`_nm` 약어, `use_yn CHAR(1)`, `twms_` 접두어, 컬럼 COMMENT 없음)을 사내 PostgreSQL 오브젝트 가이드 기준으로 재작성했다. 대리키 `{테이블}_id IDENTITY`, 접두어 없음, 완전 단어 컬럼명, `BOOLEAN is_*`, `TIMESTAMPTZ`, 전 컬럼 COMMENT. 2차수 DDL을 `std_check.sql`에 넣으면 위반 142건(R02 74, R11 27, R07 22, R04 9, R05 6, R09 2, R13 2)이고, 3차수 정답 DDL은 0건이다.
