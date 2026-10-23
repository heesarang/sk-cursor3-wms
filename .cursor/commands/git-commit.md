<!--
[사용법] Agent 입력창에서 /git-commit 입력 후 실행
[목적] 변경사항 확인 → Conventional Commits 메시지 생성 → 커밋
-->

# Git 커밋

1. `git diff --stat`으로 변경된 파일 목록을 확인한다
2. `git diff`로 변경 내용을 파악한다
3. Conventional Commits 형식으로 커밋 메시지를 생성한다
   - feat: 새 기능
   - fix: 버그 수정
   - refactor: 리팩토링
   - docs: 문서
   - chore: 설정/빌드
4. 한국어 본문으로 변경 요약을 작성한다
5. `git add .` + `git commit`을 실행한다
