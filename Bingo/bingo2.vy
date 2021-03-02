# @version ^0.2.8
#Bingo
#Version de bingo1 con mayor uso de gas

#Variable para contener la direccion de la casa de apuestas
casa: public(address)
#Precio del carton
precio: public(uint256)
#Porcentaje de la cantidad acumulada que se lleva la linea
porc_linea: public(uint256)
#porcentaje de la cantidad acumulada que se lleva el bingo
porc_bingo: public(uint256)
#Cantidad acumulada
acumulado: public(uint256)
#Si el numero ha salido el bool asociado se cambia a true
lista_numeros:public(HashMap[uint256,bool])
#Booleanos para saber si ya se ha cantado linea y si se ha empezado a jugar
yalinea: public(bool)
empezado: public(bool)

#Constructor para inicializar el contrato
@payable
@external
def __init__(_precio: uint256,_porc_linea: uint256,_porc_bingo: uint256):
    assert (_porc_linea > 0 and _porc_linea < 100)
    assert (_porc_bingo > 0 and _porc_bingo < 100)
    assert _porc_bingo +_porc_linea <= 100
    assert _precio > 0
    self.casa = msg.sender
    self.precio = _precio
    self.porc_linea = _porc_linea
    self.porc_bingo = _porc_bingo
    self.acumulado = msg.value

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
    return(self.acumulado*self.porc_bingo /100)

#Funcion para saber lo que se puede ganar cantando bingo con lo que hay acumulado    
@view
@external
def ganarconbingo()->uint256:
    return self._ganarconbingo()

#Funcion para cambiar el valor booleano al numero que acaba de salir
@external
def ponernumero(numero: uint256):
    assert self.empezado,"Ha empezado"
    assert self.casa == msg.sender,"Casa"
    assert numero > 0,"Mayor que 0"
    assert numero < 101,"Menor que 101"
    assert not self.lista_numeros[numero],"No ha salido"
    self.lista_numeros[numero] = True

#Funcion para comprar una cantidad de cartones, el ether se almacena en acumulado    
@payable
@external
def comprarcarton():
    assert msg.sender != self.casa,"Jugador"
    assert not self.empezado,"No ha empezado"
    assert msg.value >= self.precio,"Manda ether"
    cantidad:uint256 = msg.value/ self.precio
    self.acumulado += msg.value

#Funcion que es llamada por la casa de apuestas para empezar el juego
@external
def empezar():
    assert msg.sender == self.casa,"Casa"
    self.empezado = True    

#Funcion interna que dados 5 numeros devuelve un bool para saber si son distintos o no
@internal
def _5distintos(n1: uint256, n2: uint256,n3: uint256,n4: uint256,n5: uint256)->bool:
    return ((n1 != n2) and (n1!= n3) and (n1 != n4) and(n1 != n5) and (n2 != n3) and (n2 != n3) and ( n3 != n4) and (n3 != n5) and (n3 != n4) and (n3 != n5) and (n4 != n5))

#Funcion interna igual que la anterior pero en vez de para 5 numeros para 15
@internal
def _15distintos(n1:uint256,n2:uint256,n3:uint256,n4:uint256,n5:uint256, n6:uint256,n7:uint256,n8:uint256,n9:uint256,n10:uint256,n11:uint256,n12:uint256,n13:uint256,n14:uint256,n15:uint256)->bool:
    return ((n1 != n2) and ( n1 != n3) and (n1 != n4) and (n1 != n5) and (n1 != n6) and (n1!= n7) and (n1 != n8) and ( n1 != n9) and (n1 != n10) and (n1 != n11) and (n1 != n12) and (n1!= n13) and (n1 != n14) and (n1 != n15) and (n2 != n3) and (n2 != n4) and (n2 != n5) and (n2 != n6) and (n2!= n7) and (n2 != n8) and ( n2 != n9) and (n2 != n10) and (n2!= n11) and (n2 != n12) and (n2!= n13) and (n2 != n14) and (n2 != n15) and (n3 != n4) and (n3 != n5) and (n3 != n6) and (n3!= n7) and (n3 != n8) and ( n3 != n9) and (n3 != n10) and (n3!= n11) and (n3 != n12) and (n3!= n13) and (n3 != n14) and (n3 != n15) and (n4 != n5) and (n4 != n6) and (n4!= n7) and (n4 != n8) and ( n4 != n9) and (n4 != n10) and (n4!= n11) and (n4 != n12) and (n4!= n13) and (n4 != n14) and (n4 != n15) and (n5 != n6) and (n5!= n7) and (n5 != n8) and ( n5 != n9) and (n5 != n10) and (n5!= n11) and (n5 != n12) and (n5!= n13) and (n5 != n14) and (n5 != n15) and (n6!= n7) and (n6 != n8) and ( n6 != n9) and (n6 != n10) and (n6!= n11) and (n6 != n12) and (n6!= n13) and (n6 != n14) and (n6 != n15) and (n7 != n8) and ( n7 != n9) and (n7 != n10) and (n7!= n11) and (n7 != n12) and (n7!= n13) and (n7 != n14) and (n7 != n15) and (n8 != n9) and (n8 != n10) and (n8!= n11) and (n8 != n12) and (n8!= n13) and (n8 != n14) and (n8 != n15) and (n9 != n10) and (n9!= n11) and (n9!= n12) and (n9!= n13) and (n9 != n14) and (n9 != n15) and (n10!= n11) and (n10 != n12) and (n10!= n13) and (n10 != n14) and (n10 != n15) and (n11 != n12) and (n11!= n13) and (n11 != n14) and (n11 != n15) and (n12!= n13) and (n12 != n14) and (n12 != n15) and (n13 != n14) and (n13 != n15) and(n14 != n15))
    


#Funcion que dados los 5 numeros de la linea comprueba que han salido y si han salido los 5 se le manda el ether correspondiente
@external
def linea(n1: uint256, n2: uint256,n3: uint256,n4: uint256,n5: uint256):
    assert self.empezado,"Ha empezado"
    assert msg.sender != self.casa,"Jugador"
    assert not self.yalinea,"No se ha cantado linea"
    assert (self.lista_numeros[n1] and self.lista_numeros[n2] and self.lista_numeros[n3] and self.lista_numeros[n4] and self.lista_numeros[n5]),"Han salido"
    assert self._5distintos(n1,n2,n3,n4,n5),"Todos distintos"
    self.yalinea =True
    send(msg.sender,self._ganarconlinea())

#Funcion que dados los 15 numeros del carton comprueba que han salido y si 
#han salidose le manda el ether correspondiente y lo restante a la casa de apuestas 
@external
def bingo(n1:uint256,n2:uint256,n3:uint256,n4:uint256,n5:uint256,
          n6:uint256,n7:uint256,n8:uint256,n9:uint256,n10:uint256,
          n11:uint256,n12:uint256,n13:uint256,n14:uint256,n15:uint256):
    assert self.empezado,"Ha empezado"
    assert msg.sender != self.casa,"Jugador"
    assert (self.lista_numeros[n1] and self.lista_numeros[n2] and self.lista_numeros[n3] and self.lista_numeros[n4] and self.lista_numeros[n5] and self.lista_numeros[n6] and self.lista_numeros[n7] and self.lista_numeros[n8] and self.lista_numeros[n9] and self.lista_numeros[n10] and self.lista_numeros[n11] and self.lista_numeros[n12] and self.lista_numeros[n13] and self.lista_numeros[n14] and self.lista_numeros[n15]),"Han salido"
    assert self._15distintos(n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15),"Todos distintos"
    
    send(msg.sender, (self.acumulado * self.porc_bingo)/100)
    selfdestruct(self.casa)
