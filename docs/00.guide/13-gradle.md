# 13. Gradle — 백엔드 빌드·실행

> DB 접속·환경변수: [DB-CONNECT.md](DB-CONNECT.md), [backend-config.md](../99.references/backend-config.md). 프론트 실행: [12-live-server.md](12-live-server.md). 환경 준비: [START-HERE.md](START-HERE.md).

## 1. Gradle이란 (이 프로젝트 기준)

백엔드는 **Spring Boot 3** + **Java 21** 소스를 **Gradle**로 컴파일·테스트·실행합니다. 전역 Gradle 설치는 **필수가 아닙니다**. 저장소에 포함된 **Gradle Wrapper**(`backend/gradlew`, `backend/gradlew.bat`)가 Wrapper 버전에 맞는 Gradle을 자동으로 내려받아 사용합니다.

| 항목 | 값 |
|------|-----|
| 프로젝트 루트(Gradle) | `backend/` |
| Wrapper Gradle | **9.1.0** (`backend/gradle/wrapper/gradle-wrapper.properties`) |
| Spring Boot | **3.5.4** (`backend/build.gradle`) |
| 컴파일 타깃 | **Java 21** (`sourceCompatibility = '21'`) |
| 기본 HTTP 포트 | **8080** (Spring Boot 기본) |
| 실행 진입점 | `com.execnt.wms.WmsApplication` |

**JDK vs 컴파일 버전:** 소스는 Java **21** 문법·바이트코드로 빌드됩니다. PC에 **JDK 21**을 쓰는 것이 가장 단순합니다. **JDK 22~25** 등 더 높은 버전으로도 **실행·빌드**할 수 있으나, Wrapper Gradle이 해당 JDK를 인식해야 합니다. JDK 25를 쓰는 경우 이 저장소는 Gradle **9.1+** Wrapper를 사용합니다(낮은 Wrapper는 `class file major version 69` 등 오류가 날 수 있음).

---

## 2. 사전 준비

### 2.1 JDK 설치

1. **Eclipse Temurin 21** (권장) 또는 강사가 안내한 JDK를 설치합니다.
2. 터미널에서 버전을 확인합니다.

**PowerShell:**

```powershell
java -version
```

`openjdk version "21.x"` 또는 사용 중인 JDK 버전이 출력되면 됩니다.

### 2.2 JAVA_HOME (Windows)

IDE·Gradle이 같은 JDK를 쓰도록 **JAVA_HOME**을 맞춥니다.

1. **시스템 환경 변수**에 `JAVA_HOME` = JDK 설치 경로 (예: `C:\Program Files\Eclipse Adoptium\jdk-21.0.x-hotspot`).
2. `Path`에 `%JAVA_HOME%\bin`이 포함되어 있는지 확인합니다.
3. **Cursor를 완전히 종료했다가 다시 연** 뒤, 통합 터미널에서 `java -version`을 다시 확인합니다.

> Cursor **에이전트 터미널**만 PATH가 비어 있는 경우가 있습니다. 그때는 사용자 터미널·IDE Run 설정에서 JDK를 지정하거나, 해당 세션에만 `$env:JAVA_HOME='...'`을 설정합니다.

### 2.3 DB 설정 파일 (bootRun 전 필수)

1. `backend/src/main/resources/application.yml.example`을 **`application.yml`**로 복사합니다. (`application.yml`은 gitignore 대상.)
2. [DB-CONNECT.md](DB-CONNECT.md)와 `.env.example`을 참고해 아래 환경변수를 **셸 또는 IDE Run Configuration**에 설정합니다. Spring Boot는 루트 `.env`를 **자동으로 읽지 않습니다.**

| 변수 | 설명 |
|------|------|
| `SPRING_DATASOURCE_URL` | JDBC URL (`currentSchema=wms`, `sslmode=require` 등 강사 안내 반영) |
| `SPRING_DATASOURCE_USERNAME` | 학생 계정 (예: `student01`) |
| `SPRING_DATASOURCE_PASSWORD` | 개별 비밀번호 |

`bootRun` 시 URL이 없으면 `'url' must start with "jdbc"` 같은 오류로 기동에 실패합니다.

---

## 3. Wrapper로 빌드·실행 (명령)

작업 디렉터리는 항상 **`backend/`** 입니다.

### 3.1 Windows (PowerShell / cmd)

```powershell
cd c:\dev\cursor-edu\sk-cursor3-wms\backend

# 의존성·컴파일 (테스트 제외)
.\gradlew.bat build -x test

# 테스트 포함 빌드
.\gradlew.bat build

# 개발 서버 기동 (DB env 설정 후)
$env:SPRING_DATASOURCE_URL="jdbc:postgresql://..."
$env:SPRING_DATASOURCE_USERNAME="student01"
$env:SPRING_DATASOURCE_PASSWORD="..."
.\gradlew.bat bootRun
```

### 3.2 Git Bash / WSL / macOS / Linux

```bash
cd backend
./gradlew build -x test
./gradlew bootRun
```

### 3.3 자주 쓰는 Task

| 목적 | 명령 |
|------|------|
| 사용 가능한 Task 목록 | `./gradlew tasks` |
| 컴파일만 | `./gradlew compileJava` |
| 단위 테스트 | `./gradlew test` |
| boot JAR 생성 | `./gradlew bootJar` → `backend/build/libs/*.jar` |
| 클린 빌드 | `./gradlew clean build` |

기동 확인(별도 터미널):

```powershell
curl.exe -s -o NUL -w "%{http_code}" http://localhost:8080/v3/api-docs
```

`200`이면 OpenAPI·서버 준비 완료입니다. Swagger UI: `http://localhost:8080/swagger-ui.html`

---

## 4. Cursor / VS Code에서 실행

### 4.1 터미널에서 bootRun

1. **Terminal → New Terminal**
2. `cd backend`
3. 위 §2.3 환경변수 설정 후 `.\gradlew.bat bootRun`
4. 로그에 `Started WmsApplication`이 보이면 성공

### 4.2 Java Extension (선택)

**Extension Pack for Java**를 쓰면 `backend/`를 Java 프로젝트로 인식합니다.

1. Command Palette (`Ctrl+Shift+P`) → **Java: Configure Java Runtime**
2. **JDK 21**(또는 사용 중인 JDK)을 Project JDK로 지정
3. Gradle for Java가 Wrapper를 사용하도록 두면 IDE Gradle 뷰에서 `bootRun`을 실행할 수 있습니다.
4. **Run and Debug**에서 `bootRun` 또는 `WmsApplication` 실행 시 **Environment**에 `SPRING_DATASOURCE_*` 세 변수를 추가합니다.

### 4.3 프론트 정적 리소스 복사

`build.gradle`의 `copyFrontend` Task는 형제 폴더 `frontend/`가 있으면 빌드 시 `static`으로 복사합니다. 실습 기본은 **Live Server + API(8080)** 이므로, CDN SPA 개발 중에는 `bootRun`만으로도 충분한 경우가 많습니다.

---

## 5. Bash 스크립트로 기동·종료

저장소 루트의 스크립트는 Wrapper를 사용합니다.

| 스크립트 | 역할 |
|----------|------|
| `scripts/start-backend.sh` | `backend`에서 `./gradlew bootRun` 백그라운드, 로그 `logs/backend.log` |
| `scripts/stop-backend.sh` | Wrapper PID 파일 기준 종료 |
| `scripts/run-be-api-tests.sh` | (선택) stop/start 후 curl API 테스트 — 이미 기동 중이면 `ATTACH_MODE=1` |

Windows에서는 **Git Bash**에서 실행하는 것을 권장합니다. PowerShell만 쓸 경우 §3.1 `gradlew.bat bootRun`을 직접 사용합니다.

---

## 6. 프로젝트 Gradle 파일 구조

| 파일 | 역할 |
|------|------|
| `backend/settings.gradle` | 루트 프로젝트 이름 (`sk-cursor3-wms-backend`) |
| `backend/build.gradle` | 플러그인, Java 21, Spring Boot·MyBatis·PostgreSQL·Springdoc·Security 의존성 |
| `backend/gradle/wrapper/gradle-wrapper.properties` | Wrapper가 내려받을 Gradle 버전 URL |
| `backend/gradlew` / `gradlew.bat` | Wrapper 실행 스크립트 |
| `backend/gradle/wrapper/gradle-wrapper.jar` | Wrapper 부트스트랩 JAR |

Wrapper 버전을 올릴 때는 `gradle-wrapper.properties`의 `distributionUrl`만 바꾸지 말고, 팀 표준에 맞춰 **Spring Boot·JDK 호환표**를 확인합니다.

---

## 7. 문제 해결

| 증상 | 원인·조치 |
|----------|-----------|
| `java: command not found` / `'java' is not recognized` | JDK 미설치 또는 PATH·JAVA_HOME 미설정 → §2.1~2.2 |
| `Unsupported class file major version 69` (또는 65 등) | **JDK가 Wrapper Gradle보다 새롭다.** Wrapper를 9.1+로 올리거나, JDK 21로 실행 |
| Gradle 8.x + JDK 25 | Gradle 8은 JDK 25 실행에 실패할 수 있음 → Wrapper **9.1.0** 유지 또는 JDK 21 사용 |
| `'url' must start with "jdbc"` | `SPRING_DATASOURCE_URL` 미설정 → §2.3 |
| `Port 8080 was already in use` | 다른 `bootRun`/프로세스 점유 → 종료 후 재기동 |
| `bootRun`은 되는데 API 테스트만 실패 | DB 시드·DDL 미적용, 또는 Git Bash **msys curl** + 한글 JSON 이슈 → `scripts/run-be-api-tests.sh`는 `curl.exe` 사용 (Windows) |
| IDE는 되는데 에이전트 셸만 Java 없음 | 에이전트 터미널 PATH 한계 → 사용자 터미널에서 실행하거나 JAVA_HOME을 해당 세션에 export |
| 첫 `./gradlew`가 느림 | Wrapper가 Gradle 배포판을 `GRADLE_USER_HOME`에 다운로드하는 정상 동작 |

---

## 8. 완료 기준

- `backend`에서 `.\gradlew.bat build -x test`(또는 `./gradlew build -x test`)가 **성공**한다.
- DB 환경변수 설정 후 `bootRun`으로 서버가 뜨고, `/v3/api-docs`가 **200**이다.
- Wrapper만 사용해 빌드했으며, 전역 Gradle 설치 없이도 동작함을 이해했다.

---

## 9. 핵심 포인트

**Wrapper + JDK 21 타깃 + DB env** 세 가지가 맞으면 백엔드 실습의 나머지(API, Swagger, curl 테스트)가 이어집니다. 프론트(Live Server)와 포트가 다르므로 CORS 설정은 [backend-config.md](../99.references/backend-config.md)를 따릅니다.

→ 이전: [12-live-server.md](12-live-server.md) · DB: [DB-CONNECT.md](DB-CONNECT.md) · API 검증: [08-sequential-dev.md](08-sequential-dev.md) §4.5 · 설정 상세: [backend-config.md](../99.references/backend-config.md)
