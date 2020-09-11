# **IRIS ApiPub**

IRIS ApiPub é um projeto de iniciativa pessoal que tem como principal objetivo **publicar** automaticamente **API's RESTful** criadas na tecnologia IRIS, da forma mais simples e rápida possível, utilizando o padrão [Open API Specification](https://swagger.io/specification/) (OAS) versão 3.0.

Ele permite que o usuário foque principalmente na **implementação** das API’s (Web Methods), automatizando os demais aspectos relacionados a **exposição, execução, documentação e monitoramento** dos serviços.

Este projeto também inclui uma implementação completa em IRIS (**apiPub.samples,api**) do serviço [Swagger Petstore](https://app.swaggerhub.com/apis/Colon-Org/Swagger-PetStore-3.0/1.1),  utilizado como sample oficial do [swagger](https://swagger.io/). 
![](PetStore.gif)


---

## **Publique sua API no padrão OAS 3.0 com apenas 3 passos:**

**Passo 1** - Defina a classe de implementação das tuas API’s e **rotule** os métodos com o atributo [WebMethod].
![](labelingImplementationMethod.gif)
*Caso você já possua alguma implementação com WebServices esse passo não é necessário.*

---

**Passo 2** - Crie uma **subclasse** de apiPub.core.service e aponte a propriedade DispatchClass para a sua classe de Implementação criada anteriormente. Informe também o path de documentação OAS 3.0.
![](configuringServiceClass.gif)

---

**Passo 3** - Crie uma Aplicação Web e aponte a classe de Dispatch para a classe de serviço criada anteriomente.
![](creatingWebApp.gif)

---

Utilize o [iris-web-swagger-ui](https://openexchange.intersystems.com/package/iris-web-swagger-ui) para expor a especificação do teu serviço, aponte para para o path de documentação e ... **VOILÁ!!**  
![](testingFirstMethod.gif)

---

## Defina o cabeçalho da especificação OAS

---

## Customize os caminhos e verbos das tuas API's

---

## Monitore a chamada das suas API's com o IRIS Analytics 

---

## Teste os teus serviços SOAP já existentes 



