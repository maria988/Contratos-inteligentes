# @version ^0.2.8
#Pagar una cuenta entre varias personas

#Variable para saber la direccion de la empresa y el precio del producto/cuenta
#Devuelve el el valor del producto si no se recibe
#Creamos un evento para que se queden registradas las transacciones
event Transaccion:
    emisor:indexed(address)
    receptor: indexed(address)
    valor: uint256

empresa: public(address)
precio:public(uint256)
#Booleano para saber si se ha pagado en su totalidad el producto/cuenta
pagado: public(bool)
#Un diccionario en el que se asigna lo que ha pagado cada persona
yapagado: public(HashMap[address,uint256])
#y para poder devolver lo pagado
direcciones:HashMap[uint256,address]
indice: uint256
rec_indice: uint256
#limite de tiempo
limite : public(uint256)
#Constructor del contrato, en el que se establecen la direccion de la empresa y el precio a pagar
@external
def __init__(_precio: uint256,_tlimite:uint256):
    self.empresa = msg.sender
    self.precio = _precio
    self.limite = _tlimite

#Funcion para pagar entre varios una cuenta, despues de pagarla se da el servicio
@payable
@external
def pagar(empresa: address):
    assert self.empresa == empresa,"Empresa"
    assert msg.sender != self.empresa,"Cliente"
    if self.yapagado[msg.sender] == 0:
        self.yapagado[msg.sender] = msg.value
        self.direcciones[self.indice] = msg.sender
        self.indice += 1
    else:
        self.yapagado[msg.sender] += msg.value
    if msg.value > self.precio:
        log Transaccion(msg.sender,self.empresa,self.precio)
        log Transaccion(self.empresa,msg.sender,msg.value-self.precio)
        send(msg.sender,msg.value-self.precio)
        self.precio=0
    else:
        self.precio -= msg.value
        log Transaccion(msg.sender,self.empresa,msg.value)   
    
    if self.precio == 0:
        self.pagado= True
        self.limite += block.timestamp

#Se ha recibido o se ha realizado el servicio requerido       
@external
def producto(recibido:bool):
    assert self.pagado,"Pagado"
    assert self.yapagado[msg.sender] != 0,"Ha pagado"
    assert ((recibido and block.timestamp < self.limite) or (block.timestamp > self.limite)),"Posibilidades"
    if recibido:
        selfdestruct(self.empresa)
    elif block.timestamp > self.limite:
        ind: uint256 = self.rec_indice
        for i in range(ind,ind+20):
            if i >= self.indice:
                self.rec_indice = self.indice
                return
            log Transaccion(self.empresa,self.direcciones[i],self.yapagado[self.direcciones[i]])
            send(self.direcciones[i],self.yapagado[self.direcciones[i]])
        self.rec_indice = ind + 20
    
