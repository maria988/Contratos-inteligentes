# @version ^0.2.8

#Seguro movil

event Parte:
    cliente: indexed(address)
    aseguradora: indexed(address)
    descripcion: String[200]
    tipo_contrato: uint256

event Reparar:
    cliente:indexed(address)
    valor:uint256
    causas: String[200]
    
struct Contrato:
    precio: uint256
    descripcion: String[300]
    maximo_partes: uint256

    
aseguradora: public(address)
duracion : public(uint256)
contratado: bool
cliente: address
imei: String[15]
tope: uint256
elegido: uint256

tipo: public(HashMap[uint256,Contrato])
parte:public(bool)

@external
def __init__(_duracion: uint256, _precio1: uint256, _precio2: uint256,_descripcion1: String[300],_descripcion2:String[300],_maximo_partes1: uint256,_maximo_partes2: uint256):
    self.aseguradora = msg.sender
    self.duracion = _duracion
    self.tipo[1] = Contrato({precio:_precio1,descripcion: _descripcion1, maximo_partes: _maximo_partes1})
    self.tipo[2] = Contrato({precio:_precio2,descripcion: _descripcion2, maximo_partes: _maximo_partes2})

@payable
@external
def contratar(_imei: String[15]):
    assert not self.contratado,"No contratado"
    assert msg.value == self.tipo[1].precio or msg.value == self.tipo[2].precio,"Precio exacto"
    self.contratado = True
    self.cliente = msg.sender
    self.imei = _imei
    self.tope = block.timestamp + self.duracion
    if msg.value == self.tipo[1].precio:
        self.elegido = 1
    else:
        self.elegido = 2
        
    
@external
def dar_parte(_descripcion: String[200],_imei:String[15]):
    assert self.contratado,"Contratado"
    assert msg.sender == self.cliente,"Cliente"
    assert block.timestamp < self.tope,"Dentro de tope"
    assert self.tipo[self.elegido].maximo_partes > 0,"Hay partes"
    assert self.imei == _imei,"Imei correcto"
    self.parte = True
    log Parte(self.cliente,self.aseguradora,_descripcion,self.elegido)


@payable
@external
def remunerar(aceptado : bool,causas:String[200]):
    assert msg.sender == self.aseguradora,"Aseguradora"
    assert self.parte,"Se ha expedido un parte"
    self.parte = False
    if aceptado:
        send(self.cliente,msg.value)
        log Reparar(self.cliente,msg.value,"Aceptado")
        self.tipo[self.elegido].maximo_partes -= 1
    else:
        log Reparar(self.cliente,0,causas)
    

@external
def fin():
    assert msg.sender == self.aseguradora,"Aseguradora"
    assert block.timestamp > self.tope,"Despues del tope"
    assert not self.parte
    selfdestruct(self.aseguradora)
        
@view
@external
def consultar_descripcion(_tipo: uint256)->String[300]:
    return self.tipo[_tipo].descripcion

@view
@external
def consultar_precio(_tipo: uint256)-> uint256:
    return self.tipo[_tipo].precio
