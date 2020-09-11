# IRIS ApiPub

IRIS ApiPub é um projeto de iniciativa pessoal que tem como principal objetivo **publicar** automaticamente **API's RESTful** criadas na tecnologia IRIS, da forma mais simples e rápida possível, utilizando o padrão [Open API Specification](https://swagger.io/specification/) (OAS) versão 3.0.

Ele permite que o usuário foque principalmente na **implementação** das API’s (Web Methods), automatizando os demais aspectos relacionados a **exposição, execução, documentação e monitoramento** dos serviços.

Este projeto também inclui uma implementação de exemplo completa (**apiPub.samples.api**) do *sample* [Swagger Petstore](https://app.swaggerhub.com/apis/Colon-Org/Swagger-PetStore-3.0/1.1), utilizado como *sample* oficial do [swagger](https://swagger.io/). 

![](PetStore.gif)

## **Instalação**

Importe o pacote apiPub_vX.X.xml no namespace desejado via terminal.

```
zn "USER"
Do $System.OBJ.Load("/path/apiPub_vX.X.xml","ck")
```
Ou através do portal de Administração
![](importingPackage.png)

## **Publique sua API no padrão OAS 3.0 com apenas 3 passos:**

## Passo 1  
Defina a classe de implementação das tuas API’s e **rotule** os métodos com o atributo [WebMethod]
![](labelingImplementationMethod.gif)
*Caso você já possua alguma implementação com WebServices esse passo não é necessário.*

## Passo 2
Crie uma **subclasse** de apiPub.core.service e aponte a propriedade DispatchClass para a sua classe de Implementação criada anteriormente. Informe também o path de documentação OAS 3.0.
![](configuringServiceClass.gif)

## Passo 3
Crie uma Aplicação Web e aponte a classe de Dispatch para a classe de serviço criada anteriomente.
![](creatingWebApp.gif)

## Utilize o Swagger
Com o [iris-web-swagger-ui](https://openexchange.intersystems.com/package/iris-web-swagger-ui) é possível expor a especificação do teu serviço. Basta apontar para o path de documentação e ... **VOILÁ!!**  
![](testingFirstMethod.gif)

## Defina o cabeçalho da especificação OAS
*pending*

## Customize os caminhos e verbos das tuas API's
*pending*

## Monitore a chamada das suas API's com o IRIS Analytics 
*pending*

## Teste com os teus serviços SOAP já existentes 
Ao publicar métodos com tipos complexos é necessário que a classe do mesmo seja uma subclasse de %XML.Adaptor. Desta maneira serviços SOAP já existentes são automaticamente compatíveis.

![](XMLAdaptorCompat.png)


