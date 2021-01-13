# @version ^0.2.8
#Subscripcion a una revista

#Creamos una structura para almacenar todos los datos relativos al subcriptor

struct Subcriptor:
    cliente: address
    pagado: bool
    enviado:bool
    acumulado: uint256
    recibido:bool
    envpag:bool

#Estructura para saber si está registrado y si lo está en que indice
struct BoolNum:
    reg: bool
    num: uint256

#Creamos un evento para que quede registrado que se ha realizado el pago   
event Pagado:
    emisor:indexed(address)
    valor: uint256

#Creamos un evento para que quede registrado que ha llegado o no el producto
event Recibido:
    receptor: indexed(address)
    emisor: indexed(address)
    texto: String[12]    

#Direccion de la empresa,duracion de cada periodo,la cuota del periodo y el fin del periodo actual
empresa: public(address)
periodo: public(uint256)
cuota: public(uint256)
siguiente: uint256

#Diccionario al que a cada uint256 le asigna la estructura Subcriptor
clientes: HashMap[uint256,Subcriptor]

#Diccionario para saber si esta registrado y en tal caso el numero que tiene asignado
registrado:HashMap[address,BoolNum]

#Booleano para saber si se han comprobado todos los elementos
todos:public(bool)
fallo:public(bool)

#Indices para saber el total y la cantidad libres
indice: uint256
indilibres:uint256
indi: uint256

#Diccionario para almacenar los indices libres
libres :HashMap[uint256,uint256]

#Constructor del contrato
@external
def __init__(_cuota: uint256,_periodo: uint256):
    self.empresa = msg.sender
    self.cuota = _cuota
    self.periodo = _periodo
    self.siguiente = block.timestamp + _periodo

#Funcion para darse de alta en la suscripcion 
@payable
@external
def darse_de_alta():
   assert not self.registrado[msg.sender].reg,"No registrado"
   assert msg.value >= self.cuota,"Valor suficiente"
   index: uint256 = self.indi
   self.registrado[msg.sender].reg = True
   if self.indilibres > 0:
       self.registrado[msg.sender].num = self.libres[self.indi]
       self.indilibres -= 1
   else:
       self.registrado[msg.sender].num = self.indice
       index = self.indice
       self.indice += 1
   log Pagado(msg.sender,self.cuota)
   self.clientes[index] = Subcriptor({cliente:msg.sender,pagado:True,enviado:False,acumulado:msg.value - self.cuota,recibido:False,envpag:False})

#Funcion para darse de baja en la suscripcion
@external
def darse_de_baja():
    assert self.registrado[msg.sender].reg,"Registrado"
    cliente: Subcriptor = self.clientes[self.registrado[msg.sender].num]
    send(msg.sender,cliente.acumulado)
    self.libres[self.indilibres]= self.registrado[msg.sender].num
    self.clientes[self.registrado[msg.sender].num] = empty(Subcriptor)
    self.registrado[msg.sender]= empty(BoolNum)
    self.indilibres += 1
    
    
#Funcion para pagar        
@payable
@external
def pagar():
    assert self.registrado[msg.sender].reg,"Registrado"
    cliente: Subcriptor = self.clientes[self.registrado[msg.sender].num]
    assert msg.value + cliente.acumulado >= self.cuota,"Valor suficiente"
    assert not cliente.pagado,"No ha pagado"
    if msg.value == 0:
        self.clientes[self.registrado[msg.sender].num].acumulado -= self.cuota
    else:
        self.clientes[self.registrado[msg.sender].num].acumulado += msg.value - self.cuota
    log Pagado(msg.sender,self.cuota)
    cliente.pagado = True
    self.clientes[self.registrado[msg.sender].num] = cliente

#Funcion a la que accede la empresa cuando envia el elemento
@external
def enviar(cliente:address):
    assert self.empresa == msg.sender,"Empresa"
    subcriptor: Subcriptor = self.clientes[self.registrado[cliente].num]
    assert self.registrado[cliente].reg,"Registrado"
    assert  subcriptor.pagado,"Pagado"
    assert not  subcriptor.enviado,"No enviado"
    subcriptor.enviado = True
    self.clientes[self.registrado[cliente].num].enviado = True

#Funcion que es llamada por el suscriptor para que quede registrado que no se ha recibido el elemento      
@external
def no_recibido():
    assert self.registrado[msg.sender].reg,"Registrado"
    assert self.clientes[self.registrado[msg.sender].num].enviado,"Enviado"
    assert block.timestamp > self.siguiente,"Tiempo superado"
    log Recibido(self.empresa,msg.sender,"No recibido")

#Funcion que es llamada por el suscriptor para que quede registrado que se ha recibido el elemento
@external
def recibido():
    assert self.registrado[msg.sender].reg,"Registrado"
    cliente: Subcriptor = self.clientes[self.registrado[msg.sender].num]
    assert cliente.enviado,"Enviado"
    cliente.recibido = True
    log Recibido(self.empresa,msg.sender,"Recibido")
    self.clientes[self.registrado[msg.sender].num] = cliente
    if self.fallo:
        self.fallo = False
  
#Funcion que es llamada por la empresa para recaudar el ether de los suscriptores y cambiar de periodo      
@external
def comprobar():
    assert block.timestamp > self.siguiente,"Supera el periodo"
    assert not self.fallo,"No falla"
    assert msg.sender == self.empresa,"Empresa"
    ind: uint256 = self.indi
    for i in range(ind,ind+20):
        cliente: Subcriptor = self.clientes[i]
        if i >= self.indice and not self.fallo:
            self.siguiente = block.timestamp + self.periodo
            self.indi = empty(uint256)
            self.todos = True
        else:
            if not self.clientes[i].recibido:
                self.fallo = True
                self.indi = i
            elif not self.fallo:
                if cliente.pagado and cliente.envpag:
                    send(self.empresa,self.cuota)
                    cliente.envpag = True
                elif not cliente.pagado :
                    send(msg.sender,cliente.acumulado)
                    self.libres[self.indi]= i
                    self.registrado[cliente.cliente] = empty(BoolNum)
                    self.indilibres += 1
                    cliente = empty(Subcriptor)
                else:
                    cliente.pagado = False
                    cliente.enviado = False
                    cliente.recibido = False
                self.clientes[i] = cliente
    if not self.fallo and not self.todos:
        self.indi = ind + 20
