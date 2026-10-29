<!--
[사용법] /my-create-verify — 앱 반영 후
[목적] 등록·전역 진입·회귀. 범위 확대 금지
[다음] 체인 종료
-->

# 등록 기능 검증 (`/my-create-verify`)

## 프리플라이트

서버 생존 (`/v3/api-docs` 등). 실패 시 코드 수정 없이 환경 보고 후 중단.

## 검증 (기본 = 비파괴에 가깝게)

IMPACT 도메인 기준으로:

1. **전역 진입** — 코드상 `AppNav`(등)에 등록 버튼이 있고, 특정 목록에만 묶이지 않음  
2. **등록 API** — 가능하면 1건 `POST` 성공(테스트 주문). 시드 대량 소모·확정 전이 연쇄는 하지 않음. 파괴적 대량 INSERT 금지  
3. **목록/상세** — 생성분이 조회되거나, 응답 `data`에 `order_no`·상태 `00`  
4. **회귀** — 대시보드 summary, 반대 도메인 목록, 불허 전이 1건(400)  
5. **ALLOWED_PATHS 대조표** 필수  

등록 POST가 환경상 어렵면: Mapper/Controller에 엔드포인트 존재 + 프론트 바인딩 확인을 보고하고 `app_verified: 부분`.

## 플래그

- `files_synced` / `db_applied`(해당 시) / `app_verified` / `regression_ok`

## 종료

```
## /my-create-verify 완료 — 체인 종료
- files_synced / db_applied / app_verified / regression_ok: ...
- 커밋·push는 사용자 요청 시만
```

다음 등록 기능(예: 출고)은 PRD 준비 후 **`/my-create-plan`부터** 새 IMPACT로 시작한다.
