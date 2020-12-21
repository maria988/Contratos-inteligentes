#Pagar una cuenta entre varias personas

#Variable spara saber la direccion de la empresa y el precio del producto/cuenta
empresa: public(address)
precio:uint256
#Booleano para saber si se ha pagado en su totalidad el producto/cuenta
pagado: bool
#Un diccionario en el que se asigna lo que ha pagado cada persona
yapagado: public(HashMap[address,uint256])
#y para poder devolver lo pagado
direcciones:HashMap[uint256,address]
indice: uint256
rec_indice: uint256
#limite de tiempo
limite : uint256
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
    assert self.empresa == empresa
    if self.yapagado[msg.sender] == 1:
        self.yapagado[msg.sender] = msg.value
    else:
        self.yapagado[msg.sender] += msg.value
    if msg.value > self.precio:
        send(msg.sender,msg.value-self.precio)
        self.precio=0
    else:
        self.precio -= msg.value
    
    self.direcciones[self.indice] = msg.sender
    self.indice += 1
    
    if self.precio == 0:
        self.pagado= True
        self.limite += block.timestamp

#Se ha recibido o se ha realizado el servicio requerido       
@external
def producto(recibido:bool):
    assert self.pagado
    assert self.yapagado[msg.sender] != 1
    if recibido:
        selfdestruct(self.empresa)
    elif block.timestamp > self.limite:
        ind: uint256 = self.rec_indice
        for i in range(ind,ind+20):
            if i > self.indice:
                self.rec_indice = self.indice
                return
            direccion: address = self.direcciones[i]
            send(direccion,self.yapagado[direccion])
        self.rec_indice = ind + 20
    
