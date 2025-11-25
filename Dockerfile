# 1단계: 빌드 스테이지 (Build Stage)
# JDK 21이 포함된 이미지 사용 (빌드 환경)
FROM eclipse-temurin:21-jdk-jammy AS build

# 컨테이너 내 작업 디렉토리 설정
WORKDIR /app

# 1. Gradle Wrapper와 설정 파일들 복사 (캐싱 최적화를 위해 먼저 복사)
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle .

# 2. 실행 권한 부여
RUN chmod +x ./gradlew

# 3. 소스 코드 복사
COPY src src

# 4. 애플리케이션 빌드
# ./gradlew bootJar 명령어로 JAR 파일 생성.
# --no-daemon: 컨테이너 빌드 시 데몬 사용 방지.
# -x test: 빌드 시간 단축을 위해 테스트는 제외.
RUN ./gradlew bootJar --no-daemon -x test

# -------------------------------------------------------------

# 2단계: 실행 스테이지 (Run Stage)
# JRE 21만 포함된 경량 이미지 사용
# 참고: 원본 Dockerfile은 2단계에서도 eclipse-temurin:21-jdk-jammy를 사용했지만,
# 이미지 크기 최적화를 위해 JRE 이미지를 사용하는 것이 일반적입니다.
FROM eclipse-temurin:21-jre-jammy

# 환경 변수로 Spring Profile 지정 (필요 시)
ENV SPRING_PROFILES_ACTIVE=prod

# 컨테이너 내의 작업 디렉토리 설정
WORKDIR /app

# 1단계(build)에서 생성된 JAR 파일을 최종 실행 이미지로 복사
COPY --from=build /app/build/libs/app.jar app.jar

# 애플리케이션 실행 명령어
ENTRYPOINT ["java", "-jar", "app.jar"]
