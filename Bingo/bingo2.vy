#Bingo
#Variable para contener la direccion de la casa de apuestas
casa: public(address)
#Precio del carton
precio: uint256
#Porcentaje de la cantidad acumulada que se lleva la linea
porc_linea: uint256
#porcentaje de la cantidad acumulada que se lleva el bingo
porc_bingo: uint256
#Cantidad acumulada
acumulado: uint256
#Si el numero ha salido el bool asociado se cambia a true
lista_numeros:public(HashMap[uint256,bool])
#Booleanos para saber si ya se ha cantado linea y si se ha empezado a jugar
yalinea: bool
empezado: bool

#Constructor para inicializar el contrato
@external
def __init__(_precio: uint256,_porc_linea: uint256,_porc_bingo: uint256,_inicial: uint256):
    assert (_porc_linea > 0 and _porc_linea < 100)
    assert (_porc_bingo > 0 and _porc_bingo < 100)
    assert _porc_bingo +_porc_linea <= 100
    assert _precio > 0
    self.casa = msg.sender
    self.precio = _precio
    self.porc_linea = _porc_linea
    self.porc_bingo = _porc_bingo
    self.acumulado = _inicial

#Funcion interna para saber lo que se puede ganar cantando linea con lo que hay acumulado   
@view
@internal
def _ganarconlinea()->uint256:
    return (self.acumulado * self.porc_linea /100)

#Funcion para saber lo que se puede ganar cantando linea con lo que hay acumulado   
@view
@external
def ganarconlinea()->uint256:
    return self._ganarconlinea()

#Funcion interna para saber lo que se puede ganar cantando bingo con lo que hay acumulado    
@view
@internal
def _ganarconbingo()->uint256:
    return(self.acumulado*self.porc_linea /100)

#Funcion para saber lo que se puede ganar cantando bingo con lo que hay acumulado    
@view
@external
def ganarconbingo()->uint256:
    return self._ganarconbingo()

#Funcion para cambiar el valor booleano al numero que acaba de salir
@external
def ponernumero(numero: uint256):
    assert self.casa == msg.sender
    assert numero > 0
    assert numero < 101
    assert not self.lista_numeros[numero]
    self.lista_numeros[numero] = True

#Funcion para comprar una cantidad de cartones, el ether se almacena en acumulado    
@payable
@external
def comprarcarton():
    assert msg.sender != self.casa
    assert not self.empezado
    cantidad:uint256 = msg.value/ self.precio
    self.acumulado += msg.value

#Funcion que es llamada por la casa de apuestas para empezar el juego
@external
def empezar():
    assert msg.sender == self.casa
    self.empezado = True    

#Funcion que dados los 5 numeros de la linea comprueba que han salido y si han salido los 5 se le manda el ether correspondiente
@external
def linea(n1: uint256, n2: uint256,n3: uint256,n4: uint256,n5: uint256):
    assert msg.sender != self.casa
    assert not self.yalinea
    assert self.lista_numeros[n1]
    assert self.lista_numeros[n2]
    assert self.lista_numeros[n3]
    assert self.lista_numeros[n4]
    assert self.lista_numeros[n5]
    self.yalinea =True
    send(msg.sender,self._ganarconlinea())

#Funcion que dados los 15 numeros del carton comprueba que han salido y si 
#han salidose le manda el ether correspondiente y lo restante a la casa de apuestas 
@external
def bingo(n1:uint256,n2:uint256,n3:uint256,n4:uint256,n5:uint256,
          n6:uint256,n7:uint256,n8:uint256,n9:uint256,n10:uint256,
          n11:uint256,n12:uint256,n13:uint256,n14:uint256,n15:uint256):
    assert msg.sender != self.casa
    assert self.lista_numeros[n1]
    assert self.lista_numeros[n2]
    assert self.lista_numeros[n3]
    assert self.lista_numeros[n4]
    assert self.lista_numeros[n5]
    assert self.lista_numeros[n6]
    assert self.lista_numeros[n7]
    assert self.lista_numeros[n8]
    assert self.lista_numeros[n9]
    assert self.lista_numeros[n10]
    assert self.lista_numeros[n11]
    assert self.lista_numeros[n12]
    assert self.lista_numeros[n13]
    assert self.lista_numeros[n14]
    assert self.lista_numeros[n15]
    send(msg.sender, self._ganarconbingo)
    selfdestruct(self.casa)
