# 1단계: 빌드 환경 정의 (Java 컴파일 및 패키징용)
FROM openjdk:21-jdk-slim AS build
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# 2단계: 실행 환경 정의 (더 작은 JRE 이미지만 사용)
FROM openjdk:21-jre-slim
# 환경 변수로 Spring Profile 지정 (필요 시)
ENV SPRING_PROFILES_ACTIVE=prod 
# 컨테이너 내의 작업 디렉토리 설정
WORKDIR /app
# 1단계에서 빌드된 JAR 파일을 복사
COPY --from=build app.jar .
# 애플리케이션 실행 명령어
ENTRYPOINT ["java", "-jar", "app.jar"]
