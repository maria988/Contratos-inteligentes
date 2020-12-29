# @version ^0.2.8
#Apostar en un partido 
#Creamos una estructura para almacenar las apuestas en un diccionario
struct Juego:
    apostador: address
    equipo1: int128
    equipo2: int128
    apuesta: uint256

#Variables definidas inicialmente
casa:public(address)
inicial:public(uint256)
empieza:public(uint256)
termina: public(uint256)


ni : int128
apostadores: HashMap[int128, Juego]
niv : int128
invertido: bool
todos: bool


#Constructor del contrato, primero comprueba que el tiempo_inicio es mayor que 0
#y que el ether enviado por la casa de apuestas se mayor que cero.
@payable
@external    
def __init__( tiempo_inicio: uint256,duracion: uint256):
    assert tiempo_inicio > 0
    assert msg.value > 0
    self.inicial = msg.value
    self.casa = msg.sender
    self.empieza = block.timestamp + tiempo_inicio
    self.termina = self.empieza + duracion

#Funcion externa para que cada jugador apueste.
#Como netrada la funcion recibe dos argumentos, que son los puntos de cada equipo.
@external
@payable
def apostar(eq1: int128,eq2: int128):
    assert block.timestamp < self.empieza
    assert msg.sender != self.casa,"Jugador"
    assert msg.value > 0,"Apuesta positiva"
    nfi: int128 = self.ni
    self.apostadores[nfi] = Juego({apostador: msg.sender,equipo1: eq1, equipo2:eq2,apuesta:msg.value})
    self.ni = nfi + 1

#Funcion para que la casa de apuestas introducza la mitad de ether del ether recibido.
#Se puede acceder a el cuando el partido haya empezado puesto que ya no se puede apostar.
@payable
@external
def mitad():
    assert block.timestamp > self.empieza
    assert self.casa == msg.sender
    assert msg.value + self.inicial  >= ((self.balance - self.inicial -msg.value) / 2)
    self.invertido = True


#Funcion dar a los apostantes el dinero ganado, toma dos argumentos
#que son la puntuacion de cada equipo
@external
def devolver(_eq1:int128, _eq2:int128):
    assert block.timestamp > self.termina
    assert self.casa == msg.sender
    assert self.invertido
    assert _eq1 >= 0 and _eq2 >= 0
    nive:int128 = self.niv
    for i in range (nive,nive+30):
        if i > self.ni:
            nive = self.ni
            self.todos = True
            return
        else:
            if (self.apostadores[i].equipo1 == _eq1) and (self.apostadores[i].equipo2 == _eq2):
                send(self.apostadores[i].apostador, self.apostadores[i].apuesta + (self.apostadores[i].apuesta/2))
                
            self.apostadores[i]= empty(Juego)
    self.niv = nive + 30

#Cuando se devuelva todo el dinero, se destruye el contrato y el dinero que hubiese va a la casa
@external
def finalizacion():
    assert self.todos
    selfdestruct(self.casa)
