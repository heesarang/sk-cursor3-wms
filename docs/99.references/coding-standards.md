# 개발 표준 — 네이밍·패키지·API·프론트엔드 규칙

## 1. 백엔드 패키지 구조

```
backend/src/main/java/{base-package}/
├── config/
├── controller/
├── service/
├── mapper/
└── exception/

```

패키지 루트는 프로젝트에 따라 달라진다. (예: `com.execnt.wms`)

---

## 2. 백엔드 클래스 네이밍


| 계층          | 패턴                       | 예시                           |
| ----------- | ------------------------ | ---------------------------- |
| Controller  | `{Domain}Controller`     | `OrderController`            |
| Service     | `{Domain}Service`        | `OrderService`               |
| Mapper      | `{Domain}Mapper`         | `OrderMapper`                |
| MyBatis XML | `{Domain}Mapper.xml`     | `OrderMapper.xml`            |
| 예외 클래스      | `{Meaning}Exception`     | `InvalidTransitionException` |
| 전역 예외 처리    | `GlobalExceptionHandler` | —                            |
| 설정 클래스      | `{Purpose}Config`        | `SecurityConfig`             |


- Controller에 비즈니스 로직을 넣지 않는다
- SQL은 MyBatis XML에만 작성한다
- 계층 흐름: Controller → Service → Mapper → MyBatis XML

---

## 3. MyBatis XML

경로: `backend/src/main/resources/mapper/`

namespace: Mapper 인터페이스의 FQCN (예: `{base-package}.mapper.{Domain}Mapper`)

### SQL ID 네이밍


| 유형        | 패턴                      | 예시                   |
| --------- | ----------------------- | -------------------- |
| 목록 조회     | `select{Domain}List`    | `selectOrderList`    |
| 단건 조회     | `select{Domain}Detail`  | `selectOrderDetail`  |
| 상세 라인 조회  | `select{Domain}Lines`   | `selectOrderLines`   |
| 상태 업데이트   | `update{Domain}Status`  | `updateOrderStatus`  |
| 이력 INSERT | `insert{Domain}History` | `insertOrderHistory` |
| 건수 조회     | `select{Domain}Count`   | `selectOrderCount`   |


---

## 4. API 규칙

### 4.1 경로 패턴

```
/api/{domain}/{resource}

```


| 동작    | Method | 패턴                                          | 예시                                |
| ----- | ------ | ------------------------------------------- | --------------------------------- |
| 목록 조회 | GET    | `/api/{domain}/{resource}`                  | `/api/order/items`                |
| 단건 조회 | GET    | `/api/{domain}/{resource}/{key}`            | `/api/order/items/001`            |
| 상태 변경 | POST   | `/api/{domain}/{resource}/{key}/transition` | `/api/order/items/001/transition` |


구체적인 API 경로와 파라미터는 요구사항 정의서(REQ §5)에서 확정한다.

### 4.2 응답 형식

성공:

```json
{
  "success": true,
  "data": { ... }
}

```

목록 성공:

```json
{
  "success": true,
  "data": [ ... ]
}

```

에러:

```json
{
  "success": false,
  "message": "에러 메시지"
}

```

### 4.3 Swagger / OpenAPI

- Springdoc OpenAPI 사용
- Controller에 `@Tag`, `@Operation` 어노테이션 필수
- Swagger UI: `http://{host}:{port}/swagger-ui.html`
- API 스펙: `http://{host}:{port}/v3/api-docs`

### 4.4 프론트엔드 ↔ 백엔드 연동 주의사항

- 백엔드와 프론트엔드가 다른 포트에서 실행되면 브라우저는 교차 출처(Cross-Origin) 요청으로 판단한다
- `api.js`의 `API_BASE`는 백엔드가 실제로 실행 중인 주소·포트와 일치해야 한다
- curl은 CORS를 검사하지 않으므로 curl 성공이 브라우저 성공을 보장하지 않는다
- 백엔드에 CORS 전용 SecurityConfig가 필요하다: `allowedOriginPatterns("*")`, `allowedMethods`, `allowedHeaders("*")`, `setAllowPrivateNetwork(true)`
- 상세 SecurityConfig 코드는 `docs/99.references/backend-config.md`를 참조한다

---

## 5. 프론트엔드 구조 (Vue 3 CDN SPA)

빌드 도구 없이 CDN만으로 동작하는 SPA 구조.

```
frontend/
├── index.html          # SPA 진입점 (CDN 임포트, Vue 앱 마운트)
├── app.js              # Vue 앱 생성, 플러그인·전역 컴포넌트 등록
├── router.js           # Vue Router 라우팅 정의
├── js/
│   ├── api.js          # API 호출 중앙 집중 (API_BASE 한 곳 관리)
│   └── common.js       # 공통 유틸리티
├── views/              # 페이지 컴포넌트
├── components/         # 재사용 컴포넌트
└── css/                # Tailwind CDN 사용, 별도 CSS 최소화

```

### 5.1 기술 스택

- Vue 3 CDN (Options API)
- Vue Router CDN (Hash History)
- Element Plus CDN
- Tailwind CSS CDN
- Axios CDN

### 5.2 index.html

CDN 임포트 순서: Tailwind CSS → Vue 3 → Vue Router → Element Plus (CSS + JS) → Axios

스크립트 로드 순서: `common.js` → `api.js` → `components/*.js` → `views/*.js` → `router.js` → `app.js`

### 5.3 app.js

```javascript
const app = Vue.createApp({});
// 전역 컴포넌트 등록
// app.component('{name}', {Component});
app.use(ElementPlus);
app.use(router);
app.mount('#app');

```

### 5.4 router.js

```javascript
const routes = [
  // { path: '/{route}', component: {Component} },
];

const router = VueRouter.createRouter({
  history: VueRouter.createWebHashHistory(),
  routes,
});

```

### 5.5 api.js

```javascript
const API_BASE = 'http://localhost:8080';

const api = {
  // {domain}: {
  //   list: (params) => axios.get(`${API_BASE}/api/{domain}/{resource}`, { params }),
  //   detail: (key) => axios.get(`${API_BASE}/api/{domain}/{resource}/${key}`),
  //   transition: (key, body) => axios.post(`${API_BASE}/api/{domain}/{resource}/${key}/transition`, body),
  // },
};

```

### 5.6 페이지 컴포넌트 패턴 (views/)

Options API 전역 변수 방식. UI 설계서의 컬럼·필터·액션 정의를 빠짐없이 구현한다.

```javascript
const {DomainName}List = {
  template: `
    <div>
      <!-- 필터 영역: UI 설계서의 필터 정의를 따른다 -->
      <!-- 데이터 테이블: UI 설계서의 목록 컬럼 정의를 따른다 -->
      <!-- 상태 컬럼은 공통 상태 태그 컴포넌트를 사용한다 -->
      <!-- 행 클릭 시 상세 다이얼로그 열기 -->
    </div>
  `,
  data() {
    return { list: [], filter: {}, showDetail: false, selectedKey: null };
  },
  mounted() { this.fetchList(); },
  methods: {
    async fetchList() { /* api.{domain}.list 호출 */ },
    openDetail(row) { /* 상세 다이얼로그 열기 */ },
  },
};

```

### 5.7 다이얼로그 컴포넌트 패턴 (components/)

```javascript
const {DomainName}Detail = {
  template: `
    <el-dialog :model-value="visible" @close="$emit('close')">
      <!-- 헤더 정보: UI 설계서의 상세 헤더 필드를 따른다 -->
      <!-- 라인 테이블: UI 설계서의 상세 라인 컬럼을 따른다 (수량 등 포함) -->
      <!-- 액션 버튼: UI 설계서의 상태별 액션 매핑을 따른다 -->
      <!--   현재 상태에서 가능한 다음 상태 버튼만 표시 -->
      <!--   클릭 시 ElMessageBox.confirm 후 transition API 호출 -->
    </el-dialog>
  `,
  props: ['visible'],
  emits: ['close', 'refresh'],
  data() { return { detail: null, lines: [] }; },
  watch: { visible(val) { if (val) this.fetchDetail(); } },
  methods: {
    async fetchDetail() { /* api.{domain}.detail 호출 */ },
    async changeStatus(toStatus, reason) { /* 확인 → transition → 재조회 → emit refresh */ },
  },
};

```

### 5.8 사용자 피드백 규칙


| 상황       | 처리                                          |
| -------- | ------------------------------------------- |
| API 에러   | `ElementPlus.ElMessage.error(message)`      |
| 위험 동작 확인 | `ElementPlus.ElMessageBox.confirm(message)` |
| 성공 알림    | `ElementPlus.ElMessage.success(message)`    |


---

## 6. DB 네이밍 규칙

정본은 `.cursor/rules/06-database.mdc`다. 여기서는 요지만 적는다.

- 스키마 `wms`, 테이블 접두어 없음. 테이블명은 두 단어 이상 단수 snake_case, 기준정보는 `_info`
- PK: `{테이블명}_id BIGINT GENERATED BY DEFAULT AS IDENTITY`, 제약명 `{테이블명}_pk`. 업무 식별자는 `_ux1` UNIQUE
- FK: 컬럼명·타입은 부모 PK와 동일, 제약명 `{테이블명}_{부모테이블명}_fk`, FK 컬럼은 인덱스 선두
- 컬럼: 두~세 단어 snake_case. 접미어 `_id` `_no` `_name` `_code` `_qty` `_amount` `_at` `_date`. 약어(`_cd`, `_nm`, `_yn`) 금지
- 여부: `BOOLEAN is_*`. 일시: `TIMESTAMPTZ`. 문자열: `VARCHAR(n)`
- 공통 컬럼 (모든 테이블 맨 뒤):

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT now()` | 생성 일시 |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT now()` | 수정 일시 |
| `created_by` | `VARCHAR(50) NOT NULL` | 생성자 |
| `updated_by` | `VARCHAR(50) NOT NULL` | 수정자 |

- 모든 테이블·컬럼에 한글 COMMENT. `_code` 컬럼은 코드그룹 명시
- 기준 DDL은 `database/schemas/wms_ddl.sql` 하나. 변경은 `database/migrations/YYYYMMDD_NNN_설명.sql` + 기준 DDL 동기화. `DROP TABLE ... CASCADE` 재생성 방식 금지
- 형식 점검: `database/tools/std_check.sql` (위반 0 = PASS)
