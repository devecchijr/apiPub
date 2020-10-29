ARG IMAGE=intersystems/iris:2019.1.0S.111.0
ARG IMAGE=store/intersystems/irishealth:2019.3.0.308.0-community
ARG IMAGE=store/intersystems/iris-community:2019.3.0.309.0
ARG IMAGE=store/intersystems/iris-community:2019.4.0.379.0
ARG IMAGE=store/intersystems/iris-community:2020.1.0.197.0
ARG IMAGE=intersystemsdc/iris-community:2020.1.0.209.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.1.0.215.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.2.0.196.0-zpm
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER irisowner

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