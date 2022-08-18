ARG IMAGE=rlourenc/irishealth-community:latest
FROM $IMAGE AS IRISHealthBuilder

ENV IRIS_PASSWORD="SYS"

# Install custom code
COPY code/src /tmp/src
COPY scripts /tmp/scripts

USER root
RUN chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /tmp/scripts \
    && chmod +x /tmp/scripts/build.sh

# Switch user back to IRIS owner and load initialization code and run
USER ${ISC_PACKAGE_MGRUSER}
SHELL ["/tmp/scripts/build.sh"]

# Install custom code
RUN \
  zn "%SYS" \
  set sc = $SYSTEM.OBJ.Load("/tmp/src/XF/Installer.cls","ck") \
  if sc do ##class(XF.Installer).Install("/tmp/src/")
SHELL ["/bin/bash", "-c"]

RUN echo "$IRIS_PASSWORD" >> /tmp/pwd.isc && /usr/irissys/dev/Container/changePassword.sh /tmp/pwd.isc

# 2nd stage to reduce size
FROM $IMAGE AS IRISHealthTransformer
USER root
# replace in standard kit with what we modified in first stage
COPY --from=IRISHealthBuilder /usr/irissys/iris.cpf /usr/irissys/.
COPY --from=IRISHealthBuilder /usr/irissys/mgr/IRIS.DAT /usr/irissys/mgr/.
COPY --from=IRISHealthBuilder /usr/irissys/mgr/hssys/IRIS.DAT /usr/irissys/mgr/hssys/.
COPY --from=IRISHealthBuilder /usr/irissys/mgr/xf/. /usr/irissys/mgr/xf/.

# need to reset ownership for files copied
RUN \
  chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/iris.cpf \
  && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/mgr/IRIS.DAT \
  && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/mgr/xf \
  && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/mgr/hssys/IRIS.DAT \
  && chmod -R 775 /usr/irissys/mgr/xf/IRIS.DAT 

USER ${ISC_PACKAGE_MGRUSER}