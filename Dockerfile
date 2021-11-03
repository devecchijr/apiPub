ARG IMAGE=intersystemsdc/iris-community:2021.1.0.215.3-zpm
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
USER ${ISC_PACKAGE_MGRUSER}

COPY  Installer.cls .
COPY  src src
COPY irissession.sh /
SHELL ["/irissession.sh"]

RUN \
  do $SYSTEM.OBJ.Load("Installer.cls", "ck") \
  set sc = ##class(App.Installer).setup() \
  zn "%SYS" \
  write "Create web application ..." \
  set webName = "/crud" \
  set webProperties("DispatchClass") = "apiPub.samples.petStore" \
  set webProperties("NameSpace") = "IRISAPP" \
  set webProperties("Description") = "PetStore Crud Services" \
  set webProperties("Enabled") = 1 \
  set webProperties("AutheEnabled") = 32 \
  set sc = ##class(Security.Applications).Create(webName, .webProperties) \
  set webName="/csp/irisapp" \
  k webProperties \
  set webProperties("DeepSeeEnabled")=1 \
  set sc = ##class(Security.Applications).Modify(webName, .webProperties) \
  write "Web application "_webName_" has been created!" \
  zn "IRISAPP" \
  set sc = ##class(%DeepSee.UserLibrary.Utils).%ProcessContainer("apiPub.tracer.dashboards",1) \
  w "successfully imported ",sc,! \
  set sc = ##class(apiPub.tracer.production).Register() \
  w "apiPub.tracer.production registered ",sc,! \
  set ^Ens.AutoStart = "apiPub.tracer.production" \
  set ^Ens.AutoStart("StartupPriority")	=	0 \
  w "apiPub.tracer.production auto-start defined ",sc,! \
  #zpm "install webterminal" \
  zpm "install swagger-ui" 
# bringing the standard shell back
SHELL ["/bin/bash", "-c"]
CMD [ "-l", "/usr/irissys/mgr/messages.log" ]