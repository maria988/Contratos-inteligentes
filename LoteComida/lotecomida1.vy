# @version ^0.2.8
#Lote de comida
#Se crea un contrato para cada lote de comida y en el caso de esté mal devuelve el ether a cada comprador.

struct Comprador:
    cliente:address
    cantidad: uint256

event Aviso:
    receptor:indexed(address)
    lote: String[10]
    frase: String[150]    
    
empresa: public(address)
lote: public(String[10])
fechacaducidad:uint256
precio: public(uint256)
cantidad : public(uint256)

registro: HashMap[uint256,Comprador]
hacomprado: HashMap[address,bool]
indice: uint256
sigindice: uint256
aviso:bool
devuelto: bool
#Funcion constructora del contrato
@external 
def __init__(_lote:String[10],_duracion:uint256,_precio:uint256,_cantidad: uint256):
    self.empresa = msg.sender
    self.lote =_lote
    self.fechacaducidad = block.timestamp + _duracion
    self.precio = _precio
    self.cantidad = _cantidad

#Funcion para comprar elemtentos de un determinado lote
@payable
@external
def comprar(cantidad:uint256):
    assert msg.value == cantidad * self.precio,"Precio exacto"
    assert block.timestamp < self.fechacaducidad,"Antes de caducarse"
    assert cantidad <= self.cantidad,"Hay suficientes"
    self.cantidad -= cantidad
    self.hacomprado[msg.sender] = True
    self.registro[self.indice]=Comprador({cliente:msg.sender,cantidad:cantidad})
    self.indice += 1

#Funcion para avisa de que un lote está en mal estado
@external
def mensaje_aviso(descripcion: String[150]):
    assert self.hacomprado[msg.sender],"Ha comprado"
    assert block.timestamp < self.fechacaducidad,"Antes de caducarse"
    log Aviso(self.empresa,self.lote,descripcion)
    self.aviso = True
        
#Funcion para devolver el dinero por los lotes que estaban en mal estado
@external
def retirar_del_mercado(descripcion:String[150]):
    assert msg.sender == self.empresa,"Empresa"
    assert self.aviso,"Avisado"
    nive:uint256 = self.sigindice
    for i in range (nive,nive+20):
        if i >= self.indice:
            nive = self.indice
            self.devuelto = True
            return
        else:
            registro:Comprador = self.registro[i]
            log Aviso(registro.cliente,self.lote,descripcion)
            send(registro.cliente,registro.cantidad * self.precio)
    self.sigindice = nive +20

#Funcion para avisar de que un producto no está en perfectas condiciones pero es consumible
@external
def aviso_a_clientes(descripcion:String[150]):
    assert msg.sender == self.empresa,"Empresa"
    assert self.aviso,"Avisado"
    self.aviso = False
    nive:uint256 = self.sigindice
    for i in range (nive,nive+20):
        if i >= self.indice:
            nive = self.indice
            return
        else:
            log Aviso(self.registro[i].cliente,self.lote,descripcion)
    self.sigindice = nive +20
    
#Funcion para cobrar por el lote
@external
def fin():
    assert msg.sender == self.empresa,"Empresa"
    assert (self.aviso and self.devuelto) or block.timestamp > self.fechacaducidad,"Avisado o caducado"
    selfdestruct(self.empresa)
