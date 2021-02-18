# @version ^0.2.8
#Pagar una cuenta entre varias personas
#Variación de pagarvariosdevolver1.vy, usa una constante de duración del envio.
#Variable para saber la direccion de la empresa y el precio del producto/cuenta
#Devuelve el importe si no se recibe el producto
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
direcciones:HashMap[int128,address]
indice: int128
rec_indice: int128
#limite de tiempo
duracion : constant(uint256)= 2
limite :uint256
#Constructor del contrato, en el que se establecen la direccion de la empresa y el precio a pagar
@external
def __init__(_precio: uint256):
    self.empresa = msg.sender
    self.precio = _precio

#Funcion para pagar entre varios una cuenta, despues de pagarla se da el servicio
@payable
@external
def pagar(empresa: address):
    assert self.empresa == empresa,"Empresa"
    assert msg.sender != self.empresa,"Cliente"
    if msg.value < self.precio:
        self.yapagado[msg.sender] += msg.value
        self.direcciones[self.indice]= msg.sender
        self.precio -= msg.value
        log Transaccion(msg.sender,self.empresa,msg.value)
    else:
        self.yapagado[msg.sender] += self.precio
        self.direcciones[self.indice] = msg.sender
        log Transaccion(msg.sender,self.empresa,self.precio)
        if msg.value > self.precio:
            send(msg.sender,msg.value-self.precio)
            log Transaccion(self.empresa,msg.sender,msg.value-self.precio)
        
        self.precio=0
        self.pagado= True
        self.limite = block.timestamp + duracion
    self.indice += 1

#Se ha recibido o se ha realizado el servicio requerido       
@external
def producto(recibido:bool):
    assert self.pagado,"Pagado"
    assert self.yapagado[msg.sender] > 0,"Ha pagado"
    assert ((recibido and block.timestamp < self.limite) or (block.timestamp > self.limite)),"Posibilidades"
    if recibido:
        selfdestruct(self.empresa)
    elif block.timestamp > self.limite:
        ind: int128 = self.rec_indice
        for i in range(ind,ind+20):
            if i >= self.indice:
                self.rec_indice = self.indice
                return
            direccion: address = self.direcciones[i]
            valor : uint256 = self.yapagado[direccion]
            if valor > 0:
                log Transaccion(self.empresa,direccion,valor)
                send(direccion,valor)
                self.yapagado[direccion] = 0
        self.rec_indice = ind + 20
