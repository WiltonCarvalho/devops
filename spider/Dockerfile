FROM gradle:jdk11 as builder
WORKDIR /git-repo
COPY . .
RUN chown gradle: /git-repo -R
USER gradle
RUN gradle jibBuildTar -Djib.from.image=openjdk:11-jre -Djib.console=plain

FROM openjdk:11-jre
ARG JAR_FILE=build/libs/*.jar
COPY --from=builder /git-repo/build/libs/*.jar /app/spider.jar
WORKDIR /app
CMD exec java $JAVA_OPTS -jar /app/spider.jar