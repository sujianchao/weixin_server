FROM ubuntu

# 签名
MAINTAINER Jcsu "jcsu@vip.qq.com"

# 安装JDK、nginx、Git
RUN apt-get update
RUN apt-get install openjdk-7-jre -y
RUN apt-get install openjdk-7-jdk -y
RUN apt-get install nginx -y
RUN apt-get install git -y

#拷贝nginx配置文件
ADD ./etc/nginx-conf /etc/nginx/conf.d

#拷贝启动脚本
ADD ./etc/scripts /usr/local
RUN chmod a+x /usr/local/start.sh

#拷贝Tomcat与maven安装包
ADD ./soft /tmp

# 安装Tomcat 7
RUN cd /usr/local && tar xzf /tmp/apache-tomcat-7.0.64.tar.gz
RUN ln -s /usr/local/apache-tomcat-7.0.64 /usr/local/tomcat
RUN rm /tmp/apache-tomcat-7.0.64.tar.gz

# 安装maven
RUN cd /usr/local && tar xzf /tmp/apache-maven-3.1.1-bin.tar.gz
RUN ln -s /usr/local/apache-maven-3.1.1 /usr/local/maven
RUN rm /tmp/apache-maven-3.1.1-bin.tar.gz

# clone 仓库
WORKDIR  /
RUN git clone https://github.com/sujianchao/weixin_maven.git

# 定义环境变量	
ENV TOMCAT_HOME /usr/local/tomcat
ENV MAVEN_HOME /usr/local/maven
ENV APP_HOME /weixin_maven

#编译源代码与部署
RUN cd /weixin_maven && /usr/local/maven/bin/mvn package 
RUN rm -rf $TOMCAT_HOME/webapps/*
RUN cd /weixin_maven && cp target/wx_maven.war $TOMCAT_HOME/webapps/ROOT.war

#启动Tomcat与Nginx
CMD /usr/local/start.sh && tail -F /usr/local/tomcat/logs/catalina.out

EXPOSE 80 8080
