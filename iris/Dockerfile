ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

USER root
WORKDIR /opt/analytics
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/analytics

USER ${ISC_PACKAGE_MGRUSER}

COPY  Installer.cls .
COPY  post_start_hook .
COPY  src src
COPY iris.script iris.script
COPY AnalyticsGlobals.gz .
COPY FakeData.csv .

RUN gunzip -c AnalyticsGlobals.gz > /opt/analytics/globals.xml

RUN iris start IRIS \
	&& iris session IRIS < iris.script \
    && iris stop IRIS quietly

SHELL ["/bin/bash", "-c"]
RUN pip install pandas
RUN pip install scipy

COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /dsw/analytics.json /usr/irissys/csp/dsw/configs/
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /dsw/config.json /usr/irissys/csp/dsw/


