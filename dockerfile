FROM atlassian/jira-software:8.8.0

LABEL maintainer="your-email@example.com"
LABEL description="Jira with atlassian-agent.jar using catalina.sh for startup"

# Копируем atlassian-agent.jar в контейнер с правильным владельцем
COPY --chown=jira:jira atlassian-agent.jar /opt/atlassian/jira/

# Проверяем наличие файла и устанавливаем права доступа
RUN if [ ! -f /opt/atlassian/jira/atlassian-agent.jar ]; then \
    echo "ERROR: atlassian-agent.jar not found in build context!"; \
    exit 1; \
  fi && \
  chmod 644 /opt/atlassian/jira/atlassian-agent.jar

# Настраиваем запуск с java‑агентом через CATALINA_OPTS
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/jira/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/jira/bin/setenv.sh

# Переменные окружения для настройки памяти JVM
ENV JVM_MINIMUM_MEMORY=2g
ENV JVM_MAXIMUM_MEMORY=8g

# Открываем порт для веб‑интерфейса
EXPOSE 8080

# Запуск Jira через catalina.sh run (вместо entrypoint.sh)
CMD ["/opt/atlassian/jira/bin/catalina.sh", "run"]
