FROM jenkins/jenkins:lts
USER root

ARG MAVEN_VERSION=3.6.1
ARG USER_HOME_DIR="/root"

ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt update -y \
  && apt install nodejs -y

RUN rm -rf /usr/local/openjdk-8/

RUN mkdir ${USER_HOME_DIR}/Downloads
WORKDIR ${USER_HOME_DIR}/Downloads
RUN wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz \
  && mkdir /usr/lib/jvm \
  && cd /usr/lib/jvm \
  && tar -xvzf ${USER_HOME_DIR}/Downloads/jdk-8u131-linux-x64.tar.gz \
  && echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/jvm/jdk1.8.0_131/bin:/usr/lib/jvm/jdk1.8.0_131/db/bin:/usr/lib/jvm/jdk1.8.0_131/jre/bin"' >> /etc/environment \
  && echo 'J2SDKDIR="/usr/lib/jvm/jdk1.8.0_131"' >> /etc/environment \
  && echo 'J2REDIR="/usr/lib/jvm/jdk1.8.0_131/jre"' >> /etc/environment \
  && echo 'JAVA_HOME="/usr/lib/jvm/jdk1.8.0_131"' >> /etc/environment \
  && echo 'DERBY_HOME="/usr/lib/jvm/jdk1.8.0_131/db"' >> /etc/environment

ENV JAVA_HOME=/usr/lib/jvm/jdk1.8.0_131

RUN update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_131/bin/java" 0 \
  && update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_131/bin/javac" 0 \
  && update-alternatives --set java /usr/lib/jvm/jdk1.8.0_131/bin/java \
  && update-alternatives --set javac /usr/lib/jvm/jdk1.8.0_131/bin/javac

RUN update-alternatives --list java && update-alternatives --list javac
RUN java -version
