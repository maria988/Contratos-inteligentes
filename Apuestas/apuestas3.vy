# @version ^0.2.8
#Apostar en un partido mas completo que #1 y #2
#Creamos una estructura para almacenar las apuestas en un diccionario
struct Juego:
    apostador: address
    equipo1: uint256
    equipo2: uint256
    apuesta: uint256
 
#Variables definidas inicialmente
casa:public(address)
inicial:public(uint256)
empieza:public(uint256)
termina: public(uint256)

#Variable para almacenar los puntos de cada equipo
pequipo1: uint256
pequipo2: uint256

#Variables para los indices del diccionario y el diccionario
indice : uint256
apostadores: HashMap[uint256, Juego]
sigindice : uint256

#Variables para saber si la casa ha mandado el ether necesario 
invertido: bool

#Boolenao para saber si se ha introducido los puntos de cada equipo
apuntados:bool


#Constructor del contrato, primero comprueba que el tiempo_inicio es mayor que 0
#y que el ether enviado por la casa de apuestas se mayor que cero.
@payable
@external    
def __init__( tiempo_inicio: uint256,duracion: uint256):
    assert tiempo_inicio > 0
    assert duracion > 0 
    self.inicial = msg.value
    self.casa = msg.sender
    self.empieza = block.timestamp + tiempo_inicio
    self.termina = self.empieza + duracion
 
#Funcion externa para que cada jugador apueste.
#Como entrada la funcion recibe dos argumentos, que son los puntos de cada equipo.           
@external
@payable
def apostar(eq1: uint256,eq2: uint256):
    assert block.timestamp <= self.empieza,"Antes de empezar"
    assert msg.sender != self.casa,"Jugador"
    assert msg.value > 0 ,"Apuesta positiva"
    nfi: uint256 = self.indice
    self.apostadores[nfi] = Juego({apostador: msg.sender,equipo1: eq1, equipo2:eq2,apuesta:msg.value})
    self.indice = nfi + 1

#Funcion a la que solo puede acceder la casa para saber el ether que tiene que introducir
@view
@external
def necesario()-> uint256:
    assert msg.sender == self.casa,"Casa"
    assert  block.timestamp > self.empieza,"Despues de empezar"
    return (self.balance - self.inicial) / 2

#Funcion para que la casa de apuestas introducza la mitad de ether del ether recibido.
#Se puede acceder a el cuando el partido haya empezado puesto que ya no se puede apostar.
@payable
@external
def mitad():
    assert block.timestamp > self.empieza,"Despues de empezar"
    assert self.casa == msg.sender,"Casa"
    assert msg.value + self.inicial  >= ((self.balance - self.inicial -msg.value) / 2),"Valor suficiente"
    self.invertido = True
    

#Funcion dar a los apostantes el ether ganado
@external
def devolver():
    assert self.apuntados,"Apuntados"
    assert self.casa == msg.sender,"Casa"
    assert self.invertido,"Ha invertido"
    nive:uint256 = self.sigindice
    for i in range (nive,nive+30):
        if i > self.indice:
            nive = self.indice
            selfdestruct(self.casa)
        else:
            if (self.apostadores[i].equipo1 == self.pequipo1) and (self.apostadores[i].equipo2 == self.pequipo2):
                send(self.apostadores[i].apostador,self.apostadores[i].apuesta + (self.apostadores[i].apuesta/2) )
                
    self.sigindice = nive + 30

#Funcion para asignar a las variables globales la puntuacion de cada equipo
@external
def ganadores(_eq1: uint256, _eq2: uint256):
    assert msg.sender == self.casa,"Casa"
    assert block.timestamp > self.termina,"Despues de terminar"
    assert not self.apuntados,"No apuntados"
    self.apuntados = True
    self.pequipo1 = _eq1
    self.pequipo2 = _eq2
    
#Funcion externa que devulve un booleano para saber si ha terminado el partido
@view
@external
def terminado()-> bool:
    return block.timestamp > self.termina

#Funcion externa que devulve un booleano para saber si ha empezado el partido
@view
@external
def empezado() -> bool:
    return block.timestamp > self.empieza

#Funcion externa que devuelve un uint256, que es el ether que se puede ganar
@view
@external
def ganar(apos:Juego)-> uint256:
    return apos.apuesta + (apos.apuesta/2) 

#Funcion externa que devuelve un booleano para saber si se ha acertado con la jugada o no
@view
@external
def ganado(apos: Juego)-> bool:
    assert self.apuntados,"Apuntados"
    return (apos.equipo1 == self.pequipo1) and (apos.equipo2 == self.pequipo2)
