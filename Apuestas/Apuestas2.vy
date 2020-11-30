#Apostar en un partido de futbol
struct Bet:
    apostador: address
    equipo1: int128
    equipo2: int128
    apuesta: uint256
    
casa:public(address)

cequipo1: int128
cequipo2: int128
hstart:public(uint256)
hend: public(uint256)
ni : int128
apostadores: HashMap[int128, Bet]
niv : int128
invertido: bool
todos: bool
inicial:uint256

@payable
@external    
def __init__( tiempo_inicio: uint256,duracion: uint256):
    assert tiempo_inicio > 0
    self.inicial = msg.value
    self.casa = msg.sender
    self.hstart = block.timestamp + tiempo_inicio
    self.hend = self.hstart + duracion
    
@external
@payable
def bet(eq1: int128,eq2: int128):
    assert block.timestamp < self.hstart 
    assert msg.sender != self.casa
    assert msg.value > 0 
    nfi: int128 = self.ni
    self.apostadores[nfi] = Bet({apostador: msg.sender,equipo1: eq1, equipo2:eq2,apuesta:msg.value})
    self.ni = nfi + 1

@payable
@external
def mitad():
    assert block.timestamp > self.hstart
    assert self.casa == msg.sender
    assert msg.value + self.inicial  >= ((self.balance - self.inicial -msg.value) / 2)
    self.invertido = True

@internal
def _acertado(i: int128)->bool:
    return (self.apostadores[i].equipo1 == self.cequipo1) and (self.apostadores[i].equipo2 == self.cequipo2)

@external
def devolver(_eq1:int128, _eq2:int128):
    assert block.timestamp > self.hend
    assert self.casa == msg.sender
    assert self.invertido
    assert _eq1 >= 0 and _eq2 >= 0
    self.cequipo1 = _eq1
    self.cequipo2 = _eq2
    nive:int128 = self.niv
    for i in range (nive,nive+30):
        if i > self.ni:
            nive = self.ni
            self.todos = True
            return
        else:
            if self._acertado(i):
                send(self.apostadores[i].apostador, self.apostadores[i].apuesta + (self.apostadores[i].apuesta/2))
                
            self.apostadores[i]= empty(Bet)
    self.niv = nive + 30

   
    
@external
def finalizacion():
    assert self.todos
    selfdestruct(self.casa)
