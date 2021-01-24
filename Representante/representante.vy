# @version ^0.2.8
#Contrato representante
struct Cliente:
    cliente:bool
    salario: uint256
    tope: uint256
    trabajos: uint256
    empresa: address
    tipo_trabajo: uint256
    aceptar:bool
    numero: uint256

event Cobrar:
    receptor: indexed(address)
    valor: uint256  
trabajos: public(HashMap[uint256,uint256])
tope: public(uint256)
representante: public(address)
clientes: public(HashMap[address,Cliente])
lista_clientes: HashMap[uint256,address]

lista_libres: HashMap[uint256,uint256]
indice: uint256
indice_libres: uint256
aceptado: public(bool)
@external
def __init__(_porcentaje_trabajo1: uint256,_porcentaje_trabajo2: uint256,_porcentaje_trabajo3: uint256,_tope:uint256):
    assert _porcentaje_trabajo3 > 0 and _porcentaje_trabajo3 < 100
    assert _porcentaje_trabajo1 > 0 and _porcentaje_trabajo1 < 100
    assert _porcentaje_trabajo2 > 0 and _porcentaje_trabajo2 < 100
    self.representante = msg.sender
    self.trabajos[1] = _porcentaje_trabajo1
    self.trabajos[2]= _porcentaje_trabajo2
    self.trabajos[3] = _porcentaje_trabajo3
    self.tope = _tope

    
@external 
def contratar(_trabajo:uint256):
    assert self.tope > 0,"Hay hueco"
    assert _trabajo <= 3,"Tipo de trabajo correcto"
    self.tope -= 1
    indice: uint256 = self.indice
    if self.indice_libres > 0:
        indice = self.lista_libres[self.indice_libres]
        self.indice_libres-= 1
    else: 
        self.indice += 1
        
    self.clientes[msg.sender] = Cliente({cliente: True, salario: 0, tope: 0,trabajos:_trabajo,empresa: empty(address),tipo_trabajo: 0, aceptar:False, numero: indice})
    self.lista_clientes[indice] = msg.sender
    
    
@external
def trabajo_encontrado( _cliente: address, _salario: uint256,_tope:uint256, _empresa: address, _tipo_trabajo : uint256):
    assert self.clientes[_cliente].cliente,"Es cliente"
    assert self.representante == msg.sender,"Representante"
    assert self.clientes[_cliente].trabajos == _tipo_trabajo or self.clientes[_cliente].trabajos == 0,"Tipo trabajo aceptable"
    self.clientes[_cliente].salario = _salario
    self.clientes[_cliente].tope = block.timestamp + _tope
    self.clientes[_cliente].empresa = _empresa
    self.clientes[_cliente].tipo_trabajo = _tipo_trabajo
    
@external
def aceptar_trabajo():
    assert self.clientes[msg.sender].cliente,"Es cliente"
    assert block.timestamp < self.clientes[msg.sender].tope,"Dentro de tiempo"
    self.aceptado = True
    self.clientes[msg.sender].aceptar = True

@payable
@external
def pagar_trabajo(_cliente: address):
    assert self.clientes[_cliente].cliente,"Es cliente"
    assert (block.timestamp > self.clientes[_cliente].tope and self.clientes[_cliente].tope>0) or self.clientes[_cliente].aceptar,"Despues de tope o aceptado"
    assert msg.sender == self.representante,"Representante"
    assert msg.value == self.clientes[_cliente].salario,"Valor exacto"
    if self.clientes[_cliente].aceptar:
        sal_porcentaje: uint256 = (self.clientes[_cliente].salario * self.trabajos[self.clientes[_cliente].tipo_trabajo]) / 100
        send(self.representante,sal_porcentaje)
        log Cobrar(self.representante,sal_porcentaje)
        send(_cliente, self.clientes[_cliente].salario - sal_porcentaje)
        log Cobrar(_cliente,self.clientes[_cliente].salario - sal_porcentaje)
    else:
        send(self.clientes[_cliente].empresa, msg.value)
        log Cobrar(self.clientes[_cliente].empresa, msg.value)

    self.clientes[_cliente].salario = 0
    self.clientes[_cliente].tope = 0
    self.clientes[_cliente].empresa = empty(address)
    self.clientes[_cliente].tipo_trabajo = 0

@external
def dejar_representante():
    assert self.clientes[msg.sender].cliente,"Es cliente"
    self.tope += 1
    self.lista_libres[self.indice_libres] = self.clientes[msg.sender].numero
    self.lista_clientes[self.clientes[msg.sender].numero] = empty(address)
    self.indice_libres += 1
    self.clientes[msg.sender] = empty(Cliente)
    

@external
def dejar_cliente(_cliente: address):
    assert msg.sender == self.representante,"Representante"
    assert self.clientes[_cliente].cliente,"Es cliente"
    self.tope += 1
    self.lista_libres[self.indice_libres] = self.clientes[_cliente].numero
    self.lista_clientes[self.clientes[_cliente].numero] = empty(address)
    self.indice_libres += 1
    self.clientes[_cliente] = empty(Cliente)

@external
def cambiar_trabajo(_trabajo: uint256):
    assert self.clientes[msg.sender].cliente,"Es cliente"
    assert _trabajo < 4,"Trabajo valido"
    self.clientes[msg.sender].trabajos = _trabajo

@external
def cambiar_porcentaje(numero: uint256,porcentaje: uint256):
    assert msg.sender == self.representante,"Representante"
    assert numero < 4 and numero > 0,"Trabajo valido"
    assert porcentaje > 0 and porcentaje < 100,"Porcentaje"
    self.trabajos[numero] = porcentaje
    
@view
@external
def mostrar_salario()->uint256:
    assert self.clientes[msg.sender].cliente,"Es cliente"
    return self.clientes[msg.sender].salario

@view
@external
def mostrar_tiempo_tope()->uint256:
    assert self.clientes[msg.sender].cliente,"Es cliente"
    return self.clientes[msg.sender].tope
