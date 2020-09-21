# IRIS ApiPub

IRIS ApiPub é um projeto [Open Source](https://en.wikipedia.org/wiki/Open_source), de iniciativa pessoal, que tem como principal objetivo **publicar** automaticamente **API's RESTful** criadas com a tecnologia [Intersystems IRIS](https://www.intersystems.com/try-intersystems-iris-for-free/), da forma mais simples e rápida possível, utilizando o padrão [Open API Specification](https://swagger.io/specification/) (OAS) versão 3.0.  

Ele permite que o usuário foque principalmente na **implementação** das API’s (Web Methods), automatizando os demais aspectos relacionados a **exposição, execução, documentação e monitoramento** dos serviços.

Este projeto também inclui uma implementação de exemplo completa (**apiPub.samples.api**) do *sample* [Swagger Petstore](https://app.swaggerhub.com/apis/Colon-Org/Swagger-PetStore-3.0/1.1), utilizado como *sample* oficial do [swagger](https://swagger.io/). 

![](PetStore.gif)

## Faça um teste com os teus serviços SOAP já existentes 
Se você já possui serviços SOAP publicados, você pode testar a sua publicação com Rest/JSON com OAS 3.0.
![](soapToOASRest.png)

Ao publicar métodos com tipos complexos é necessário que a classe do objeto seja uma subclasse de %XML.Adaptor. Desta maneira serviços SOAP já existentes são automaticamente compatíveis.

![](XMLAdaptorCompat.png)

## **Instalação**

Importe o pacote apiPub_vx.xml no namespace desejado via terminal.

```
zn "USER"
Do $System.OBJ.Load("/path/apiPub_vx.xml","ck")
```
Ou através do portal de Administração
![](importingPackage.png)

## **Publique sua API no padrão OAS 3.0 com apenas 3 passos:**

## Passo 1  
Defina a classe de implementação das tuas API’s e **rotule** os métodos com o atributo [WebMethod]
![](labelingImplementationMethod.gif)
*Caso você já possua alguma implementação com WebServices esse passo não é necessário.*

## Passo 2
Crie uma **subclasse** de apiPub.core.service e aponte a propriedade DispatchClass para a sua classe de Implementação criada anteriormente. Informe também o path de documentação OAS 3.0. Se desejar, aponte para a classe apiPub.samples.api (PetStore).
![](configuringServiceClass.gif)

## Passo 3
Crie uma Aplicação Web e aponte a classe de Dispatch para a classe de serviço criada anteriomente.
![](creatingWebApp.gif)

## Utilize o Swagger
Com o [iris-web-swagger-ui](https://openexchange.intersystems.com/package/iris-web-swagger-ui) é possível expor a especificação do teu serviço. Basta apontar para o path de documentação e ... **VOILÁ!!**  
![](testingFirstMethod.gif)

## Defina o cabeçalho da especificação OAS
![](OASheader.png)

Há duas maneiras de definir o cabeçalho OAS 3.0: 

A primeira é através da criação de um bloco JSON XDATA nomeado como *apiPub* na classe de implementação. Este método permite que se tenha mais de uma Tag e a modelagem é compatível com o padrão OAS 3.0. 
```
XData apiPub [ MimeType = application/json ]
{
    {
        "info" : {
            "description" : "This is a sample Petstore server.  You can find\nout more about Swagger at\n[http://swagger.io](http://swagger.io) or on\n[irc.freenode.net, #swagger](http://swagger.io/irc/).\n",
            "version" : "1.0.0",
            "title" : "IRIS Petstore (Dev First)",
            "termsOfService" : "http://swagger.io/terms/",
            "contact" : {
            "email" : "apiteam@swagger.io"
            },
            "license" : {
            "name" : "Apache 2.0",
            "url" : "http://www.apache.org/licenses/LICENSE-2.0.html"
            }
        },
        "tags" : [ {
            "name" : "pet",
            "description" : "Everything about your Pets",
            "externalDocs" : {
            "description" : "Find out more",
            "url" : "http://swagger.io"
            }
        }, {
            "name" : "store",
            "description" : "Access to Petstore orders"
        }, {
            "name" : "user",
            "description" : "Operations about user",
            "externalDocs" : {
            "description" : "Find out more about our store",
            "url" : "http://swagger.io"
            }
        } ]
    }
}
```
A segunda maneira é através da definição de parâmetros na classe de implementação, assim como no exemplo a seguir:

```
Parameter SERVICENAME = "My Service";

Parameter SERVICEURL = "http://localhost:52776/apipub";

Parameter TITLE As %String = "REST to SOAP APIs";

Parameter DESCRIPTION As %String = "APIs to Proxy SOAP Web Services via REST";

Parameter TERMSOFSERVICE As %String = "http://www.intersystems.com/terms-of-service/";

Parameter CONTACTNAME As %String = "John Doe";

Parameter CONTACTURL As %String = "https://www.intersystems.com/who-we-are/contact-us/";

Parameter CONTACTEMAIL As %String = "support@intersystems.com";

Parameter LICENSENAME As %String = "Copyright InterSystems Corporation, all rights reserved.";

Parameter LICENSEURL As %String = "http://docs.intersystems.com/latest/csp/docbook/copyright.pdf";

Parameter VERSION As %String = "1.0.0";

Parameter TAGNAME As %String = "Services";

Parameter TAGDESCRIPTION As %String = "Legacy Services";

Parameter TAGDOCSDESCRIPTION As %String = "Find out more";

Parameter TAGDOCSURL As %String = "http://intersystems.com";
```
## Customize as tuas API's
![](customizeYourAPI.png)

É possível customizar vários aspectos das API's, como ***tags, paths e verbos***. Para tal, é necessária a utilização de uma notação específica, definida no comentário do método a ser customizado. 

Sintaxe:
>/// @apiPub[*assignment clause*]  
[*Method/ClassMethod*] *methodName(params as type) As returnType* {  
>    
>}

Todas as customizações dadas como exemplo nesta documentação estão disponíveis na classe [apiPub.samples.api](/samples/api.cls).

## Customizando os Verbos
Quando não há nenhum tipo complexo como parâmetro de entrada, apiPub atribui automaticamente o verbo como *Get*. Caso contrário é atribuído o verbo *Post*. 

Caso se queira customizar o método adiciona-se a seguinte linha nos comentários do método.

>/// @apiPub[verb="*verb*"]

Onde *verb* pode ser **get, post, put, delete ou patch**. 

Exemplo:

>/// @apiPub[verb="put"]

## Customizando os Caminhos (Paths)
Esta ferramenta atribui automaticamente os *paths* ou o roteamento para os *Web Methods*. Ele utiliza como padrão o nome do método como *path*.

Caso se queira customizar o **path** adiciona-se a seguinte linha nos comentários do método.

>/// @apiPub[path="*path*"]

Onde *path* pode ser qualquer valor precedido com barra, desde que não conflita com outro *path* na mesma classe de implementação. 

Exemplo:
>/// @apiPub[path="/pet"]

Outro uso bastante comum do path é definir um ou mais parâmetros no próprio path. Para tal, é necessário que o nome do parâmetro definido no método esteja entre chaves. 

Exemplo:
>/// @apiPub[path="/pet/{petId}"]  
Method getPetById(petId As %Integer) As apiPub.samples.Pet [ WebMethod ]   
{  
}

Quando o nome do parâmetro interno difere do nome do parâmetro exposto, pode-se equalizar o nome conforme exemplo a seguir:
>/// @apiPub[path="/pet/{petId}"]  
/// @apiPub[params.pId.name="petId"]  
Method getPetById(pId As %Integer) As apiPub.samples.Pet [ WebMethod ]   
{  
}

No exemplo acima, o parâmetro interno *pId* é exposto como *petId*.

## Customizando as Tags

Definir a **tag**(agrupamento) do método quando há mais que uma tag definida no cabeçalho.
>/// @apiPub[tag="*value*"]

Exemplo:
>/// @apiPub[tag="user"]

## Como marcar a API como Descontinuada

Para que a API seja exposta como ***deprecated***, utiliza-se a seguinte notação:

>/// @apiPub[deprecated="true"]

## Customizando o *operationId*

Segundo a especificação OAS, ***operationId*** é uma string única usada para identificar uma API ou operação. Nesta ferramenta ela é utilizada para a mesma finalidade no monitoramento e rastreamento das operações.

Por padrão, ela recebe o mesmo nome do método da classe de implementação.

Caso se queira alterá-la utiliza-se a seguinte notação 

>/// @apiPub[operationId="updatePetWithForm"]

## Alterando o charset do método

O charset padrão da geralmente é definido através do parâmetro CHARSET na classe de serviço, descrita no [Passo 2](https://github.com/devecchijr/apiPub#passo-2). Caso se queira customizar o charset de um método, deve se utilizar a seguinte notação:

>/// @apiPub[charset="*value*"]

Exemplo:

>/// @apiPub[charset="UTF-8"]

## Customizando nomes e outras funcionalidades dos parâmetros
Pode-se customizar vários aspectos de cada parâmetro de entrada e saída dos métodos, como por exemplo os nomes e as descrições que serão expostas para cada parâmetro.

Para se customizar um parametro específico utiliza-se a seguinte notação

>/// @apiPub[params.*paramId.property*="*value*"]

ou para respostas:

>/// @apiPub[response.*property*="*value*"]

Exemplo:
>/// @apiPub[params.pId.name="petId"]  
/// @apiPub[params.pId.description="ID of pet to return"]

Neste caso, está sendo atribuido o nome *petId* e a descrição *ID of pet to return* para o parâmetro definido como *pId*

Quando a customização não é específica para um determinado parâmetro, utiliza-se a seguinte notação
>/// @apiPub[params.*property*="*value*"]

No exemplo abaixo, a descrição *This can only be done by the logged in user* é atribuída para todo o *request*, não apenas para um parâmetro:  
>/// @apiPub[params.description="This can only be done by the logged in user."]

## Outras Propriedades que podem ser customizadas para parâmetros específicos

Para parâmetros de entrada ou saída:
>/// @apiPub[params.*paramId.property*="*value*"]

ou para respostas:
>/// @apiPub[response.*property*="*value*"]

|   Property           |   Description                                                                                                                                                                                                                                                                                                                                        |
|----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|   required           |   se o parâmetro é requerido. Todos os parâmetros do tipo **path** já são automaticamente requeridos                                                                                                                                                                                                                                                 |
|   schema.items.enum  |   exposição de Enumeradores para tipos %String ou %Library.DynamicArray. Veja o método ***findByStatus*** da classe [apiPub.samples.api](/samples/api.cls)                                                                                                                                                                                           |
|   schema.default     |   aponta para um valor default para enumeradores.                                                                                                                                                                                                                                                                                                    |
|   inputType          |   por padrão é **query parameter** para os tipos simples e **application/json** para os tipos complexo (body). Caso se queira alterar o tipo de input, pode se utilizar este parâmetro. Exemplo de uso: Upload de uma imagem, que normalmente não é do tipo JSON. Veja método ***uploadImage*** da classe [apiPub.samples.api](/samples/api.cls).    |
|   outputType         |   por padrão é **header** para os tipos %Status e **application/json** para o restante. Caso se queira alterar o tipo de output, pode se utilizar este parâmetro. Exemplo de uso: Retorno de um token ("text/plain"). Veja método ***loginUser*** da classe [apiPub.samples.api](/samples/api.cls)                                                   |

## Associe Schemas Parseáveis a tipos JSON Dinâmicos ***(%Library.DynamicObject)***

É possível associar [schemas OAS 3.0](https://swagger.io/docs/specification/data-models/) a [tipos dinâmicos](https://docs.intersystems.com/hs20201/csp/docbook/DocBook.UI.Page.cls?KEY=GJSON_create) internos. 

A grande vantagem neste caso, além da documentação da API para tipos dinâmicos, é o ***parsing automático*** do request. Se o usuário da API por exemplo enviar uma propriedade que não está no schema ou não enviar uma propriedade obrigatória, um ou mais erros são retornados.

O primeiro passo é incluir o schema desejado no bloco XDATA conforme exemplo abaixo. Neste caso o schema chamado *User* pode ser utilizado por qualquer método. Ele deve seguir as mesmas regras da modelagem [OAS 3.0](https://swagger.io/docs/specification/data-models/). 
```
XData apiPub [ MimeType = application/json ]
{
    {
        "schemas": {
            "User": {
                "type": "object",
                "required": [
                    "id"
                ],
                "properties": {
                    "id": {
                        "type": "integer",
                        "format": "int64"
                    },
                    "username": {
                        "type": "string"
                    },
                    "firstName": {
                        "type": "string"
                    },
                    "lastName": {
                        "type": "string"
                    },
                    "email": {
                        "type": "string"
                    },
                    "password": {
                        "type": "string"
                    },
                    "phone": {
                        "type": "string"
                    },
                    "userStatus": {
                        "type": "integer",
                        "description": "(short) User Status"
                    }
                }
            }            
        }
    }
}
```

O segundo passo é asssociar o nome do schema informado no passo anterior ao parâmetro interno do tipo [%Library.DynamicObject](https://docs.intersystems.com/hs20201/csp/docbook/DocBook.UI.Page.cls?KEY=GJSON_create) usando a seguinte notação:

>/// @apiPub[params.*paramId*.*schema*="*schema name*"]

Exemplo associando o parâmetro *user* ao schema *User*:
```
/// @apiPub[params.user.schema="User"]
Method updateUserUsingOASSchema(username As %String, user As %Library.DynamicObject) As %Status [ WebMethod ]
{
    code...
}
```

Exemplo de request com erro a ser submetido. A propriedade username2 não existe no schema *User*. A propriedade id também não foi especificada e é requerida:
```
{
  "username2": "devecchijr",
  "firstName": "claudio",
  "lastName": "devecchi junior",
  "email": "devecchijr@gmail.com",
  "password": "string",
  "phone": "string",
  "userStatus": 0
}
```

Exemplo de erro retornado:
```
{
  "statusCode": 0,
  "message": "ERRO #5001: <Bad Request> Path User.id is required; Invalid path: User.username2",
  "errorCode": 5001
}
```

Veja métodos ***updateUserUsingOASSchema*** e ***getInventory*** da classe [apiPub.samples.api](/samples/api.cls). O método ***getInventory*** é um exemplo de schema associado à saída do método (response), portanto não é parseável.

## Monitore a chamada das suas API's com o IRIS Analytics 
*pending*

## Utilize esta ferramenta em conjunto com o IRIS API Manager
*pending*

## Tipos Primitivos Suportados

|   Primitive Type           |   OAS JSON Type           |   OAS Format Type  |
|----------------------------|---------------------------|--------------------|
|   %Binary                  |   string                  |                    |
|   %xsd.base64Binary        |   string                  |                    |
|   %Boolean                 |   boolean                 |                    |
|   %Date                    |   string                  |   date             |
|   %PosixTime               |   string                  |   date-time        |
|   %StringTimeStamp         |   string                  |   date-time        |
|   %TimeStamp               |   string                  |   date-time        |
|   %DateTime                |   string                  |   date-time        |
|   %Currency                |   number                  |                    |
|   %Float                   |   number                  |                    |
|   %Decimal                 |   number                  |                    |
|   %Numeric                 |   number                  |                    |
|   %Double                  |   number                  |                    |
|   %Float                   |   number                  |                    |
|   %BigInt                  |   integer                 |   int64            |
|   %xsd.int                 |   integer                 |                    |
|   %xsd.long                |   integer                 |   int64            |
|   %Integer                 |   integer                 |                    |
|   %SmallInt                |   integer                 |   int32            |
|   %Time                    |   string                  |                    |
|   %TinyInt                 |   integer                 |                    |
|   %xsd.byte                |   integer                 |   int32            |
|   %String                  |   string                  |                    |
|   %Stream.FileBinary       |   string                  |   binary           |
|   %Stream.Filecharacter    |   string                  |                    |
|   %Stream.GlobalBinary     |   string                  |   binary           |
|   %Stream.GlobalCharacter  |   string                  |                    |
|   %Status                  |   special type as output  |                    |

## Tipos Complexos (Propriedades)

|   Property Type             |   OAS JSON Type                   |   OAS Format Type  |
|-----------------------------|-----------------------------------|--------------------|
|   %BigInt                   |   integer                         |   int64            |
|   %Binary                   |   string                          |                    |
|   %Boolean                  |   boolean                         |                    |
|   %Char                     |   string                          |                    |
|   %Counter                  |   integer                         |   int64            |
|   %Currency                 |   number                          |                    |
|   %Date                     |   string                          |   date             |
|   %DateTime                 |   string                          |   date-time        |
|   %Decimal                  |   number                          |                    |
|   %Double                   |   number                          |                    |
|   %EnumString               |   string                          |                    |
|   %ExactString              |   string                          |                    |
|   %Integer                  |   integer                         |   int64            |
|   %List                     |   array                           |                    |
|   %ListOfBinary             |   array                           |                    |
|   %Name                     |   string                          |                    |
|   %Numeric                  |   number                          |                    |
|   %SmallInt                 |   integer                         |                    |
|   %Status                   |   string                          |   binary           |
|   %String                   |   string                          |                    |
|   %Time                     |   string                          |                    |
|   %TimeStamp                |   string                          |   date-time        |
|   %TinyInt                  |   integer                         |                    |
|   %Stream.GlobalCharacter   |   string                          |                    |
|   %Stream.GlobalBinary      |   string                          |   binary           |
|   %Stream.GlobalCharacter   |   string                          |                    |
|   %Stream.GlobalBinary      |   string                          |   binary           |
|   Complex Type              |   object                          |                    |
|   list Of (Primitive Type)  |   array of (Primitive JSON Type)  |                    |
|   list Of (Complex Type)    |   array of (Complex Type)         |                    |
|   array Of (Primitive)	      |   array of (Primitive JSON Type)  |                    |
|   array Of (Complex Type)   |   array of (Complex Type)         |                    |
|   RelationShip              |   object or array                 |                    |