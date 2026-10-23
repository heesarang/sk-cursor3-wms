---
description: "MyBatis XML SQL 패턴 – 형식, 동적 SQL, namespace, resultType/parameterType 규칙"
globs: ["backend/**/mapper/**/*.xml"]
alwaysApply: false
---


<!--
[목적] MyBatis XML 작성 규칙. Mapper XML 편집 시에만 로드된다.
[작동] mapper/ 하위 .xml 파일을 작업할 때 자동 적용.
-->

# MyBatis XML 규칙

## 참조 문서
- docs/99.references/coding-standards.md — MyBatis XML 위치, namespace, SQL ID 네이밍 패턴 상세

## 기본
- namespace는 Mapper 인터페이스의 FQCN과 일치
- resultType은 map (별도 VO가 없으면)
- parameterType은 map

## 동적 SQL
- 조건 검색에 <if>, <where>, <choose> 활용
- 문자열 비교: <if test="status != null and status != ''">

## 네이밍
- select 쿼리 id: select + 의미 (예: selectInboundOrderList)
- update 쿼리 id: update + 의미
- insert 쿼리 id: insert + 의미

## 금지 사항
- Java 소스에 SQL 문자열 직접 작성 금지
- MyBatis @Select, @Insert 등 어노테이션 방식 사용 금지. XML만 사용
