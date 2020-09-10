# IRIS ApiPub

ApiPub é um projeto de iniciativa pessoal que tem como principal objetivo expor automaticamente e rapidamente serviços Rest/JSON criadas na tecnologia IRIS, da forma mais simples possível, utilizando o padrão Open API Specification (OAS) versão 3.0.

Ela permite que o implementador foque principalmente na implementação das API’s (WebMethods), automatizando os demais aspectos relacionados a exposição, documentação e monitoramento dos serviços.

---

## Publique sua API no padrão OAS 3.0 em apenas 3 passos:

**Passo 1** - Defina a classe de implementação das tuas API’s e rotule os métodos com o atributo [WebMethod].
![](labelingImplementationMethod.gif)
*Caso você já possua alguma implementação com WebServices esse passo não é necessário.*

---

**Passo 2** - Crie uma classe herdando de apiPub.core.service e aponte a propriedade DispatchClass para a sua classe de Implementação criada anteriormente. Aponte também o caminho para a URL de documentação OAS 3.0.
![](configuringServiceClass.gif)

---

**Passo 3** - Crie uma Aplicação Web e aponte a classe de Dispatch para a classe de serviço anteriormente criada.
![](creatingWebApp.gif)

---

Utilize o swagger para expor a especificação do teu serviço, aponte para para o path de documentação e ... **VOILÁ!!!**  
![](testingFirstMethod.gif)

---

## Teste os teus serviços SOAP já existentes 

---

## Defina o cabeçalho da especificação OAS

---

## Customize os caminhos e verbos das tuas API's

---

## Monitore a chamada das suas API's com o IRIS Analytics 

---



