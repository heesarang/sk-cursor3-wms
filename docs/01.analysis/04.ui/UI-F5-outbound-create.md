# UI 설계 — 출고 주문 등록

| 항목 | 내용 |
|------|------|
| 문서 ID | UI-F5-outbound-create |
| 기준 | `wms_prd-outbound-create.md`, `UI-F2-outbound.md` 상세 레이아웃 |

## 진입

- 공통 `AppNav` **[출고 등록]** — `#/dashboard` · `#/inbound` · `#/outbound` 전역 ([입고 등록]과 병존)
- 출고 목록 보조 **[출고 등록]**

## 다이얼로그 `OutboundCreate`

출고 상세와 동일 구조: 헤더 2열 + 라인 테이블 + 저장/취소.

| 영역 | 입력 |
|------|------|
| 주문번호 | 자동 채번 안내 |
| 센터 | select |
| 상태 | `00` 태그 |
| 주문일시 | 서버 등록 시각 |
| 담당자 이름·연락처 | input |
| 라인 | SKU, order_qty, 피킹=0, 추가/삭제 |
| 액션 | 저장(등록) / 취소 |

성공 시 토스트·닫기. `#/outbound`이면 목록 갱신 (`wms-outbound-created`).
