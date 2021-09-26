FROM gradle:jdk11 as builder
WORKDIR /git-repo
COPY . .
RUN gradle build -i

FROM openjdk:11-jre
ARG JAR_FILE=build/libs/*.jar
COPY --from=builder /git-repo/build/libs/*.jar /app/spider.jar
WORKDIR /app
CMD exec java $JAVA_OPTS -jar /app/spider.jar